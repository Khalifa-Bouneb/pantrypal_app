class NotificationSettings {
  final bool expiryAlerts;
  final bool lowStockAlerts;
  final int leadDays;

  const NotificationSettings({
    required this.expiryAlerts,
    required this.lowStockAlerts,
    required this.leadDays,
  });

  factory NotificationSettings.defaults() {
    return const NotificationSettings(
      expiryAlerts: true,
      lowStockAlerts: false,
      leadDays: 2,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      expiryAlerts: json['expiryAlerts'] == true,
      lowStockAlerts: json['lowStockAlerts'] == true,
      leadDays: (json['leadDays'] is int)
          ? (json['leadDays'] as int)
          : int.tryParse('${json['leadDays'] ?? ''}') ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expiryAlerts': expiryAlerts,
      'lowStockAlerts': lowStockAlerts,
      'leadDays': leadDays,
    };
  }

  NotificationSettings copyWith({
    bool? expiryAlerts,
    bool? lowStockAlerts,
    int? leadDays,
  }) {
    return NotificationSettings(
      expiryAlerts: expiryAlerts ?? this.expiryAlerts,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
      leadDays: leadDays ?? this.leadDays,
    );
  }
}
