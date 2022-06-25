import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  String id;
  Timestamp endDate;
  String imageUrl;
  Timestamp? addedOn, lastUpdated;
  bool? limitedDeal, clickable;
  String? category;

  BannerModel(
      {required this.id,
      required this.endDate,
      required this.imageUrl,
      this.addedOn,
      this.lastUpdated,
      this.limitedDeal,
      this.clickable,
      this.category});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'end_date': endDate,
      'image_url': imageUrl,
      'added_on': addedOn ?? Timestamp.now(),
      'last_updated': lastUpdated ?? Timestamp.now(),
      'limited_deal': limitedDeal ?? false,
      'clickable': clickable ?? false,
      'category': category ?? ''
    };
  }
}
