import 'package:alearn/features/points/data/shared_pref_points_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('seeds the initial mock balance when empty', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();
    final repo = SharedPrefPointsRepo(sharedPreferences);

    final balance = await repo.getBalance();

    expect(balance, SharedPrefPointsRepo.initialBalance);
  });

  test('spends and adds points', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPrefPointsRepo.storageKey: 12,
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    final repo = SharedPrefPointsRepo(sharedPreferences);

    final spentBalance = await repo.spendPoints(2);
    final addedBalance = await repo.addPoints(3);

    expect(spentBalance, 10);
    expect(addedBalance, 13);
  });

  test('throws when spending more points than available', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPrefPointsRepo.storageKey: 1,
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    final repo = SharedPrefPointsRepo(sharedPreferences);

    expect(() => repo.spendPoints(2), throwsStateError);
  });
}
