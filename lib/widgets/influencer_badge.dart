import 'package:flutter/material.dart';

import '../custom/galup_font_icons.dart';

class InfluencerBadge extends StatelessWidget {
  final GlobalKey key = GlobalKey();
  final String type;
  final double size;

  InfluencerBadge(this.type, this.size);

  Widget _checkMark(tooltip, color) {
    return Tooltip(
      key: key,
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          final dynamic tooltip = key.currentState;
          tooltip.ensureTooltipVisible();
        },
        child: Icon(
          GalupFont.certification,
          size: size,
          color: color,
        ),
      ),
    );
  }

  Widget _checkMarkAsset(tooltip, asset) {
    return Tooltip(
      key: key,
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          final dynamic tooltip = key.currentState;
          tooltip.ensureTooltipVisible();
        },
        child: Image.asset(
          asset,
          width: (size + 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'Política':
        return _checkMark(
          'Influencer Política',
          Color(0xFF191A1A),
        );
      case 'Conferencista':
        return _checkMark(
          'Influencer Conferencista',
          Color(0xFF9A0846),
        );
      case 'Coaching':
        return _checkMark(
          'Influencer Coaching',
          Color(0xFF582F1A),
        );
      case 'Celebrity':
        return _checkMark(
          'Influencer Celebrity',
          Color(0xFF56176F),
        );
      case 'Youtuber':
        return _checkMark(
          'Influencer Youtuber',
          Color(0xFF953935),
        );
      case 'Makeup':
        return _checkMark(
          'Influencer Makeup',
          Color(0xFFDB0064),
        );
      case 'Noticias':
        return _checkMark(
          'Influencer Noticias',
          Color(0xFF7B7D51),
        );
      case 'Foodie':
        return _checkMark(
          'Influencer Foodie',
          Color(0xFF761726),
        );
      case 'Traveler':
        return _checkMark(
          'Influencer Traveler',
          Color(0xFF009EBE),
        );
      case 'Gamer':
        return _checkMark(
          'Influencer Gamer',
          Color(0xFF68747A),
        );
      case 'Entretenimiento':
        return _checkMark(
          'Influencer Entretenimiento',
          Color(0xFFEE6B0A),
        );
      case 'Fashion':
        return _checkMark(
          'Influencer Fashion',
          Color(0xFFFFDA00),
        );
      case 'Espectáculos':
        return _checkMark(
          'Influencer Espectáculos',
          Color(0xFF0070BA),
        );
      case 'Healthy':
        return _checkMark(
          'Influencer Healthy',
          Color(0xFF399A32),
        );
      case 'Libre':
        return _checkMark(
          'Influencer Libre',
          Color(0xFFE1302F),
        );
      case 'Escritor':
        return _checkMark(
          'Influencer Escritor',
          Color(0xFFCDDE00),
        );
      case 'Emprendedor':
        return _checkMark(
          'Influencer Emprendedor',
          Color(0xFF8A84D6),
        );
      case 'Galup':
        return _checkMarkAsset(
          'Influencer Galup',
          'assets/badge.png',
        );
      default:
        return Container();
    }
  }
}
