import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';

class ShareContent {
  final String _shareImage =
      'https://firebasestorage.googleapis.com/v0/b/voiceinc-e945f.appspot.com/o/galup-preview.png?alt=media&token=5ccd092a-9148-43bf-924a-0bad40c05a8b';
  
  void sharePoll(id, title, image) async {
    String toRemove;
    int start = title.indexOf('[');
    if (start != -1) {
      int finish = title.indexOf(']');
      toRemove = title.substring(start - 1, finish + 1);
    }
    final String sharedText =
        toRemove != null ? title.replaceAll(toRemove, '') : title;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galup.page.link',
      link: Uri.parse('https://galup.app/poll/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.galup.app',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.galup.app',
        minimumVersion: '0',
        appStoreId: '1521345975',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: sharedText,
        description: 'En Galup tu opinión cuenta',
        imageUrl: Uri.parse(image != null ? image : _shareImage),
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share(
        'Vota en esta encuesta Galup y sé la diferencia! Descárgate nuestra aplicación y se parte de la comunidad GALUP. $url');
  }

  void sharePromoPoll(id, title, image) async {
    String toRemove;
    int start = title.indexOf('[');
    if (start != -1) {
      int finish = title.indexOf(']');
      toRemove = title.substring(start - 1, finish + 1);
    }
    final String sharedText =
        toRemove != null ? title.replaceAll(toRemove, '') : title;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galup.page.link',
      link: Uri.parse('https://galup.app/promo_p/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.galup.app',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.galup.app',
        minimumVersion: '0',
        appStoreId: '1521345975',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: sharedText,
        description: 'En Galup tu opinión cuenta',
        imageUrl: Uri.parse(image != null ? image : _shareImage),
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share(
        'Vota en esta encuesta Galup y sé la diferencia! Descárgate nuestra aplicación y se parte de la comunidad GALUP. $url');
  }

  void shareChallenge(id, title, image) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galup.page.link',
      link: Uri.parse('https://galup.app/challenge/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.galup.app',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.galup.app',
        minimumVersion: '0',
        appStoreId: '1521345975',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: title,
        description: 'En Galup tu opinión cuenta',
        imageUrl: Uri.parse(image != null ? image : _shareImage),
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share(
        'Ayúdame a cumplir con este challenge Galup. Descárgate nuestra aplicación y se parte de la comunidad GALUP. $url');
  }

  void shareTip(id, title, image) async {
    String toRemove;
    int start = title.indexOf('[');
    if (start != -1) {
      int finish = title.indexOf(']');
      toRemove = title.substring(start - 1, finish + 1);
    }
    final String sharedText =
        toRemove != null ? title.replaceAll(toRemove, '') : title;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galup.page.link',
      link: Uri.parse('https://galup.app/tip/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.galup.app',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.galup.app',
        minimumVersion: '0',
        appStoreId: '1521345975',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: sharedText,
        description: 'En Galup tu opinión cuenta',
        imageUrl: Uri.parse(image != null ? image : _shareImage),
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share(
        'Tip Galup! Conoce y comparte nuestra sección de valiosos tips. Descárgate nuestra aplicación y se parte de la comunidad GALUP. $url');
  }

  void shareCause(id, title, image) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galup.page.link',
      link: Uri.parse('https://galup.app/cause/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.galup.app',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.galup.app',
        minimumVersion: '0',
        appStoreId: '1521345975',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: title,
        description: 'En Galup tu opinión cuenta',
        imageUrl: Uri.parse(image != null ? image : _shareImage),
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share(
        'Firma y apoya esta causa Galup y conviértete en un agente del cambio. Descárgate nuestra aplicación y se parte de la comunidad GALUP. $url');
  }

  void shareProfile(id, image) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galup.page.link',
      link: Uri.parse('https://galup.app/profile/$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.galup.app',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.galup.app',
        minimumVersion: '0',
        appStoreId: '1521345975',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Conoce este perfil',
        description: 'En Galup tu opinión cuenta',
        imageUrl: Uri.parse(image != null ? image : _shareImage),
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share(
        'Te invito a conocer la opinión de muchos. Descárgate nuestra aplicación y se parte de la comunidad GALUP. $url');
  }
}
