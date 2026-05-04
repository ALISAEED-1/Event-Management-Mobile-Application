class VoteModel {
  final String? docId;
  final String? question;
  final List<String>? options;
  final String? imageUrl;
  final String? createdAt;
  final Map<String, int>? voteCounts;

  VoteModel({
    this.docId,
    this.question,
    this.options,
    this.imageUrl,
    this.createdAt,
    this.voteCounts,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List?;
    final rawCounts = json['voteCounts'] as Map?;
    return VoteModel(
      docId: json['docId'] as String?,
      question: json['question'] as String?,
      options: rawOptions?.map((e) => e.toString()).toList(),
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt']?.toString(),
      voteCounts: rawCounts != null
          ? rawCounts.map(
              (k, v) => MapEntry(k.toString(), (v as num).toInt()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (docId != null) 'docId': docId,
      if (question != null) 'question': question,
      if (options != null) 'options': options,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (createdAt != null) 'createdAt': createdAt,
      if (voteCounts != null) 'voteCounts': voteCounts,
    };
  }
}
