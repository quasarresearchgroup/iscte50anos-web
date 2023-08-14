import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/feedback_form.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

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
  late Future<List<Topic>> availableTopicsFuture;
  late Future<List<EventScope>> availableScopesFuture;

  @override
  void initState() {
    super.initState();
    availableTopicsFuture = TimelineTopicService.fetchAllTopics();
    availableScopesFuture = Future(() => EventScope.values);
    isDialOpen = ValueNotifier<bool>(false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.timelineScreen,
        //title: "Cronologia 50 anos Iscte",
        leading: FutureBuilder<List<int>>(
            future: widget.yearsList,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => FeedbackForm(
                          yearsList: snapshot.data!,
                          selectedYear: widget.selectedYear,
                        ),
                      ),
                      icon: const Icon(Icons.feedback_outlined),
                    );
                  } else {
                    return LoadingWidget();
                  }
                default:
                  return LoadingWidget();
              }
            }),
        trailing: Hero(
          tag: "searchIcon",
          child: Builder(builder: (context) {
            return (!PlatformService.instance.isIos)
                ? IconButton(
                    onPressed: Scaffold.of(context).openEndDrawer,
                    icon: const Icon(Icons.search),
                  )
                : CupertinoButton(
                    onPressed: Scaffold.of(context).openEndDrawer,
                    child: const Icon(CupertinoIcons.search),
                  );
          }),
        ),
      ),
      endDrawer: Drawer(
        width: width > 400
            ? width > 500
                ? width > 600
                    ? width * 0.4
                    : width * 0.7
                : width * 0.8
            : width,
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
      persistentFooterButtons: (MediaQuery.of(context).size.height < 700)
          ? null
          : [
              Image.asset(
                "Resources/Img/Logo/rgb_iscte_pt_horizontal.png",
                height: kToolbarHeight + 25,
              )
            ],
    );
  }
}
