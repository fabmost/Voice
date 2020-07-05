import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  
  void _signOut() {
    FirebaseAuth.instance.signOut();
  }
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          SizedBox(height: 52), 
          ListTile(
            onTap: _signOut,
            title: Text('Cerrar sesión'),
          )
        ],
      ),
    );
  }
}
