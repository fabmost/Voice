class CertificateModel {
  final String icon;
  final String description;

  CertificateModel({
    this.icon,
    this.description,
  });

  static CertificateModel fromJson(Map content) {
    return CertificateModel(
      icon: content['icon'],
      description: content['description'],
    );
  }
}
