import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../providers/preferences_provider.dart';
import '../widgets/onboarding.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool canPop = false;
  PageController _pageController;

  final imgs = [
    'assets/onboarding_1.png',
    'assets/onboarding_2.png',
    'assets/onboarding_3.png',
    'assets/onboarding_4.png',
    'assets/onboarding_5.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_pageController.page == 3) {
      _skip();
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
  }

  void _skip() async {
    canPop = true;
    await Provider.of<Preferences>(context, listen: false).setFirstTime();
    Navigator.of(context).pop(true);
  }

  Future<bool> _preventPopIfOpen() async {
    if (canPop) {
      return true;
    }
    await Provider.of<Preferences>(context, listen: false).setFirstTime();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      Translations.of(context).text('onboarding_title_1'),
      Translations.of(context).text('onboarding_title_2'),
      Translations.of(context).text('onboarding_title_3'),
      Translations.of(context).text('onboarding_title_4'),
      Translations.of(context).text('onboarding_title_5'),
    ];

    final contents = [
      Translations.of(context).text('onboarding_subtitle_1'),
      Translations.of(context).text('onboarding_subtitle_2'),
      Translations.of(context).text('onboarding_subtitle_3'),
      Translations.of(context).text('onboarding_subtitle_4'),
      Translations.of(context).text('onboarding_subtitle_5'),
    ];
    return Scaffold(
      body: WillPopScope(
        onWillPop: _preventPopIfOpen,
        child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          itemCount: titles.length,
          itemBuilder: (ctx, i) =>
              OnBoarding(titles[i], imgs[i], contents[i], _next, _skip),
        ),
      ),
    );
  }
}
