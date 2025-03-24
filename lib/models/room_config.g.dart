// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomConfigImpl _$$RoomConfigImplFromJson(Map<String, dynamic> json) =>
    _$RoomConfigImpl(
      url: json['url'] as String,
      token: json['token'] as String,
      roomName: json['roomName'] as String,
      userName: json['userName'] as String? ?? 'anonymous',
    );

Map<String, dynamic> _$$RoomConfigImplToJson(_$RoomConfigImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'token': instance.token,
      'roomName': instance.roomName,
      'userName': instance.userName,
    };
