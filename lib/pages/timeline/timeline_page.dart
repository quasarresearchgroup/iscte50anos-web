import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({
    Key? key,
    this.futureEventsList,
    this.selectedYear,
    required this.handleEventSelection,
    required this.handleFilterNavigation,
  }) : super(key: key);
  final Logger _logger = Logger();
  final Function(int) handleEventSelection;
  final Function() handleFilterNavigation;
  static const String pageRoute = "timeline";
  static const ValueKey pageKey = ValueKey(pageRoute);
  final Future<List<Event>>? futureEventsList;
  final int? selectedYear;

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late Future<List<Event>> mapdata;
  late ValueNotifier<bool> isDialOpen;

  @override
  void initState() {
    super.initState();
    if (widget.futureEventsList != null) {
      mapdata = widget.futureEventsList!;
    } else {
      resetMapData();
    }
    isDialOpen = ValueNotifier<bool>(false);
  }

  Future<void> resetMapData() async {
    setState(() {
      mapdata = TimelineEventService.fetchAllEvents();
    });
    var list = await mapdata;
    //FlutterNativeSplash.remove();
    if (list.isEmpty) {
      deleteGetAllEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget scaffold = FutureBuilder<List<Event>>(
        future: mapdata,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: MyAppBar(
              title: AppLocalizations.of(context)!.timelineScreen,
              trailing: (!PlatformService.instance.isIos)
                  ? IconButton(
                      onPressed: () {
                        widget.handleFilterNavigation();
                        /*Navigator.of(context).pushNamed(
                            TimelineFilterPage.pageRoute,
                            arguments: snapshot.data);
                      */
                      },
                      icon: const Icon(Icons.search),
                    )
                  : CupertinoButton(
                      child: const Icon(
                        CupertinoIcons.search,
                        color: CupertinoColors.white,
                      ),
                      //color: CupertinoTheme.of(context).primaryContrastingColor,
                      onPressed: () {
                        widget.handleFilterNavigation();
                        /*                 Navigator.of(context).pushNamed(
                            TimelineFilterPage.pageRoute,
                            arguments: snapshot.data);
        */
                      },
                    ),
            ),
            /*floatingActionButton: TimelineDial(
              isDialOpen: isDialOpen,
              deleteTimelineData: deleteTimelineData,
              refreshTimelineData: deleteGetAllEvents,
            ),*/
            body: RefreshIndicator(
              onRefresh: deleteGetAllEvents,
              child: Builder(
                builder: (context) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isNotEmpty) {
                      return TimeLineBody(
                          mapdata: snapshot.data!,
                          handleEventSelection: widget.handleEventSelection);
                    } else {
                      return Center(
                        child: Text(
                            AppLocalizations.of(context)!.timelineNothingFound),
                      );
                    }
                  } else if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingWidget();
                  } else if (snapshot.hasError) {
                    return Center(
                        child:
                            Text(AppLocalizations.of(context)!.generalError));
                  } else {
                    return const LoadingWidget();
                  }
                },
              ),
            ),
          );
        });

    return PlatformService.instance.isIos
        ? scaffold
        : Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: Theme.of(context)
                  .appBarTheme
                  .copyWith(shape: const ContinuousRectangleBorder()),
            ),
            child: scaffold,
          );
  }

  Future<void> deleteGetAllEvents() async {
    await deleteTimelineData();
    Future<List<Event>> events = TimelineEventService.fetchAllEvents();

    setState(() {
      mapdata = events;
    });
    widget._logger.i("Updated Timeline events future!");
  }

  Future<void> deleteTimelineData() async {
    widget._logger.d("Removed all content, events and topics from db");
    setState(() {
      mapdata = Future.delayed(
        const Duration(seconds: 2),
        () => [],
      );
    });
  }
}
