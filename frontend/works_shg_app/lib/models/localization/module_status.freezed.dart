// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'module_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ModuleStatus _$ModuleStatusFromJson(Map<String, dynamic> json) {
  return _ModuleStatus.fromJson(json);
}

/// @nodoc
mixin _$ModuleStatus {
  Map<String, bool> get status => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ModuleStatusCopyWith<ModuleStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleStatusCopyWith<$Res> {
  factory $ModuleStatusCopyWith(
          ModuleStatus value, $Res Function(ModuleStatus) then) =
      _$ModuleStatusCopyWithImpl<$Res, ModuleStatus>;
  @useResult
  $Res call({Map<String, bool> status, String label, String value});
}

/// @nodoc
class _$ModuleStatusCopyWithImpl<$Res, $Val extends ModuleStatus>
    implements $ModuleStatusCopyWith<$Res> {
  _$ModuleStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? label = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ModuleStatusCopyWith<$Res>
    implements $ModuleStatusCopyWith<$Res> {
  factory _$$_ModuleStatusCopyWith(
          _$_ModuleStatus value, $Res Function(_$_ModuleStatus) then) =
      __$$_ModuleStatusCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, bool> status, String label, String value});
}

/// @nodoc
class __$$_ModuleStatusCopyWithImpl<$Res>
    extends _$ModuleStatusCopyWithImpl<$Res, _$_ModuleStatus>
    implements _$$_ModuleStatusCopyWith<$Res> {
  __$$_ModuleStatusCopyWithImpl(
      _$_ModuleStatus _value, $Res Function(_$_ModuleStatus) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? label = null,
    Object? value = null,
  }) {
    return _then(_$_ModuleStatus(
      status: null == status
          ? _value._status
          : status // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ModuleStatus implements _ModuleStatus {
  _$_ModuleStatus(
      {required final Map<String, bool> status,
      required this.label,
      required this.value})
      : _status = status;

  factory _$_ModuleStatus.fromJson(Map<String, dynamic> json) =>
      _$$_ModuleStatusFromJson(json);

  final Map<String, bool> _status;
  @override
  Map<String, bool> get status {
    if (_status is EqualUnmodifiableMapView) return _status;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_status);
  }

  @override
  final String label;
  @override
  final String value;

  @override
  String toString() {
    return 'ModuleStatus(status: $status, label: $label, value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ModuleStatus &&
            const DeepCollectionEquality().equals(other._status, _status) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_status), label, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ModuleStatusCopyWith<_$_ModuleStatus> get copyWith =>
      __$$_ModuleStatusCopyWithImpl<_$_ModuleStatus>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ModuleStatusToJson(
      this,
    );
  }
}

abstract class _ModuleStatus implements ModuleStatus {
  factory _ModuleStatus(
      {required final Map<String, bool> status,
      required final String label,
      required final String value}) = _$_ModuleStatus;

  factory _ModuleStatus.fromJson(Map<String, dynamic> json) =
      _$_ModuleStatus.fromJson;

  @override
  Map<String, bool> get status;
  @override
  String get label;
  @override
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$_ModuleStatusCopyWith<_$_ModuleStatus> get copyWith =>
      throw _privateConstructorUsedError;
}
