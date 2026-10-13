package io.nyoom.rexorder

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import android.os.SystemClock
import android.provider.OpenableColumns
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream
import org.apache.commons.compress.compressors.bzip2.BZip2CompressorInputStream
import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.util.UUID

class ModelImporter(
    private val contentResolver: ContentResolver,
    private val cacheDirectory: File,
    private val filesDirectory: File,
) {
    fun importModel(
        uri: Uri,
        modelId: String,
        displayName: String,
        requiredFiles: List<String>,
        kind: String,
        targetFileName: String?,
        onProgress: (Long, Long) -> Unit,
    ): String {
        requireValidModelId(modelId)
        require(displayName.isNotBlank()) { "Missing model display name." }
        require(kind == "tar.bz2" || kind == "file") { "Unsupported archive type." }
        require(requiredFiles.isNotEmpty()) { "The model has no required files." }
        requiredFiles.forEach(::requireValidRelativePath)
        if (kind == "file") {
            require(targetFileName != null) { "Missing target model file name." }
            requireValidRelativePath(targetFileName)
            require(targetFileName in requiredFiles) {
                "The target file is not in the required model files."
            }
        }

        val modelRoot = File(filesDirectory, "models")
        if (!modelRoot.exists() && !modelRoot.mkdirs()) {
            throw IOException("Unable to create model directory.")
        }
        val temporaryFile = File(cacheDirectory, "model-${UUID.randomUUID()}.download")
        val partialDirectory = File(modelRoot, "$modelId.partial")
        val destination = File(modelRoot, modelId)
        val backup = File(modelRoot, "$modelId.previous")
        var lastProgressBytes = 0L
        var lastProgressTime = SystemClock.elapsedRealtime()
        try {
            val expectedLength = queryLength(uri)
            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(temporaryFile).use { output ->
                    val buffer = ByteArray(COPY_BUFFER_SIZE)
                    var bytesRead = 0L
                    while (true) {
                        val count = input.read(buffer)
                        if (count < 0) break
                        output.write(buffer, 0, count)
                        bytesRead += count
                        val elapsedTime = SystemClock.elapsedRealtime() - lastProgressTime
                        if (
                            bytesRead - lastProgressBytes >= PROGRESS_BYTES_INTERVAL &&
                            elapsedTime >= PROGRESS_TIME_INTERVAL_MS
                        ) {
                            onProgress(bytesRead, expectedLength)
                            lastProgressBytes = bytesRead
                            lastProgressTime = SystemClock.elapsedRealtime()
                        }
                    }
                    onProgress(bytesRead, expectedLength)
                }
            } ?: throw IOException("Unable to open the selected document.")

            partialDirectory.deleteRecursively()
            if (!partialDirectory.mkdirs()) {
                throw IOException("Unable to create temporary model directory.")
            }
            try {
                when (kind) {
                    "tar.bz2" ->
                        extractArchive(temporaryFile, partialDirectory, requiredFiles)
                    "file" -> {
                        if (temporaryFile.length() == 0L) {
                            throw IOException("The selected model file is empty.")
                        }
                        val output = File(partialDirectory, targetFileName!!)
                        output.parentFile?.mkdirs()
                        FileInputStream(temporaryFile).use { input ->
                            FileOutputStream(output).use { out ->
                                input.copyTo(out, COPY_BUFFER_SIZE)
                            }
                        }
                    }
                }
                if (partialDirectory.walkTopDown().none { it.isFile }) {
                    throw IOException("The archive did not contain supported model files.")
                }
                val missingFiles = requiredFiles.filterNot {
                    File(partialDirectory, it).isFile
                }
                if (missingFiles.isNotEmpty()) {
                    throw IOException(
                        "The archive is missing required files: ${missingFiles.joinToString()}.",
                    )
                }
            } catch (error: Exception) {
                if (kind == "tar.bz2") {
                    throw IOException(
                        "The selected file is not a valid $displayName " +
                            "archive: ${error.message ?: "Unable to decode the archive."}",
                        error,
                    )
                }
                throw error
            }
            if (backup.exists()) backup.deleteRecursively()
            val hadDestination = destination.exists()
            if (hadDestination && !destination.renameTo(backup)) {
                throw IOException("Unable to prepare the existing model for replacement.")
            }
            if (!partialDirectory.renameTo(destination)) {
                if (hadDestination) backup.renameTo(destination)
                throw IOException("Unable to install the imported model.")
            }
            backup.deleteRecursively()
            return destination.absolutePath
        } finally {
            temporaryFile.delete()
            partialDirectory.deleteRecursively()
        }
    }

    fun listInstalled(): Map<String, List<String>> {
        val modelRoot = File(filesDirectory, "models")
        if (!modelRoot.isDirectory) return emptyMap()
        return modelRoot.listFiles()
            ?.filter {
                it.isDirectory && !it.name.endsWith(".partial") &&
                    !it.name.endsWith(".previous")
            }
            ?.associate { directory ->
                directory.name to directory.walkTopDown()
                    .filter { it.isFile }
                    .map { it.relativeTo(directory).invariantSeparatorsPath }
                    .toList()
            } ?: emptyMap()
    }

    fun delete(modelId: String): Boolean {
        requireValidModelId(modelId)
        return File(File(filesDirectory, "models"), modelId).deleteRecursively()
    }

    private fun extractArchive(
        archive: File,
        destination: File,
        requiredFiles: List<String>,
    ) {
        BufferedInputStream(FileInputStream(archive)).use { input ->
            BZip2CompressorInputStream(input, true).use { compressed ->
                TarArchiveInputStream(compressed).use { tar ->
                    while (true) {
                        val entry = tar.getNextEntry() ?: break
                        if (!entry.isFile) continue
                        val pathParts = entry.name
                            .replace('\\', '/')
                            .trimStart('/')
                            .split('/')
                            .filter { it.isNotBlank() && it != "." }
                        if (pathParts.isEmpty() || pathParts.any { it == ".." }) continue
                        val fileName = pathParts.last()
                        val outputPath = when {
                            fileName.endsWith(".wav") &&
                                pathParts.getOrNull(pathParts.lastIndex - 1) == "test_wavs" ->
                                "test_wavs/$fileName"
                            else -> requiredFiles.firstOrNull { requiredFile ->
                                val requiredFileName = requiredFile.substringAfterLast('/')
                                fileName == requiredFileName ||
                                    fileName.endsWith("-$requiredFileName")
                            }
                        } ?: continue
                        val output = File(destination, outputPath)
                        output.parentFile?.mkdirs()
                        FileOutputStream(output).use { out ->
                            val buffer = ByteArray(COPY_BUFFER_SIZE)
                            while (true) {
                                val count = tar.read(buffer)
                                if (count < 0) break
                                out.write(buffer, 0, count)
                            }
                        }
                    }
                }
            }
        }
    }

    private fun queryLength(uri: Uri): Long {
        var cursor: Cursor? = null
        return try {
            cursor = contentResolver.query(uri, arrayOf(OpenableColumns.SIZE), null, null, null)
            if (cursor?.moveToFirst() == true) {
                val sizeColumn = cursor.getColumnIndex(OpenableColumns.SIZE)
                if (sizeColumn >= 0 && !cursor.isNull(sizeColumn)) cursor.getLong(sizeColumn) else -1L
            } else {
                -1L
            }
        } finally {
            cursor?.close()
        }
    }

    private fun requireValidModelId(modelId: String) {
        require(modelId.matches(Regex("[a-z0-9-]+"))) { "Invalid model id." }
    }

    private fun requireValidRelativePath(path: String) {
        require(
            path.isNotBlank() && !path.startsWith('/') &&
                path.split('/').all { it.isNotBlank() && it != "." && it != ".." } &&
                '\\' !in path,
        ) { "Invalid model file path." }
    }

    companion object {
        private const val COPY_BUFFER_SIZE = 64 * 1024
        private const val PROGRESS_BYTES_INTERVAL = 1024 * 1024
        private const val PROGRESS_TIME_INTERVAL_MS = 100L
    }
}
