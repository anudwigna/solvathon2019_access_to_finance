// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      phonenumber: json['phonenumber'] as String?,
      emailAddress: json['emailAddress'] as String?,
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      address: json['address'] as String?,
      image: json['image'] as String?);
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'gender': instance.gender,
      'phonenumber': instance.phonenumber,
      'emailAddress': instance.emailAddress,
      'dob': instance.dob?.toIso8601String(),
      'address': instance.address,
      'image': instance.image
    };
