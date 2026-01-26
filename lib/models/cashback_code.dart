class CashbackCode {
  final String siteName;
  final String code;
  final String description;
  final DateTime date;
  final String? logoUrl;

  CashbackCode({
    required this.siteName,
    required this.code,
    required this.description,
    required this.date,
    this.logoUrl,
  });
}
