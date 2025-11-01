import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String username; // email / username untuk login

  @HiveField(1)
  String password;

  @HiveField(2)
  String displayName; // nama yang tampil di profil / home

  UserModel({
    required this.username,
    required this.password,
    required this.displayName,
  });
}
