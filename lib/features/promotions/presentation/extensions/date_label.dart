const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

extension DateLabel on DateTime {
  /// Formats as `31 Dec 2026`.
  String toDateLabel() => '$day ${_months[month - 1]} $year';
}
