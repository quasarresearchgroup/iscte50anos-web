import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/timeline/web_scroll_behaviour.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:timeline_tile/timeline_tile.dart';

class YearTimelineListView extends StatefulWidget {
  const YearTimelineListView(
      {Key? key,
      required this.changeYearFunction,
      required this.yearsList,
      required this.selectedYear})
      : super(key: key);

  final Function(int) changeYearFunction;
  final List<int> yearsList;
  final int selectedYear;

  @override
  State<YearTimelineListView> createState() => _YearTimelineListViewState();
}

class _YearTimelineListViewState extends State<YearTimelineListView> {
  final ItemScrollController itemController = ItemScrollController();
  List<Widget> yearsList = [];

  @override
  void initState() {
    super.initState();
    //if (itemController.isAttached) {
    /*WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Logger().d(
            "index:${widget.yearsList.indexOf(widget.selectedYear)}\nselectedYear:${widget.selectedYear}");
        itemController.scrollTo(
          index: widget.yearsList.indexOf(widget.selectedYear),
          duration: const Duration(milliseconds: 50),
        );
      },
    );*/
    //}
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: WebScrollBehaviour(),
      child: ScrollablePositionedList.builder(
          initialScrollIndex: widget.yearsList.indexOf(widget.selectedYear),
          itemScrollController: itemController,
          scrollDirection: Axis.horizontal,
          itemCount: widget.yearsList.length,
          shrinkWrap: false,
          itemBuilder: (
            BuildContext context,
            int index,
          ) {
            return Padding(
              // key: itemKey,
              padding: const EdgeInsets.only(bottom: 8.0),
              child: YearTimelineTile(
                // key: itemKey,
                changeYearFunction: widget.changeYearFunction,
                year: widget.yearsList[index],
                isSelected: widget.selectedYear == widget.yearsList[index],
                isFirst: index == 0,
                isLast: index == widget.yearsList.length - 1,
              ),
            );
          }),
    );
  }
}

class YearTimelineTile extends StatefulWidget {
  const YearTimelineTile({
    Key? key,
    required this.changeYearFunction,
    required this.year,
    required this.isFirst,
    required this.isLast,
    required this.isSelected,
  }) : super(key: key);

  final Function changeYearFunction;
  final int year;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;

  @override
  State<YearTimelineTile> createState() => _YearTimelineTileState();
}

class _YearTimelineTileState extends State<YearTimelineTile> {
  @override
  Widget build(BuildContext context) {
    const double textFontSize = 20.0;
    const double minWidth2 = 90;
    const double radius = 15;
    //final Color color2 = Colors.white.withOpacity(0.3);
    const double timelineIconOffset = 0.7;
    LineStyle lineStyle = LineStyle(
        color: Theme.of(context).iconTheme.color ?? Colors.black, thickness: 6);

    return InkWell(
      //splashColor: color2,
      //highlightColor: color2,
      enableFeedback: true,
      customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius))),
      onTap: () {
        setState(() {
          widget.changeYearFunction(widget.year);
        });
      },
      child: TimelineTile(
        beforeLineStyle: lineStyle,
        afterLineStyle: lineStyle,
        axis: TimelineAxis.horizontal,
        alignment: TimelineAlign.manual,
        lineXY: timelineIconOffset,
        isFirst: widget.isFirst,
        isLast: widget.isLast,
        hasIndicator: true,
        indicatorStyle: IndicatorStyle(
          drawGap: true,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          indicator: Center(
            child: Icon(
              widget.isSelected
                  ? FontAwesomeIcons.calendarCheck
                  : FontAwesomeIcons.calendar,
            ),
          ),
        ),
        startChild: Container(
          constraints: const BoxConstraints(minWidth: minWidth2),
          child: Center(
            child: Text(
              widget.year.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).iconTheme.color,
                  ),
            ),
          ),
        ),
        //),
      ),
    );
  }
}
