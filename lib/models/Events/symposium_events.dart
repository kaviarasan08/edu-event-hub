class SymposiumEvent {
  SymposiumEvent({
    this.symposiumEventId = '',
    required this.eventId,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.totalSeats,
  });

  final String symposiumEventId;
  String eventId;
  String name;
  String description;
  String startTime;
  String endTime;
  int totalSeats;

  factory SymposiumEvent.fromJson(Map<String, dynamic> json) {
    return SymposiumEvent(
      symposiumEventId: json['symposium_event_id'] as String? ?? '',
      eventId: json['event_id'] as String,
      name: json['event_name'] as String,
      description: json['description'] as String? ?? '',
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      totalSeats: json['total_seats'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'name': name,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'total_seats': totalSeats,
    };
  }
}
