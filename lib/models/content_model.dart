import 'user_model.dart';

class ContentModel {
  final int id;
  final UserModel user;
  final UserModel creator;
  final DateTime createdAt;
  final String type;
  final String title;
  final int likes;
  final int regalups;
  final bool hasLiked;
  final bool hasRegalup;
  final bool hasSaved;

  ContentModel({
    this.id,
    this.user,
    this.creator,
    this.title,
    this.createdAt,
    this.type,
    this.likes,
    this.regalups,
    this.hasLiked,
    this.hasRegalup,
    this.hasSaved,
  });
}
