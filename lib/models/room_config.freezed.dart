// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RoomConfig _$RoomConfigFromJson(Map<String, dynamic> json) {
  return _RoomConfig.fromJson(json);
}

/// @nodoc
mixin _$RoomConfig {
  /// The LiveKit server URL (e.g., 'wss://my-livekit-server.com')
  String get url => throw _privateConstructorUsedError;

  /// Authentication token from LiveKit
  String get token => throw _privateConstructorUsedError;

  /// Name of the room to join
  String get roomName => throw _privateConstructorUsedError;

  /// Display name for the participant
  String get userName => throw _privateConstructorUsedError;

  /// Serializes this RoomConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoomConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomConfigCopyWith<RoomConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomConfigCopyWith<$Res> {
  factory $RoomConfigCopyWith(
    RoomConfig value,
    $Res Function(RoomConfig) then,
  ) = _$RoomConfigCopyWithImpl<$Res, RoomConfig>;
  @useResult
  $Res call({String url, String token, String roomName, String userName});
}

/// @nodoc
class _$RoomConfigCopyWithImpl<$Res, $Val extends RoomConfig>
    implements $RoomConfigCopyWith<$Res> {
  _$RoomConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? token = null,
    Object? roomName = null,
    Object? userName = null,
  }) {
    return _then(
      _value.copyWith(
            url:
                null == url
                    ? _value.url
                    : url // ignore: cast_nullable_to_non_nullable
                        as String,
            token:
                null == token
                    ? _value.token
                    : token // ignore: cast_nullable_to_non_nullable
                        as String,
            roomName:
                null == roomName
                    ? _value.roomName
                    : roomName // ignore: cast_nullable_to_non_nullable
                        as String,
            userName:
                null == userName
                    ? _value.userName
                    : userName // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoomConfigImplCopyWith<$Res>
    implements $RoomConfigCopyWith<$Res> {
  factory _$$RoomConfigImplCopyWith(
    _$RoomConfigImpl value,
    $Res Function(_$RoomConfigImpl) then,
  ) = __$$RoomConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, String token, String roomName, String userName});
}

/// @nodoc
class __$$RoomConfigImplCopyWithImpl<$Res>
    extends _$RoomConfigCopyWithImpl<$Res, _$RoomConfigImpl>
    implements _$$RoomConfigImplCopyWith<$Res> {
  __$$RoomConfigImplCopyWithImpl(
    _$RoomConfigImpl _value,
    $Res Function(_$RoomConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoomConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? token = null,
    Object? roomName = null,
    Object? userName = null,
  }) {
    return _then(
      _$RoomConfigImpl(
        url:
            null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                    as String,
        token:
            null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                    as String,
        roomName:
            null == roomName
                ? _value.roomName
                : roomName // ignore: cast_nullable_to_non_nullable
                    as String,
        userName:
            null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomConfigImpl implements _RoomConfig {
  const _$RoomConfigImpl({
    required this.url,
    required this.token,
    required this.roomName,
    this.userName = 'anonymous',
  });

  factory _$RoomConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomConfigImplFromJson(json);

  /// The LiveKit server URL (e.g., 'wss://my-livekit-server.com')
  @override
  final String url;

  /// Authentication token from LiveKit
  @override
  final String token;

  /// Name of the room to join
  @override
  final String roomName;

  /// Display name for the participant
  @override
  @JsonKey()
  final String userName;

  @override
  String toString() {
    return 'RoomConfig(url: $url, token: $token, roomName: $roomName, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomConfigImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.roomName, roomName) ||
                other.roomName == roomName) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, token, roomName, userName);

  /// Create a copy of RoomConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomConfigImplCopyWith<_$RoomConfigImpl> get copyWith =>
      __$$RoomConfigImplCopyWithImpl<_$RoomConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomConfigImplToJson(this);
  }
}

abstract class _RoomConfig implements RoomConfig {
  const factory _RoomConfig({
    required final String url,
    required final String token,
    required final String roomName,
    final String userName,
  }) = _$RoomConfigImpl;

  factory _RoomConfig.fromJson(Map<String, dynamic> json) =
      _$RoomConfigImpl.fromJson;

  /// The LiveKit server URL (e.g., 'wss://my-livekit-server.com')
  @override
  String get url;

  /// Authentication token from LiveKit
  @override
  String get token;

  /// Name of the room to join
  @override
  String get roomName;

  /// Display name for the participant
  @override
  String get userName;

  /// Create a copy of RoomConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomConfigImplCopyWith<_$RoomConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
