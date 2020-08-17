import 'dart:io';
import 'dart:ui' as ui;

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:voice_inc/translations.dart';

import '../custom/galup_font_icons.dart';
import '../providers/preferences_provider.dart';

import 'upgrade_screen.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';
import 'polls_screen.dart';
import 'search_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'new_poll_screen.dart';
import 'new_challenge_screen.dart';
import 'new_tip_screen.dart';
import 'new_cause_screen.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';

class MenuScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  static ScrollController _homeController = ScrollController();
  bool _triggeredOnboarding = false;
  bool _isOpen = false;
  bool _showBadge = false;
  Duration _duration = Duration(milliseconds: 300);
  AnimationController _iconAnimationCtrl;
  Animation<double> _iconAnimationTween;
  int _selectedPageIndex = 0;
  List<Widget> _pages = [
    PollsScreen(
      key: PageStorageKey('Page1'),
      homeController: _homeController,
      stopVideo: _playVideo,
    ),
    SearchScreen(
      key: PageStorageKey('Page2'),
      stopVideo: _playVideo,
    ),
    MessagesScreen(
      key: PageStorageKey('Page3'),
    ),
    ProfileScreen(
      key: PageStorageKey('Page4'),
      stopVideo: _playVideo,
    ),
  ];
  List<FabMenuItem> items = [];

  static VideoPlayerController _controller;

  static void _playVideo(VideoPlayerController controller) {
    _controller = controller;
  }

  void _selectPage(int index) {
    setState(() {
      if(_controller != null){
        _controller.pause();
      }
      if (_selectedPageIndex == index && index == 0) {
        _homeController.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
      _selectedPageIndex = index;
      if (index == 2) {
        _showBadge = false;
      }
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

  void _newPoll() async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert();
      return;
    }
    Navigator.of(context).pushNamed(NewPollScreen.routeName);
  }

  void _newChallenge() async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert();
      return;
    }
    Navigator.of(context).pushNamed(NewChallengeScreen.routeName);
  }

  void _newTip() async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert();
      return;
    }
    Navigator.of(context).pushNamed(NewTipScreen.routeName);
  }

  void _newCause() async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert();
      return;
    }
    Navigator.of(context).pushNamed(NewCauseScreen.routeName);
  }

  void _anonymousAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.of(context).text('dialog_need_account')),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.red,
            child: Text('Cancelar'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthScreen.routeName);
            },
            textColor: Theme.of(context).accentColor,
            child: Text('Crear cuenta'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    this.initDynamicLinks();
    _iconAnimationCtrl = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _iconAnimationTween = Tween(
      begin: 0.0,
      end: 0.875,
    ).animate(_iconAnimationCtrl);

    items = [
      FabMenuItem(
        icon: Icon(GalupFont.survey),
        label: 'Encuesta',
        ontap: _newPoll,
      ),
      FabMenuItem(
        icon: Icon(GalupFont.challenge),
        label: 'Reto',
        ontap: _newChallenge,
        color: Color(0xFFA4175D),
      ),
      FabMenuItem(
        icon: Icon(GalupFont.tips),
        label: 'Tip',
        ontap: _newTip,
        color: Color(0xFF00B2E3),
      ),
      FabMenuItem(
        icon: Icon(GalupFont.cause),
        label: 'Causa',
        ontap: _newCause,
        color: Colors.black,
      )
    ];

    final fm = FirebaseMessaging();
    fm.requestNotificationPermissions(
      IosNotificationSettings(
        alert: true,
        sound: true,
        badge: true,
      ),
    );
    fm.configure(onMessage: (msg) {
      print(msg);
      Map data = msg['data'] ?? msg;
      if (_selectedPageIndex != 2 && data['type'] == 'chat') {
        setState(() {
          _showBadge = true;
        });
      }
      Platform.isAndroid
          ? showNotification(msg['notification'])
          : showNotification(msg['aps']['alert']);
      return;
    }, onLaunch: (msg) {
      //showAlert(msg);
      Map data = msg['data'] ?? msg;
      if (data['type'] == 'chat') {
        Navigator.of(context).pushNamed(ChatScreen.routeName,
            arguments: {'chatId': data['id'], 'userId': data['sender']});
      } else {
        Navigator.of(context).pushNamed(NotificationsScreen.routeName);
      }
      return;
    }, onResume: (msg) {
      //showAlert(msg);
      Map data = msg['data'] ?? msg;
      if (data['type'] == 'chat') {
        Navigator.of(context).pushNamed(ChatScreen.routeName,
            arguments: {'chatId': data['id'], 'userId': data['sender']});
      } else {
        Navigator.of(context).pushNamed(NotificationsScreen.routeName);
      }
      return;
    });
    fm.subscribeToTopic('cause');
    FirebaseAuth.instance.currentUser().then((value) {
      fm.getToken().then((token) {
        print('token: $token');
        Firestore.instance
            .collection('users')
            .document(value.uid)
            .updateData({'pushToken': token});
      });
    });

    _checkVersion();
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) _controller.dispose();
  }

  void _checkVersion() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    // Enable developer mode to relax fetch throttling
    remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: false));
    remoteConfig.setDefaults(<String, dynamic>{
      'app_version': 0,
    });
    await remoteConfig.fetch();
    await remoteConfig.activateFetched();

    final remoteVersion = remoteConfig.getDouble('app_version');
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      if (remoteVersion > double.parse(packageInfo.buildNumber)) {
        Navigator.of(context).popAndPushNamed(UpgradeScreen.routeName);
      }
    });
  }

  void showAlert(msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(msg.toString()),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }

  void showNotification(message) async {
    /*
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
    Platform.isAndroid ? 'com.dfa.flutterchatdemo' : 'com.duytq.flutterchatdemo',
    'Flutter chat demo',
    'your channel description',
    playSound: true,
    enableVibration: true,
    importance: Importance.Max,
    priority: Priority.High,
  );
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics =
  new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
      payload: json.encode(message));
      */
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
            backgroundColor: item.color,
            onPressed: onTap,
            mini: true,
            child: item.icon,
            elevation: 0,
          ),
        ],
      ),
    );
  }

  void _checkIfOnboarding() async {
    final bool result =
        await Provider.of<Preferences>(context, listen: false).getFirstTime();
    if (result && !_triggeredOnboarding) {
      _triggeredOnboarding = true;
      Navigator.of(context).pushNamed(OnboardingScreen.routeName);
    }
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, '/${deepLink.pathSegments[0]}',
          arguments: deepLink.pathSegments[1]);
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        Navigator.pushNamed(context, '/${deepLink.pathSegments[0]}',
            arguments: deepLink.pathSegments[1]);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    _checkIfOnboarding();
    return Scaffold(
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            IndexedStack(
              index: _selectedPageIndex,
              children: _pages,
            ),
            _isOpen ? _buildBlurWidget() : Container(),
            _isOpen ? _buildMenuItemList() : Container(),
          ],
        ),
        onWillPop: _preventPopIfOpen,
      ),
      floatingActionButton: FloatingActionButton(
        child: RotationTransition(
          turns: _iconAnimationTween,
          child: Icon(Icons.add),
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
                GalupFont.home,
                color: _selectedPageIndex == 0 ? Colors.black : Colors.grey,
              ),
              onPressed: () => _selectPage(0),
            ),
            IconButton(
              icon: Icon(
                GalupFont.search,
                color: _selectedPageIndex == 1 ? Colors.black : Colors.grey,
              ),
              onPressed: () => _selectPage(1),
            ),
            Text(''),
            Badge(
              showBadge: _showBadge,
              badgeContent: Text(
                '',
                style: TextStyle(color: Colors.white),
              ),
              position: BadgePosition(top: -5, right: 0),
              child: IconButton(
                icon: Icon(
                  GalupFont.message_select,
                  color: _selectedPageIndex == 2 ? Colors.black : Colors.grey,
                ),
                onPressed: () => _selectPage(2),
              ),
            ),
            IconButton(
              icon: Icon(
                GalupFont.profile,
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
  Color color;
  Function ontap;
  FabMenuItem({
    @required this.label,
    @required this.ontap,
    @required this.icon,
    this.color,
  });
}
