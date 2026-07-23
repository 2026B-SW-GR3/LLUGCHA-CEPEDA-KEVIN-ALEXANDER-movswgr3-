class MeetupEvent {
  final String id;
  final String discipline;
  final DateTime dateTime;
  final double latitude;
  final double longitude;
  final String locationName;
  final String? description;

  MeetupEvent({
    required this.id,
    required this.discipline,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'discipline': discipline,
      'dateTime': dateTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'description': description ?? '',
    };
  }

  factory MeetupEvent.fromMap(Map<String, dynamic> map) {
    return MeetupEvent(
      id: map['id'] as String,
      discipline: map['discipline'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      locationName: map['locationName'] as String,
      description: map['description'] as String?,
    );
  }
}
