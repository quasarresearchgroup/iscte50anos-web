import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:logger/logger.dart';

import '../../services/timeline/timeline_topic_service.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({
    Key? key,
    required this.selectedYear,
    required this.yearsList,
    required this.handleEventSelection,
    required this.handleYearSelection,
    //required this.handleFilterNavigation,
    required this.filteredEvents,
    required this.handleFilterSubmission,
  }) : super(key: key);
  final Logger _logger = Logger();
  final Function(int) handleEventSelection;
  final Function(int) handleYearSelection;
  //final Function() handleFilterNavigation;
  void Function(TimelineFilterParams filters, bool showResults)
      handleFilterSubmission;
  static const String pageRoute = "timeline";
  static const ValueKey pageKey = ValueKey(pageRoute);
  final int selectedYear;
  final List<Event> filteredEvents;
  final Future<List<int>> yearsList;

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late ValueNotifier<bool> isDialOpen;
  Future<List<Topic>> availableTopicsFuture =
      TimelineTopicService.fetchAllTopics();
  Future<List<EventScope>> availableScopesFuture =
      Future(() => EventScope.values);

  @override
  void initState() {
    super.initState();
    isDialOpen = ValueNotifier<bool>(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        //title: AppLocalizations.of(context)!.timelineScreen,
        title: "Cronologia 50 anos Iscte",
        trailing: (!PlatformService.instance.isIos)
            ? Builder(builder: (context) {
                return IconButton(
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  icon: const Icon(Icons.search),
                );
              })
            : Builder(builder: (context) {
                return CupertinoButton(
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  child: const Icon(CupertinoIcons.search),
                );
              }),
      ),
      /*floatingActionButton: TimelineDial(
              isDialOpen: isDialOpen,
              deleteTimelineData: deleteTimelineData,
              refreshTimelineData: deleteGetAllEvents,
            ),*/

      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        child: TimelineFilterPage(
          handleEventSelection: widget.handleEventSelection,
          handleYearSelection: widget.handleYearSelection,
          handleFilterSubmission: widget.handleFilterSubmission,
          yearsList: widget.yearsList,
          availableTopics: availableTopicsFuture,
          availableScopes: availableScopesFuture,
        ),
      ),
      body: TimeLineBodyBuilder(
        handleEventSelection: widget.handleEventSelection,
        handleYearSelection: widget.handleYearSelection,
        selectedYear: widget.selectedYear,
        yearsList: widget.yearsList,
        filteredEvents: widget.filteredEvents,
        isFilterTimeline: false,
      ),
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
      persistentFooterButtons: [
        Image.asset(
          "Resources/Img/Logo/rgb_iscte_pt_horizontal.png",
          height: kToolbarHeight + 25,
        )
      ],
    );
  }
}
