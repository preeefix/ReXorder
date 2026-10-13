// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recording.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Recording {

 String get id; String get title; DateTime get createdAt; int get durationMs; String get fileName; int get sampleRate; RecordingStatus get status;
/// Create a copy of Recording
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingCopyWith<Recording> get copyWith => _$RecordingCopyWithImpl<Recording>(this as Recording, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Recording;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recording&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.sampleRate, _this.sampleRate) || other.sampleRate == _this.sampleRate)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as Recording;
  return Object.hash(runtimeType,_this.id,_this.title,_this.createdAt,_this.durationMs,_this.fileName,_this.sampleRate,_this.status);
}

@override
String toString() {
  final _this = this as Recording;
  return 'Recording(id: ${_this.id}, title: ${_this.title}, createdAt: ${_this.createdAt}, durationMs: ${_this.durationMs}, fileName: ${_this.fileName}, sampleRate: ${_this.sampleRate}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $RecordingCopyWith<$Res>  {
  factory $RecordingCopyWith(Recording value, $Res Function(Recording) _then) = _$RecordingCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime createdAt, int durationMs, String fileName, int sampleRate, RecordingStatus status
});




}
/// @nodoc
class _$RecordingCopyWithImpl<$Res>
    implements $RecordingCopyWith<$Res> {
  _$RecordingCopyWithImpl(this._self, this._then);

  final Recording _self;
  final $Res Function(Recording) _then;

/// Create a copy of Recording
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? createdAt = null,Object? durationMs = null,Object? fileName = null,Object? sampleRate = null,Object? status = null,}) {
  return _then(Recording(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,sampleRate: null == sampleRate ? _self.sampleRate : sampleRate // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecordingStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Recording].
extension RecordingPatterns on Recording {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recording value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recording() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recording value)  $default,){
final _that = this;
switch (_that) {
case _Recording():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recording value)?  $default,){
final _that = this;
switch (_that) {
case _Recording() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime createdAt,  int durationMs,  String fileName,  int sampleRate,  RecordingStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recording() when $default != null:
return $default(_that.id,_that.title,_that.createdAt,_that.durationMs,_that.fileName,_that.sampleRate,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime createdAt,  int durationMs,  String fileName,  int sampleRate,  RecordingStatus status)  $default,) {final _that = this;
switch (_that) {
case _Recording():
return $default(_that.id,_that.title,_that.createdAt,_that.durationMs,_that.fileName,_that.sampleRate,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime createdAt,  int durationMs,  String fileName,  int sampleRate,  RecordingStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Recording() when $default != null:
return $default(_that.id,_that.title,_that.createdAt,_that.durationMs,_that.fileName,_that.sampleRate,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _Recording implements Recording {
  const _Recording({required this.id, required this.title, required this.createdAt, required this.durationMs, required this.fileName, required this.sampleRate, required this.status});


@override final  String id;
@override final  String title;
@override final  DateTime createdAt;
@override final  int durationMs;
@override final  String fileName;
@override final  int sampleRate;
@override final  RecordingStatus status;

/// Create a copy of Recording
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordingCopyWith<_Recording> get copyWith => __$RecordingCopyWithImpl<_Recording>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recording&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.sampleRate, sampleRate) || other.sampleRate == sampleRate)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,createdAt,durationMs,fileName,sampleRate,status);
}

@override
String toString() {
    return 'Recording(id: $id, title: $title, createdAt: $createdAt, durationMs: $durationMs, fileName: $fileName, sampleRate: $sampleRate, status: $status)';
}


}

/// @nodoc
abstract mixin class _$RecordingCopyWith<$Res> implements $RecordingCopyWith<$Res> {
  factory _$RecordingCopyWith(_Recording value, $Res Function(_Recording) _then) = __$RecordingCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime createdAt, int durationMs, String fileName, int sampleRate, RecordingStatus status
});




}
/// @nodoc
class __$RecordingCopyWithImpl<$Res>
    implements _$RecordingCopyWith<$Res> {
  __$RecordingCopyWithImpl(this._self, this._then);

  final _Recording _self;
  final $Res Function(_Recording) _then;

/// Create a copy of Recording
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? createdAt = null,Object? durationMs = null,Object? fileName = null,Object? sampleRate = null,Object? status = null,}) {
  return _then(_Recording(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,sampleRate: null == sampleRate ? _self.sampleRate : sampleRate // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecordingStatus,
  ));
}


}

// dart format on
