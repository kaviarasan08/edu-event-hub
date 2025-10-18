class Student {
  Student({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.collegeId,
    required this.department,
    required this.year,
    this.profileImageUrl = '',
    this.profileUpdated = false
  });

  final String userId;
  final String name;
  final String email;
  final String phone;
  final String collegeId;
  final String department;
  final String year;
  final String profileImageUrl;
  final bool profileUpdated;

  // ✅ Convert Supabase row (Map) → Student
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      collegeId: json['college_id'] as String,
      department: json['department'] as String,
      year: json['year'] as String,
      profileImageUrl: json['profile_image_url'] ?? '',
      profileUpdated: json['profile_updated']
    );
  }

  // ✅ Convert Student → Map (for insert/update in Supabase)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'college_id': collegeId,
      'department': department,
      'year': year,
      'profile_image_url': profileImageUrl,
      'profile_updated': profileUpdated
          };
  }
}
