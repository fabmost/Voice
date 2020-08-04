class PollAnswerModel {
  final int id;
  final String answer;
  final int count;
  final String url;
  final bool isVote;

  PollAnswerModel({
    this.id,
    this.answer,
    this.count,
    this.url,
    this.isVote,
  });
}
