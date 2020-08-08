class PollAnswerModel {
  final String id;
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

  static List<PollAnswerModel> listFromJson(List<dynamic> content) {
    List<PollAnswerModel> mList = [];

    content.forEach((element) {
      mList.add(PollAnswerModel(
        id: element['id'],
        answer: element['answer'],
        count: element['count'],
        url: element['icon'],
        isVote: element['is_vote'],
      ));
    });

    return mList;
  }
}
