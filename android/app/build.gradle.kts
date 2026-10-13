import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeyProperties = Properties().apply {
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.isFile) {
        propertiesFile.inputStream().use(::load)
    }
}

fun releaseSetting(environmentName: String, propertyName: String): String? =
    System.getenv(environmentName)?.takeIf(String::isNotBlank)
        ?: releaseKeyProperties.getProperty(propertyName)?.takeIf(String::isNotBlank)

val releaseStoreFilePath = releaseSetting("ANDROID_KEYSTORE_PATH", "storeFile")
val releaseStorePassword = releaseSetting("ANDROID_KEYSTORE_PASSWORD", "storePassword")
val releaseKeyAlias = releaseSetting("ANDROID_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = releaseSetting("ANDROID_KEY_PASSWORD", "keyPassword")
val releaseSigningConfigured = listOf(
    releaseStoreFilePath,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { it != null }

android {
    namespace = "io.nyoom.rexorder"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.nyoom.rexorder"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseSigningConfigured) {
                storeFile = rootProject.file(releaseStoreFilePath!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (releaseSigningConfigured) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                logger.warn("Release keystore not configured; signing release with the debug key")
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    implementation("org.apache.commons:commons-compress:1.28.0")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
