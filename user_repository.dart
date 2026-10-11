import '../core/database/app_database.dart';

class UserRepository {
  UserRepository(this._database);
  final AppDatabase _database;

  Future<Map<String, dynamic>?> byEmail(String email) => _database.userByEmail(email);
  Future<Map<String, dynamic>?> byId(String id) => _database.userById(id);
  Future<void> create(Map<String, dynamic> user) => _database.createUser(user);
  Future<void> updatePassword(String id, String hash, String salt) =>
      _database.updatePassword(id, hash, salt);
  Future<List<Map<String, dynamic>>> all() => _database.allUsers();
  Future<void> setActive(String id, bool active) => _database.setUserActive(id, active);
}
