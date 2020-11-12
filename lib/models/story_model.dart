import 'resource_model.dart';
import 'user_model.dart';

class StoryModel {
  final UserModel user;
  final ResourceModel story;

  StoryModel({
    this.user,
    this.story,
  });

  static List<StoryModel> listFromJson(List<dynamic> content) {
    List<StoryModel> mList = [];

    content.forEach((element) {
      mList.add(StoryModel(
        user: UserModel(
          userName: element['user_name'],
          icon: element['icon'],
        ),
        story: ResourceModel.objectFromJson(element['histories']),
      ));
    });

    return mList;
  }
}
