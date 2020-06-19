import 'dart:ui' as ui;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'polls_screen.dart';
import 'search_screen.dart';
import 'challenges_screen.dart';
import 'messages_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  bool _isOpen = false;
  Duration _duration = Duration(milliseconds: 300);
  AnimationController _iconAnimationCtrl;
  Animation<double> _iconAnimationTween;
  int _selectedPageIndex = 0;
  List<Widget> _pages = [
    PollsScreen(),
    SearchScreen(),
    ChallengesScreen(),
    MessagesScreen(),
  ];
  final List<FabMenuItem> items = [
    FabMenuItem(
      icon: Icon(Icons.home),
      label: 'Encuesta',
      ontap: () {},
    ),
    FabMenuItem(
      icon: Icon(Icons.local_florist),
      label: 'Reto',
      ontap: () {},
    ),
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _toggleOpen() {
    setState(() {
      _isOpen = !_isOpen;
    });
    if (_isOpen) {
      _iconAnimationCtrl.forward();
    } else {
      _iconAnimationCtrl.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _iconAnimationCtrl = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _iconAnimationTween = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_iconAnimationCtrl);
    
    final fm = FirebaseMessaging();
    fm.requestNotificationPermissions();
    fm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
    fm.subscribeToTopic('polls');
  }

  Future<bool> _preventPopIfOpen() async {
    if (_isOpen) {
      _toggleOpen();
      return false;
    }
    return true;
  }

  Widget _buildBlurWidget() {
    return InkWell(
      onTap: _toggleOpen,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 5.0,
        ),
        child: Container(
          color: Colors.black12,
        ),
      ),
    );
  }

  Widget _buildMenuItemList() {
    double width = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: 20,
      right: (width / 2) - 25,
      child: ScaleTransition(
        scale: AnimationController(
          vsync: this,
          value: 0.7,
          duration: _duration,
        )..forward(),
        child: SizeTransition(
          axis: Axis.vertical,
          sizeFactor: AnimationController(
            vsync: this,
            value: 0.5,
            duration: _duration,
          )..forward(),
          child: FadeTransition(
            opacity: AnimationController(
              vsync: this,
              value: 0.0,
              duration: _duration,
            )..forward(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  items.map<Widget>((item) => _buildMenuItem(item)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(FabMenuItem item) {
    var onTap = () {
      _toggleOpen();
      item.ontap();
    };
    return InkWell(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Text(item.label),
          ),
          FloatingActionButton(
            onPressed: onTap,
            mini: true,
            child: item.icon,
            elevation: 0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            _pages[_selectedPageIndex],
            _isOpen ? _buildBlurWidget() : Container(),
            _isOpen ? _buildMenuItemList() : Container(),
          ],
        ),
        onWillPop: _preventPopIfOpen,
      ),
      floatingActionButton: FloatingActionButton(
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _iconAnimationTween,
        ),
        mini: true,
        elevation: 0,
        onPressed: _toggleOpen,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home,
                color: _selectedPageIndex == 0 ? Colors.black : Colors.grey,
              ),
              onPressed: () => _selectPage(0),
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: _selectedPageIndex == 1 ? Colors.black : Colors.grey,
              ),
              onPressed: () => _selectPage(1),
            ),
            Text(''),
            IconButton(
              icon: Icon(
                Icons.local_florist,
                color: _selectedPageIndex == 2 ? Colors.black : Colors.grey,
              ),
              onPressed: () => _selectPage(2),
            ),
            IconButton(
              icon: Icon(
                Icons.message,
                color: _selectedPageIndex == 3 ? Colors.black : Colors.grey,
              ),
              onPressed: () => _selectPage(3),
            ),
          ],
        ),
      ),
    );
  }
}

class FabMenuItem {
  String label;
  Icon icon;
  Function ontap;
  FabMenuItem({
    @required this.label,
    @required this.ontap,
    @required this.icon,
  });
}
