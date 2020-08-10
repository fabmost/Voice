class UserModel {
  final String userName;
  final String icon;

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

  UserModel({
    this.userName,
    this.icon,
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
  });

  static UserModel fromJson(Map content) {
    return UserModel(
      userName: content['user_name'] ?? '',
      icon: content['icon'],
      name: content['name'],
      lastName: content['last_name'],
      cover: content['cover'] ?? '',
      country: content['country_code'],
      tiktok: content['tiktok'],
      facebook: content['facebook'],
      instagram: content['instagram'],
      youtube: content['youtube'],
      biography: content['biography'],
      gender: content['gender'],
      birthday: content['birthday'],
      followers: content['followers'],
      following: content['following'],
      isFollowing: content['is_following'],
    );
  }
}
