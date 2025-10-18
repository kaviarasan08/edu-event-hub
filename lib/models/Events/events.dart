import 'package:intl/intl.dart';

enum EventType { workshop, symposium }

class Event {
  Event({
    this.eventId = ' ',
    required this.collegeId,
    required this.eventName,
    required this.eventType,
    required this.workshopName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.startDay,
    required this.totalSeats,
    required this.location,
    this.registrationUrl = '',
  });

  final String eventId;
  final String collegeId;
  final String eventName;
  final String eventType;
  final String workshopName;
  final String description;
  final String startTime;
  final String endTime;
  final String startDate;
  final String startDay;
  final int totalSeats;
  final String location;
  final String registrationUrl;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'] as String,
      eventName: json['event_name'] as String,
      eventType: json['event_type'] as String,
      collegeId: json['college_id'] as String,
      description: json['description'] as String,
      workshopName: json['workshop_name'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      startDate: json['start_date'] as String,
      startDay: json['start_day'] as String,
      totalSeats: json['total_seats'] as int,
      location: json['location'] as String,
      registrationUrl: json['registration_url'] ?? ' ',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_name': eventName,
      'event_type': eventType,
      'college_id': collegeId,
      'workshop_name': workshopName,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'total_seats': totalSeats,
      'start_date': startDate,
      'start_day': startDay,
      'location': location,
      'registration_url': registrationUrl,
    };
  }
}
