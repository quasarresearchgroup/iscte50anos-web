import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:logger/logger.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({
    Key? key,
    required this.selectedYear,
    required this.yearsList,
    required this.handleEventSelection,
    required this.handleYearSelection,
    required this.handleFilterNavigation,
  }) : super(key: key);
  final Logger _logger = Logger();
  final Function(int) handleEventSelection;
  final Function(int) handleYearSelection;
  final Function() handleFilterNavigation;
  static const String pageRoute = "timeline";
  static const ValueKey pageKey = ValueKey(pageRoute);
  final int selectedYear;
  final Future<List<int>> yearsList;

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late ValueNotifier<bool> isDialOpen;

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
            ? IconButton(
                onPressed: widget.handleFilterNavigation,
                icon: const Icon(Icons.search),
              )
            : CupertinoButton(
                onPressed: widget.handleFilterNavigation,
                child: const Icon(CupertinoIcons.search),
              ),
      ),
      /*floatingActionButton: TimelineDial(
              isDialOpen: isDialOpen,
              deleteTimelineData: deleteTimelineData,
              refreshTimelineData: deleteGetAllEvents,
            ),*/
      body: TimeLineBodyBuilder(
        handleEventSelection: widget.handleEventSelection,
        selectedYear: widget.selectedYear,
        handleYearSelection: widget.handleYearSelection,
        yearsList: widget.yearsList,
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
