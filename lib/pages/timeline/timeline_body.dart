import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/list_view/events_timeline_listview.dart';
import 'package:iscte_spots/pages/timeline/list_view/year_timeline__listview.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

class TimeLineBody extends StatefulWidget {
  const TimeLineBody({
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
  State<TimeLineBody> createState() => _TimeLineBodyState();
}

class _TimeLineBodyState extends State<TimeLineBody> {
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
            return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 15.0,
                      )
                    ]),
                    child: YearTimelineListView(
                      yearsList: snapshot.data!,
                      changeYearFunction: stateHandleYearSelection,
                      selectedYear: stateSelectedYear,
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: EventTimelineListView(
                        key: UniqueKey(),
                        events: widget.filteredEvents,
                        timelineYear: stateSelectedYear,
                        handleEventSelection: widget.handleEventSelection,
                      ),
                    ),
                  ),
                ]);
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
