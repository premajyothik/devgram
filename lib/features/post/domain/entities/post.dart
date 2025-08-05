import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final DateTime timeStamp;
  final String text;
  final String? imageUrl;
  final List<String>? likeBy;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.timeStamp,
    required this.text,
    this.imageUrl,
    this.likeBy,
  });

  Post copyWith(String imgUrl) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      timeStamp: timeStamp,
      text: text,
      imageUrl: imgUrl ?? "",
      likeBy: likeBy ?? [],
    );
  }

  // convert post to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'timeStamp': Timestamp.fromDate(timeStamp),
      'text': text,
      'imageUrl': imageUrl,
      'likeBy': likeBy,
    };
  }

  //convert json to post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      timeStamp: (json['timeStamp'] as Timestamp).toDate(),
      text: json['text'],
      imageUrl: json['imageUrl'] ?? "",
      likeBy: List<String>.from(json['likeBy'] ?? []),
    );
  }
}
