class UserProfile {
  final String fullName;
  final String phone;
  final String country;
  final String city;
  final String addressLine;
  final int householdSize;
  final String dietaryPreferences;
  final String allergies;
  final String avatarBase64;

  const UserProfile({
    required this.fullName,
    required this.phone,
    required this.country,
    required this.city,
    required this.addressLine,
    required this.householdSize,
    required this.dietaryPreferences,
    required this.allergies,
    required this.avatarBase64,
  });

  factory UserProfile.empty({String fullName = ''}) {
    return UserProfile(
      fullName: fullName,
      phone: '',
      country: '',
      city: '',
      addressLine: '',
      householdSize: 1,
      dietaryPreferences: '',
      allergies: '',
      avatarBase64: '',
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: (json['fullName'] as String?)?.trim() ?? '',
      phone: (json['phone'] as String?)?.trim() ?? '',
      country: (json['country'] as String?)?.trim() ?? '',
      city: (json['city'] as String?)?.trim() ?? '',
      addressLine: (json['addressLine'] as String?)?.trim() ?? '',
      householdSize: (json['householdSize'] is int)
          ? (json['householdSize'] as int)
          : int.tryParse('${json['householdSize'] ?? ''}') ?? 1,
      dietaryPreferences: (json['dietaryPreferences'] as String?)?.trim() ?? '',
      allergies: (json['allergies'] as String?)?.trim() ?? '',
      avatarBase64: (json['avatarBase64'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'country': country,
      'city': city,
      'addressLine': addressLine,
      'householdSize': householdSize,
      'dietaryPreferences': dietaryPreferences,
      'allergies': allergies,
      'avatarBase64': avatarBase64,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? country,
    String? city,
    String? addressLine,
    int? householdSize,
    String? dietaryPreferences,
    String? allergies,
    String? avatarBase64,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      city: city ?? this.city,
      addressLine: addressLine ?? this.addressLine,
      householdSize: householdSize ?? this.householdSize,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      allergies: allergies ?? this.allergies,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
    );
  }
}
