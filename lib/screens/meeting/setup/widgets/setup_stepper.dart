import 'package:flutter/material.dart';
import 'package:meet/widgets/widgets.dart';

import 'meeting_setup.dart';
import 'order_setup.dart';
import 'timer_setup.dart';

class SetupStepper extends StatelessWidget {
  final VoidCallback onCompleted;

  const SetupStepper({
    Key key,
    this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = [
      EventSetup(),
      OrderSetup(),
      TimerSetup(),
    ];

    return PageStepper(
      steps: steps,
      onCompleted: onCompleted,
    );
  }
}
