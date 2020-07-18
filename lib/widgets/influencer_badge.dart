import 'package:flutter/material.dart';

import '../custom/galup_font_icons.dart';

class InfluencerBadge extends StatelessWidget {
  final String type;
  final double size;

  InfluencerBadge(this.type, this.size);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'Política':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF191A1A),
        );
      case 'Conferencista':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF9A0846),
        );
      case 'Coaching':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF582F1A),
        );
      case 'Celebrity':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF56176F),
        );
      case 'Youtuber':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF953935),
        );
      case 'Makeup':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFFDB0064),
        );
      case 'Noticias':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF7B7D51),
        );
      case 'Foodie':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF761726),
        );
      case 'Traveler':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF009EBE),
        );
      case 'Gamer':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF68747A),
        );
      case 'Entretenimiento':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFFEE6B0A),
        );
      case 'Fashion':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFFFFDA00),
        );
      case 'Espectáculos':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF0070BA),
        );
      case 'Healthy':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF399A32),
        );
      case 'Libre':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFFE1302F),
        );
      case 'Escritor':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFFCDDE00),
        );
      case 'Emprendedor':
        return Icon(
          GalupFont.certification,
          size: size,
          color: Color(0xFF8A84D6),
        );
      case 'Galup':
        return Image.asset(
          'assets/badge.png',
          width: (size + 2),
        );
      default:
        return Container();
    }
  }
}
