import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';

class ShareContent {
  void sharePoll(id, title) async {
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
        title: title,
        description: 'En Galup tu opinión cuenta',
        imageUrl: Uri.parse('https://firebasestorage.googleapis.com/v0/b/voiceinc-e945f.appspot.com/o/WhatsApp%20Image%202020-07-17%20at%208.23.43%20PM.jpeg?alt=media&token=8c8e6eb8-a87c-4320-8da0-9b000ce3e66e'),
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share(
        'Te invito a conocer la opinión de muchos y a contestar esta encuesta de Galup. $url');
  }

  void shareChallenge(id, title) async {
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
        imageUrl: Uri.parse('https://firebasestorage.googleapis.com/v0/b/voiceinc-e945f.appspot.com/o/WhatsApp%20Image%202020-07-17%20at%208.23.43%20PM.jpeg?alt=media&token=8c8e6eb8-a87c-4320-8da0-9b000ce3e66e'),
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share(
        'Te reto a crecer con esta comunidad\n¡Únete y suma tu voz! $url');
  }

  void shareCause(id, title) async {
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
        imageUrl: Uri.parse('https://firebasestorage.googleapis.com/v0/b/voiceinc-e945f.appspot.com/o/WhatsApp%20Image%202020-07-17%20at%208.23.43%20PM.jpeg?alt=media&token=8c8e6eb8-a87c-4320-8da0-9b000ce3e66e'),
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share(
        'Suma tu voz a esta noble causa Galup y sé el cambio que todos deseamos. $url');
  }
}
