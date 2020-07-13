import 'package:flutter/material.dart';

class Influencer {
  final String name;
  final int color;

  Influencer({@required this.name, @required this.color});

  static List<Influencer> influencerList = [
    Influencer(name: 'Política', color: 0xFF191A1A),
    Influencer(name: 'Conferencista', color: 0xFF9A0846),
    Influencer(name: 'Coaching', color: 0xFF582F1A),
    Influencer(name: 'Celebrity', color: 0xFF56176F),
    Influencer(name: 'Youtuber', color: 0xFF953935),
    Influencer(name: 'Makeup', color: 0xFFDB0064),
    Influencer(name: 'Noticias', color: 0xFF7B7D51),
    Influencer(name: 'Foodie', color: 0xFF761726),
    Influencer(name: 'Traveler', color: 0xFF009EBE),
    Influencer(name: 'Gamer', color: 0xFF68747A),
    Influencer(name: 'Entretenimiento', color: 0xFFEE6B0A),
    Influencer(name: 'Fashion', color: 0xFFFFDA00),
    Influencer(name: 'Espectáculos', color: 0xFF0070BA),
    Influencer(name: 'Healthy', color: 0xFF399A32),
    //TODO
    Influencer(name: 'Escritor', color: 0xFF009EBE),
    //TODO
    Influencer(name: 'Emprendedor', color: 0xFF009EBE),
    Influencer(name: 'Libre', color: 0xFFE1302F),
  ];
}
