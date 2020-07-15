import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;

  Category({@required this.name, @required this.icon});

  static List<Category> categoriesList = [
    Category(name: 'Salud', icon: Icons.ac_unit),
    Category(name: 'Belleza', icon: Icons.access_alarms),
    Category(name: 'Tecnología', icon: Icons.backspace),
    Category(name: 'Entretenimiento', icon: Icons.speaker_group),
    Category(name: 'Deportes', icon: Icons.settings_power),
    Category(name: 'Comedia', icon: Icons.comment),
    Category(name: 'Negocios', icon: Icons.business),
    Category(name: 'Emprendimiento', icon: Icons.business),
    Category(name: 'Política', icon: Icons.photo_library),
    Category(name: 'Estilo de vida', icon: Icons.style),
    Category(name: 'Espectáculos', icon: Icons.speaker),
    Category(name: 'Celebridades', icon: Icons.clear),
    Category(name: 'Videojuegos', icon: Icons.games),
    Category(name: 'Animales', icon: Icons.airplanemode_active),
    Category(name: 'Gastronomía', icon: Icons.folder_open),
    Category(name: 'Talento', icon: Icons.tab),
    Category(name: 'Amor', icon: Icons.local_activity),
    Category(name: 'Familia', icon: Icons.fast_forward),
    Category(name: 'Educación', icon: Icons.book),
    Category(name: 'Motores', icon: Icons.card_giftcard),
    Category(name: 'Manualidades', icon: Icons.hdr_weak),
    Category(name: 'Actividades al aire libre', icon: Icons.warning),
    Category(name: 'Superación personal', icon: Icons.hd),
    Category(name: 'Noticias', icon: Icons.edit),
    Category(name: 'Hogar', icon: Icons.face),
    Category(name: 'Hobby', icon: Icons.hot_tub),
    Category(name: 'Viajes', icon: Icons.view_agenda),
  ];
}
