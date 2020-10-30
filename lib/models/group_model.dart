class GroupModel {
  final String id;
  final String title;
  final int members;

  GroupModel({
    this.id,
    this.title,
    this.members,
  });

  static List<GroupModel> listFromJson(List<dynamic> content) {
    List<GroupModel> mList = [];

    content.forEach((element) {
      mList.add(
        GroupModel(
          id: element['id'],
          title: element['title'],
          members: element['members'],
        ),
      );
    });

    return mList;
  }
}
