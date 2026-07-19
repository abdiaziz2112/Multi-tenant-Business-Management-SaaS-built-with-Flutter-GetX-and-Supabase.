/// Purpose: Everything the Setup Wizard collects for complete_setup().
/// Responsibilities: Immutable carrier + JSON shaping for the RPC contract.
/// Dependencies: none.
/// Usage: SetupData(...).toBusinessJson() / .toBranchJson()
class SetupData {
  final String phone; // E.164
  final String businessType;
  final String currency; // ISO-4217
  final String timezone; // IANA
  final String language; // en | so | ar
  final String? address;
  final String? description;
  final String branchName;
  final String? branchAddress;

  const SetupData({
    required this.phone,
    required this.businessType,
    required this.currency,
    required this.timezone,
    required this.language,
    required this.branchName,
    this.address,
    this.description,
    this.branchAddress,
  });

  Map<String, dynamic> toBusinessJson() => {
        'phone': phone,
        'business_type': businessType,
        'currency': currency,
        'timezone': timezone,
        'language': language,
        if (address != null) 'address': address,
        if (description != null) 'description': description,
      };

  Map<String, dynamic> toBranchJson() => {
        'name': branchName,
        if (branchAddress != null) 'address': branchAddress,
      };
}
