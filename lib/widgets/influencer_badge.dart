import 'package:flutter/material.dart';

import '../models/certificate_model.dart';

// ignore: must_be_immutable
class InfluencerBadge extends StatelessWidget {
  GlobalKey key;
  final String id;
  final CertificateModel certificate;
  final double size;

  InfluencerBadge(this.id, this.certificate, this.size) {
    key = GlobalObjectKey(this.id);
  }

  @override
  Widget build(BuildContext context) {
    return certificate == null
        ? Container()
        : Tooltip(
            key: key,
            message: 'Influencer ${certificate.description}',
            child: GestureDetector(
              onTap: () {
                final dynamic tooltip = key.currentState;
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
