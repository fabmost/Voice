import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';

class ShareContent {

  void sharePoll(id) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://galup.page.link',
      link:
          Uri.parse('https://galup.page.link/poll/$id'),
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
      ),
    );

    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    Uri url = shortLink.shortUrl;

    Share.share('Te comparto esta encuesta de Galup $url');
  }

}