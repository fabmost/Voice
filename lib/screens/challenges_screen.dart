import 'package:flutter/material.dart';

import '../widgets/appbar.dart';

class ChallengesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Text('Retos'),
      ),
    );
  }
}
