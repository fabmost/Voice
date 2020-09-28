import 'package:flutter/material.dart';

import '../models/certificate_model.dart';

// ignore: must_be_immutable
class InfluencerBadge extends StatelessWidget {
  final String id;
  final CertificateModel certificate;
  final double size;

  InfluencerBadge(
    this.id,
    this.certificate,
    this.size,
  );

  @override
  Widget build(BuildContext context) {
    final mKey = new GlobalKey();
    return certificate == null
        ? Container()
        : Tooltip(
            key: mKey,
            message: 'Influencer ${certificate.description}',
            child: GestureDetector(
              onTap: () {
                final dynamic tooltip = mKey.currentState;
                tooltip.ensureTooltipVisible();
              },
              child: Image.network(
                certificate.icon,
                width: (size + 2),
              ),
            ),
          );
  }
}
