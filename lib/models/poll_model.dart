import 'content_model.dart';
import 'resource_model.dart';
import 'poll_answer_model.dart';

class PollModel extends ContentModel {
  final String body;
  final int votes;
  final bool hasVoted;
  final List<PollAnswerModel> answers;
  final List<ResourceModel> resources;
  final int comments;

  PollModel({
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
    this.votes,
    this.hasVoted,
    this.answers,
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
