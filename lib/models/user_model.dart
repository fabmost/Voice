import 'package:voice_inc/mixins/text_mixin.dart';

import 'certificate_model.dart';

class UserModel {
  String userName;
  String icon;
  String hash;

  String name;
  String lastName;
  String cover;
  String country;
  String tiktok;
  String facebook;
  String instagram;
  String youtube;
  String biography;
  String gender;
  String birthday;
  int followers;
  int following;
  bool isFollowing;
  String idAnswer;
  CertificateModel certificate;
  int validated;

  UserModel({
    this.userName,
    this.icon,
    this.hash,
    this.name,
    this.lastName,
    this.cover,
    this.country,
    this.tiktok,
    this.facebook,
    this.instagram,
    this.youtube,
    this.biography,
    this.gender,
    this.birthday,
    this.followers,
    this.following,
    this.isFollowing,
    this.idAnswer,
    this.certificate,
    this.validated,
  });

  static UserModel fromJson(Map content) {
    return UserModel(
      userName: content['user_name'] ?? '',
      icon: content['icon'] == null
          ? null
          : content['icon'].isEmpty ? null : content['icon'],
      hash: content['user_hash'],
      name: TextMixin.fixString(content['name']),
      lastName: TextMixin.fixString(content['last_name']),
      cover: content['cover'] == null
          ? null
          : content['cover'].isEmpty ? null : content['cover'],
      country: content['country_code'],
      tiktok: content['tiktok'],
      facebook: content['facebook'],
      instagram: content['instagram'],
      youtube: content['youtube'],
      biography: content['biography'] == null
          ? null
          : TextMixin.fixString(content['biography']),
      gender: content['gender'],
      birthday: content['birhtday'],
      followers: content['followers'],
      following: content['following'],
      isFollowing: content['is_following'],
      certificate: content['certificates']['icon'] == null
          ? null
          : CertificateModel.fromJson(content['certificates']),
      validated: content['certificates']['status'] == null
          ? 0
          : int.parse(content['certificates']['status']),
    );
  }

  static List<UserModel> listFromJson(List<dynamic> content) {
    List<UserModel> mList = [];

    content.forEach((element) {
      mList.add(UserModel(
        icon: element['icon'] == null
            ? null
            : element['icon'].isEmpty ? null : element['icon'],
        userName: element['user_name'],
        name: element['name'] == null
            ? null
            : TextMixin.fixString(element['name']),
        lastName: element['last_name'] == null
            ? null
            : TextMixin.fixString(element['last_name']),
        isFollowing: element['is_following'],
        certificate: element['certificates'] == null
            ? null
            : element['certificates']['icon'] == null
                ? null
                : CertificateModel.fromJson(element['certificates']),
      ));
    });

    return mList;
  }

  static List<UserModel> votersListFromJson(List<dynamic> content) {
    List<UserModel> mList = [];

    content.forEach((element) {
      mList.add(UserModel(
        icon: element['icon'] == null
            ? null
            : element['icon'].isEmpty ? null : element['icon'],
        userName: element['user_name'],
        idAnswer: element['id_answer'],
        certificate: element['certificates'] == null
            ? null
            : element['certificates']['icon'] == null
                ? null
                : CertificateModel.fromJson(element['certificates']),
      ));
    });

    return mList;
  }

  static List<UserModel> likesListFromJson(List<dynamic> content) {
    List<UserModel> mList = [];

    content.forEach((element) {
      mList.add(UserModel(
        icon: element['icon'] == null
            ? null
            : element['icon'].isEmpty ? null : element['icon'],
        userName: element['user_name'],
        certificate: element['certificates'] == null
            ? null
            : element['certificates']['icon'] == null
                ? null
                : CertificateModel.fromJson(element['certificates']),
      ));
    });

    return mList;
  }
}
