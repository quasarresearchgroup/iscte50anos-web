import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/timeline/web_scroll_behaviour.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:timeline_tile/timeline_tile.dart';

class YearTimelineListView extends StatefulWidget {
  const YearTimelineListView({
    Key? key,
    required this.changeYearFunction,
    required this.yearsList,
    required this.currentYear,
    required this.selectedYearIndex,
  }) : super(key: key);

  final Function(int) changeYearFunction;
  final List<int> yearsList;
  final int currentYear;
  final ValueNotifier<int?> selectedYearIndex;

  @override
  State<YearTimelineListView> createState() => _YearTimelineListViewState();
}

class _YearTimelineListViewState extends State<YearTimelineListView> {
  final ItemScrollController itemController = ItemScrollController();
  final List<Widget> yearsList = [];

  @override
  void initState() {
    super.initState();
    widget.selectedYearIndex.addListener(() {
      itemController.scrollTo(
          index: widget.selectedYearIndex.value ?? widget.currentYear,
          duration: Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
        valueListenable: widget.selectedYearIndex,
        builder: (context, value, _) {
          return ScrollConfiguration(
            behavior: WebScrollBehaviour(),
            child: ScrollablePositionedList.builder(
                initialScrollIndex:
                    widget.yearsList.indexOf(widget.currentYear),
                itemScrollController: itemController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.yearsList.length,
                shrinkWrap: false,
                itemBuilder: (
                  BuildContext context,
                  int index,
                ) {
                  var tile = YearTimelineTile(
                    // key: itemKey,
                    changeYearFunction: widget.changeYearFunction,
                    year: widget.yearsList[index],
                    isSelected: widget.currentYear == widget.yearsList[index],
                    isFirst: index == 0,
                    isLast: index == widget.yearsList.length - 1,
                  );
                  return Padding(
                      // key: itemKey,
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: value == index
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border:
                                    Border.all(color: IscteTheme.iscteColor),
                              ),
                              child: tile,
                            )
                          : tile);
                }),
          );
        });
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
