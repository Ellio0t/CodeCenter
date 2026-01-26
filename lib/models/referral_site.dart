class ReferralSite {
  final String name;
  final String referralUrl;
  final String? logoAssetsPath; 

  ReferralSite({
    required this.name,
    required this.referralUrl,
    this.logoAssetsPath,
  });
}
