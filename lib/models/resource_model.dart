class ResourceModel {
  final String id;
  final String type;
  final String url;
  final String thumbnail;
  final int duration;
  final double ratio;

  ResourceModel({
    this.id,
    this.type,
    this.url,
    this.thumbnail,
    this.duration,
    this.ratio,
  });

  static List<ResourceModel> listFromJson(List<dynamic> content) {
    List<ResourceModel> mList = [];

    content.forEach((element) {
      int duration =
          element['duration'] == null ? 0 : int.tryParse(element['duration']);
      mList.add(ResourceModel(
        id: element['id'],
        type: element['type'],
        url: element['content'],
        thumbnail: element['thumbnail'],
        duration: duration == null ? 0 : duration,
      ));
    });

    return mList;
  }

  static ResourceModel objectFromJson(Map element) {
    int duration =
        element['duration'] == null ? 0 : int.tryParse(element['duration']);
    return ResourceModel(
      id: element['id'],
      type: element['type'],
      url: element['content'],
      thumbnail: element['thumbnail'],
      duration: duration == null ? 0 : duration,
    );
  }
}
