class EventModel {
  final String? docId;
  final String? title;
  final String? date;
  final String? time;
  final String? location;
  final String? detail;
  final String? imageUrl;
  final String? createdAt;

  EventModel({
    this.docId,
    this.title,
    this.date,
    this.time,
    this.location,
    this.detail,
    this.imageUrl,
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      docId: json['docId'] as String?,
      title: json['title'] as String?,
      date: json['date'] as String?,
      time: json['time'] as String?,
      location: json['location'] as String?,
      detail: json['detail'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (docId != null) 'docId': docId,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (location != null) 'location': location,
      if (detail != null) 'detail': detail,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
