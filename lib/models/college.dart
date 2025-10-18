class College {
  College({
    required this.userId,
    required this.collegeName,
    required this.email,
    required this.location,
    required this.phone,
    this.logoUrl = '',
    this.lat = 10.0000,
    this.lon = 125.0111,
    this.websiteUrl = '',
    this.profileUpdated = false,
  });

  final String userId;
  final String collegeName;
  final String email;
  final String location;
  final String phone; // 👈 better to keep as String
  final String logoUrl;
  final double lat;
  final double lon;
  final String websiteUrl;
  final bool profileUpdated;

  // ✅ Convert Supabase row (Map) → College
  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      userId: json['user_id'] as String,
      collegeName: json['college_name'] as String,
      email: json['email'] as String,
      location: json['location'] as String,
      phone: json['phone'] as String, // 👈 treat as String
      logoUrl: json['logo_url'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 10.0000,
      lon: (json['lon'] as num?)?.toDouble() ?? 125.0111,
      websiteUrl: json['website_url'] ?? '',
      profileUpdated: (json['profile_updated'] ?? false) as bool,
    );
  }

  // ✅ Convert College → Map (for insert/update in Supabase)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'college_name': collegeName,
      'email': email,
      'phone': phone,
      'logo_url': logoUrl,
      'location': location,
      'latitude': lat,
      'longitude': lon,
      'website_url': websiteUrl,
      'profile_updated': profileUpdated,
    };
  }
}
