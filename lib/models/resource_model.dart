class ResourceModel {
  final String id;
  final String type;
  final String url;
  final String thumbnail;

  ResourceModel({
    this.id,
    this.type,
    this.url,
    this.thumbnail,
  });

  static List<ResourceModel> listFromJson(List<dynamic> content) {
    List<ResourceModel> mList = [];

    content.forEach((element) {
      mList.add(ResourceModel(
        id: element['id'],
        type: element['type'],
        url: element['content'],
        thumbnail: element['thumbnail'],
      ));
    });

    return mList;
  }

  static ResourceModel objectFromJson(Map element) {
    return ResourceModel(
      id: element['id'],
      type: element['type'],
      url: element['content'],
      thumbnail: element['thumbnail'],
    );
  }
}
