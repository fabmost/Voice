class ResourceModel {
  final String id;
  final String type;
  final String url;

  ResourceModel({
    this.id,
    this.type,
    this.url,
  });

  static List<ResourceModel> listFromJson(List<dynamic> content) {
    List<ResourceModel> mList = [];

    content.forEach((element) {
      mList.add(ResourceModel(
        id: element['id'],
        type: element['type'],
        url: element['content'],
      ));
    });

    return mList;
  }
}
