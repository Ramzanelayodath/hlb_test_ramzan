enum PromotionCategory {
  deposit,
  card,
  transfer,
  referral;

  /// Maps an API value such as `"DEPOSIT"`. Returns `null` for unknown values so
  /// a single unexpected item can be skipped instead of failing the whole list.
  static PromotionCategory? fromApi(String value) {
    for (final category in values) {
      if (category.name.toUpperCase() == value.toUpperCase()) return category;
    }
    return null;
  }
}
