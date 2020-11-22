import 'package:calendar_service/calendar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:router_v2/router_v2.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'auth/auth.dart';
import 'blocs/blocs.dart';
import 'constants.dart';
import 'routes.dart';
import 'theme.dart';

class MeetApp extends StatefulWidget {
  final AuthRepository authRepository;
  final CalendarRepository calendarRepository;

  MeetApp({
    Key key,
    @required this.authRepository,
    @required this.calendarRepository,
  })  : assert(authRepository != null),
        super(key: key);

  @override
  _MeetAppState createState() => _MeetAppState();
}

class _MeetAppState extends State<MeetApp> {
  final AppRouterDelegate routerDelegate;
  final AppRouteInformationParser routerParser;

  _MeetAppState()
      : routerDelegate = AppRouterDelegate(routerConfig),
        routerParser = AppRouteInformationParser(routerConfig);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.calendarRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthBloc(authRepository: widget.authRepository),
        child: BlocProvider(
          create: (_) => AppBloc(),
          child: MaterialApp.router(
            title: kAppName,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              primarySwatch: KevlatusColors.mint,
              accentColor: KevlatusColors.coral,
            ),
            routerDelegate: routerDelegate,
            routeInformationParser: routerParser,
          ),
        ),
      ),
    );
  }
}