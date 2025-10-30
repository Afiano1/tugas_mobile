import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String username; // Akan berfungsi sebagai email/username

  @HiveField(1)
  String password; // Password sudah terenkripsi

  // Hapus field 'country'

  UserModel({
    required this.username,
    required this.password,
  });
}