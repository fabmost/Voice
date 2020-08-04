import 'content_model.dart';
import 'resource_model.dart';

class ChallengeModel extends ContentModel {
  final String body;
  final String parameter;
  final int goal;
  final List<ResourceModel> resources;
  final int comments;

  ChallengeModel({
    id,
    type,
    user,
    creator,
    createdAt,
    title,
    likes,
    regalups,
    hasLiked,
    hasRegalup,
    hasSaved,
    this.body,
    this.parameter,
    this.goal,
    this.resources,
    this.comments,
  }) : super(
            id: id,
            type: type,
            user: user,
            creator: creator,
            title: title,
            createdAt: createdAt,
            likes: likes,
            regalups: regalups,
            hasLiked: hasLiked,
            hasRegalup: hasRegalup,
            hasSaved: hasSaved);
}
