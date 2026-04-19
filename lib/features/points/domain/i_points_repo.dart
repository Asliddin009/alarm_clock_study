abstract interface class IPointsRepo {
  Future<int> getBalance();

  Future<int> addPoints(int amount);

  Future<int> spendPoints(int amount);
}
