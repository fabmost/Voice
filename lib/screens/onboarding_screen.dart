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
  final imgs = [
    'assets/onboarding_1.png',
    'assets/onboarding_2.png',
    'assets/onboarding_3.png',
    'assets/onboarding_4.png',
  ];
  final contents = [
    '¡De eso de trata esta original App! En este espacio podrás seleccionar tus intereses y así comenzar a generar y responder encuestas adaptadas a tus preferencias para hacer valer tu opinión como nunca antes.',
    'Si te gusta debatir e intercambiar ideas, Galup es tu mejor opción porque te ofrece la posibilidad de ir más allá a la hora de dar tus puntos de vista y de compartirlos con otros, escribiendo y opinando sobre los distintos contenidos.',
    'Dale emoción a tu opinión creando retos de forma divertida para ti y tus amigos. Llegando a 1000 likes podrás descubrir sorpresas con variedad de contenidos que podrás disfrutar al alcance de un “click”.',
    '¡Diviértete debatiendo con tus amigos y conocidos! Busca integrar a muchas más personas a la comunidad Galup compartiendo e invitándolos a dar su valiosa opinión en esta increíble y única aplicación.',
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
              OnBoarding(titles[i], imgs[i], contents[i], _next, _skip),
        ),
      ),
    );
  }
}
