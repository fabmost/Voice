import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  final titles = [
    '¡Encuestas, retos y diversión!',
    'Crea cientos de encuestas para sabe que opinan tus amigos',
    '¡Lo retos nunca fueron tan divertidos!',
    'Únete a miles de personas que ya están compartiendo encuestas, retos y videos'
  ];
  final contents = [
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
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
    return Scaffold(
      body: WillPopScope(
        onWillPop: _preventPopIfOpen,
        child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          itemCount: titles.length,
          itemBuilder: (ctx, i) =>
              OnBoarding(titles[i], contents[i], _next, _skip),
        ),
      ),
    );
  }
}
