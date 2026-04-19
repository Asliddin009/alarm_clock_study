import 'package:alearn/features/points/domain/i_points_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefPointsRepo implements IPointsRepo {
  SharedPrefPointsRepo(this._sharedPreferences);

  static const String storageKey = 'points_balance';
  static const int initialBalance = 12;

  final SharedPreferences _sharedPreferences;

  @override
  Future<int> getBalance() async {
    return _ensureBalance();
  }

  @override
  Future<int> addPoints(int amount) async {
    final currentBalance = await _ensureBalance();
    final nextBalance = currentBalance + amount;
    await _sharedPreferences.setInt(storageKey, nextBalance);
    return nextBalance;
  }

  @override
  Future<int> spendPoints(int amount) async {
    final currentBalance = await _ensureBalance();
    if (currentBalance < amount) {
      throw StateError('Not enough points to complete the action.');
    }
    final nextBalance = currentBalance - amount;
    await _sharedPreferences.setInt(storageKey, nextBalance);
    return nextBalance;
  }

  Future<int> _ensureBalance() async {
    final storedBalance = _sharedPreferences.getInt(storageKey);
    if (storedBalance != null) {
      return storedBalance;
    }
    await _sharedPreferences.setInt(storageKey, initialBalance);
    return initialBalance;
  }
}
