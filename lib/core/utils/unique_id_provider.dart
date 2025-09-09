abstract class UniqueIdProvider {
  static int provide() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100_000);
  }
}