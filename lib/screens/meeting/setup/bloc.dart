import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meet/models/models.dart';
import 'package:meet/timer/timer.dart';
import 'package:meta/meta.dart';

const List<String> _denyList = <String>[
  'Organisator',
  'Organizer',
];

@immutable
abstract class SetupHint extends Equatable {
  final int step;

  const SetupHint({
    this.step,
  });
}

abstract class InvalidNameHint extends SetupHint {
  String get name;
}

class DenyListHint extends SetupHint implements InvalidNameHint {
  final String name;

  const DenyListHint({
    @required this.name,
    int step,
  }) : super(step: step);

  @override
  List<Object> get props => [step, name];
}

class DuplicateHint extends SetupHint implements InvalidNameHint {
  final String name;

  const DuplicateHint({
    @required this.name,
    int step,
  }) : super(step: step);

  @override
  List<Object> get props => [step, name];
}

@immutable
class MeetingSetupState extends Equatable {
  final Meeting meeting;
  final OrderStrategy orderStrategy;
  final TimerStrategy timerStrategy;
  final List<SetupHint> hints;

  const MeetingSetupState({
    this.meeting = const Meeting(),
    this.hints = const <SetupHint>[],
    this.orderStrategy = const OrderStrategy.random(),
    this.timerStrategy = const NoTimerStrategy(),
  });

  Iterable<T> getHintsByType<T extends SetupHint>() => hints.whereType<T>();

  bool hasHint<T extends SetupHint>() => getHintsByType<T>().isNotEmpty;

  MeetingSetupState copyWith({
    Meeting meeting,
    List<SetupHint> hints,
    OrderStrategy orderStrategy,
    TimerStrategy timerStrategy,
  }) =>
      MeetingSetupState(
        meeting: meeting ?? this.meeting,
        hints: hints ?? this.hints,
        orderStrategy: orderStrategy ?? this.orderStrategy,
        timerStrategy: timerStrategy ?? this.timerStrategy,
      );

  @override
  List<Object> get props => [meeting, hints, orderStrategy, timerStrategy];
}

class MeetingSetupCubit extends Cubit<MeetingSetupState> {
  MeetingSetupCubit() : super(MeetingSetupState());

  void addHints(List<SetupHint> hints) {
    emit(state.copyWith(hints: [
      ...state.hints,
      ...hints,
    ]));
  }

  void dismissHints(Iterable<SetupHint> hints) {
    emit(state.copyWith(
      hints: [
        for (var it in state.hints)
          if (!hints.contains(it)) it
      ],
    ));
  }

  void changeOrderStrategy(OrderStrategy strategy) {
    emit(state.copyWith(orderStrategy: strategy));
  }

  void changeTimerStrategy(TimerStrategy strategy) {
    emit(state.copyWith(timerStrategy: strategy));
  }

  void updateAttendees(Iterable<String> attendees) {
    emit(
      state.copyWith(
        meeting: state.meeting.copyWith(
          attendees: attendees.toList(),
        ),
      ),
    );
  }

  void removeAttendees(Iterable<String> toBeDeleted, {bool keepFirst = false}) {
    Iterable<String> update;
    if (!keepFirst) {
      update = state.meeting.attendees.where((it) => !toBeDeleted.contains(it));
    } else {
      update = <String>[
        for (var entry in state.meeting.attendees.asMap().entries)
          if (!toBeDeleted.contains(entry.value))
            entry.value
          else if (state.meeting.attendees
              .sublist(0, entry.key)
              .where((it) => toBeDeleted.contains(it))
              .isEmpty)
            entry.value
      ];
    }
    updateAttendees(update);
  }

  void addAttendees(Iterable<String> attendees) {
    final newAttendees = <String>[
      ...(state.meeting?.attendees ?? []),
      ...attendees,
    ];

    final newHints = <SetupHint>[];
    final deniedItems = attendees.where((it) => _denyList.contains(it));
    if (deniedItems.isNotEmpty) {
      newHints.addAll([
        for (var it in deniedItems) DenyListHint(name: it),
      ]);
    }

    final duplicates = [
      for (var entry in newAttendees.asMap().entries)
        if (newAttendees.sublist(entry.key + 1).contains(entry.value))
          entry.value
    ];
    if (duplicates.isNotEmpty) {
      newHints.addAll([
        for (var it in duplicates) DuplicateHint(name: it),
      ]);
    }

    emit(
      state.copyWith(
        meeting: state.meeting.copyWith(attendees: newAttendees),
        hints: [
          ...state.hints,
          ...newHints,
        ],
      ),
    );
  }
}
