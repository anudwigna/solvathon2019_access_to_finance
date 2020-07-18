import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String gender;
  final String phonenumber;
  final String emailAddress;
  final DateTime dob;
  final String address;
  final String image;

  User(
      {this.id,
      this.name,
      this.gender,
      this.phonenumber,
      this.emailAddress,
      this.dob,
      this.address,
      this.image});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
