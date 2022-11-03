import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/events_timeline_listview.dart';
import 'package:iscte_spots/pages/timeline/list_view/intents.dart';
import 'package:iscte_spots/pages/timeline/list_view/year_timeline__listview.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class TimeLineBodyBuilder extends StatefulWidget {
  const TimeLineBodyBuilder({
    Key? key,
    required this.selectedYear,
    this.filteredEvents,
    this.yearsList,
    required this.handleYearSelection,
    required this.handleEventSelection,
  }) : super(key: key);

  final int selectedYear;
  final Future<List<int>>? yearsList;
  final List<Event>? filteredEvents;
  final void Function(int) handleYearSelection;
  final void Function(int) handleEventSelection;

  @override
  State<TimeLineBodyBuilder> createState() => _TimeLineBodyBuilderState();
}

class _TimeLineBodyBuilderState extends State<TimeLineBodyBuilder> {
  late Future<List<int>> stateYears;
  late Function(int) stateHandleYearSelection;
  late int stateSelectedYear;
  @override
  void initState() {
    super.initState();
    assert(widget.filteredEvents != null && widget.yearsList == null ||
        widget.filteredEvents == null && widget.yearsList != null);
    if (widget.filteredEvents != null) {
      stateYears = Future(() =>
          widget.filteredEvents!.map((e) => e.dateTime.year).toSet().toList());
    } else {
      stateYears = widget.yearsList!;
    }
    stateSelectedYear = widget.selectedYear;

    if (widget.filteredEvents != null) {
      stateHandleYearSelection = (int year) {
        setState(() {
          stateSelectedYear = year;
        });
      };
    } else {
      stateHandleYearSelection = widget.handleYearSelection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: stateYears,
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                  AppLocalizations.of(context)?.timelineNothingFound ?? ""),
            );
          } else {
            return TimelineBody(
              stateHandleYearSelection: stateHandleYearSelection,
              currentYear: stateSelectedYear,
              filteredEvents: widget.filteredEvents,
              handleEventSelection: widget.handleEventSelection,
              yearsList: snapshot.data!,
            );
          }
        } else if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingWidget();
        } else if (snapshot.hasError) {
          return Center(
              child: Text(AppLocalizations.of(context)!.generalError));
        } else {
          return const LoadingWidget();
        }
      },
    );
  }
}

class TimelineBody extends StatefulWidget {
  const TimelineBody({
    Key? key,
    required this.stateHandleYearSelection,
    required this.currentYear,
    this.filteredEvents,
    required this.handleEventSelection,
    required this.yearsList,
  }) : super(key: key);

  final Function(int p1) stateHandleYearSelection;
  final int currentYear;
  final List<Event>? filteredEvents;
  final void Function(int) handleEventSelection;
  final List<int> yearsList;

  @override
  State<TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<TimelineBody> {
  ValueNotifier<int?> selectedEventIndex = ValueNotifier(0);
  void changeSelectedEvent(int index) {
    Logger().d(
        "index: $index ; widget.filteredEvents?.length ${widget.filteredEvents}");
    if (index >= 0 && index < (widget.filteredEvents?.length ?? 0)) {
      selectedEventIndex.value = index;
    }
  }

  late ValueNotifier<int?> selectedYearIndex = ValueNotifier(null);

  void changeSelectedYear(int index) {
    if (index >= 0 && index < widget.yearsList.length) {
      selectedYearIndex.value = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowRight, includeRepeats: true):
            IncrementYearsIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft, includeRepeats: true):
            DecrementYearsIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown, includeRepeats: true):
            IncrementEventsIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp, includeRepeats: true):
            DecrementEventsIntent(),
        SingleActivator(LogicalKeyboardKey.enter): EnterIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): EnterIntent(),
        SingleActivator(LogicalKeyboardKey.space): EnterIntent(),
        SingleActivator(LogicalKeyboardKey.escape): EscapeIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          IncrementYearsIntent: CallbackAction<IncrementYearsIntent>(
            onInvoke: (IncrementYearsIntent intent) => changeSelectedYear(
                selectedYearIndex.value != null
                    ? selectedYearIndex.value! + 1
                    : widget.yearsList.indexOf(widget.currentYear)),
          ),
          DecrementYearsIntent: CallbackAction<DecrementYearsIntent>(
            onInvoke: (DecrementYearsIntent intent) => changeSelectedYear(
                selectedYearIndex.value != null
                    ? selectedYearIndex.value! - 1
                    : widget.yearsList.indexOf(widget.currentYear)),
          ),
          IncrementEventsIntent: CallbackAction<IncrementEventsIntent>(
            onInvoke: (IncrementEventsIntent intent) => changeSelectedEvent(
                selectedEventIndex.value != null
                    ? selectedEventIndex.value! + 1
                    : 0),
          ),
          DecrementEventsIntent: CallbackAction<DecrementEventsIntent>(
            onInvoke: (DecrementEventsIntent intent) => changeSelectedEvent(
                selectedEventIndex.value != null
                    ? selectedEventIndex.value! - 1
                    : 0),
          ),
          EnterIntent: CallbackAction<EnterIntent>(
              onInvoke: (EnterIntent intent) => Logger().d(
                  "selectedEventIndex: ${selectedEventIndex.value} ; selectedYearIndex: ${selectedYearIndex.value}")),
          EscapeIntent: CallbackAction<EscapeIntent>(
            onInvoke: (EscapeIntent intent) {
              selectedYearIndex.value = null;
              selectedEventIndex.value = null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(
              height: 100,
              child: YearTimelineListView(
                yearsList: widget.yearsList,
                changeYearFunction: widget.stateHandleYearSelection,
                currentYear: widget.currentYear,
                selectedYearIndex: selectedYearIndex,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: EventTimelineListViewBuilder(
                    key: UniqueKey(),
                    events: widget.filteredEvents,
                    timelineYear: widget.currentYear,
                    handleEventSelection: widget.handleEventSelection,
                    selectedEventIndex: selectedEventIndex,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
