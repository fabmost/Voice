class NotificationModel {
  final String id;
  final String userName;
  final String icon;
  final String type;
  final String idContent;
  final String message;
  final bool isNew;

  NotificationModel({
    this.id,
    this.userName,
    this.icon,
    this.type,
    this.idContent,
    this.message,
    this.isNew,
  });

  static List<NotificationModel> listFromJson(List<dynamic> content) {
    List<NotificationModel> mList = [];

    content.forEach((element) {
      mList.add(NotificationModel(
        id: element['id'],
        userName: element['user_name'],
        icon: element['icon'],
        type: element['type'],
        idContent: element['id_content'],
        message: element['message'],
        isNew: element['is_new'],
      ));
    });

    return mList;
  }
}
