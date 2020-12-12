import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet/routes.dart';
import 'package:meet/screens/meeting/meeting.dart';
import 'package:meet/widgets/widgets.dart';

import 'bloc.dart';
import 'widgets/widgets.dart';

class MeetingSetupScreen extends StatefulWidget {
  const MeetingSetupScreen({Key key}) : super(key: key);

  @override
  _MeetingSetupScreenState createState() => _MeetingSetupScreenState();
}

class _MeetingSetupScreenState extends State<MeetingSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MeetingSetupCubit(),
      child: AppLayout(builder: (context) {
        return SetupStepper(
          onCompleted: () {
            final event = context.bloc<MeetingSetupCubit>().state.meeting;
            context.bloc<MeetingSessionCubit>().startNewSession(event);
            Navigator.of(context).pushNamed(AppRouter.meetingSession);
          },
        );
      }),
    );
  }
}