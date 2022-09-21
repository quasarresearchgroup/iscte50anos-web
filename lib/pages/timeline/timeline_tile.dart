import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/datetime_extension.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventTimelineTile extends StatefulWidget {
  const EventTimelineTile({
    Key? key,
    required this.lineStyle,
    required this.isFirst,
    required this.isLast,
    required this.event,
    required this.isEven,
    required this.index,
    required this.handleEventSelection,
  }) : super(key: key);

  final int index;
  final bool isFirst;
  final bool isLast;
  final bool isEven;
  final Event event;
  final LineStyle lineStyle;
  final void Function(int) handleEventSelection;

  @override
  State<EventTimelineTile> createState() => _EventTimelineTileState();
}

class _EventTimelineTileState extends State<EventTimelineTile> {
  final Color color2 = Colors.white.withOpacity(0.3);
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(milliseconds: 100 * (widget.index + 1)),
      () {
        setState(() {
          opacity = 1;
        });
      },
    ).onError((error, stackTrace) => null);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return InkWell(
        splashColor: color2,
        highlightColor: color2,
        enableFeedback: true,
        customBorder: const StadiumBorder(),
        onTap: () async {
          setState(() {
            widget.event.visited = true;
          });
          widget.handleEventSelection(widget.event.id);
          /* Navigator.pushNamed(
              context,
              "${TimeLineDetailsPage.pageRoute}/${widget.data.id}",
            );*/
        },
        child: TimelineTile(
          beforeLineStyle: widget.lineStyle,
          afterLineStyle: widget.lineStyle,
          axis: TimelineAxis.vertical,
          alignment: TimelineAlign.manual,
          lineXY: 0.30,
          isFirst: widget.isFirst,
          isLast: widget.isLast,
          indicatorStyle: IndicatorStyle(
            width: MediaQuery.of(context).size.width * 0.08,
            height: MediaQuery.of(context).size.width * 0.1,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            indicator: Container(
              decoration: BoxDecoration(
                color: !widget.isEven
                    ? Colors.transparent
                    : Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          widget.event.dateTime.monthName(),
                          style: TextStyle(
                            color: widget.isEven ? Colors.white : null,
                          ),
                          textScaleFactor: 1,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          widget.event.dateTime.day.toString(),
                          style: TextStyle(
                            color: widget.isEven ? Colors.white : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          endChild: TimelineInformationChild(
              isEven: widget.isEven, data: widget.event),
          startChild: Padding(
            padding:
                EdgeInsets.all(orientation == Orientation.landscape ? 20 : 0),
            child: Center(child: widget.event.scopeIcon),
          ),
        ),
      );
    });
  }
}

class TimelineInformationChild extends StatelessWidget {
  const TimelineInformationChild({
    Key? key,
    required this.isEven,
    required this.data,
  }) : super(key: key);

  final bool isEven;
  final Event data;
  final double padding = 20;

  @override
  Widget build(BuildContext context) {
    Color? textColor = !isEven ? Colors.white : null;
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        decoration: BoxDecoration(
          color: isEven ? Colors.transparent : Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Text(
                  data.title,
                  maxLines: 3,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: textColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.adaptive.arrow_forward,
                    color: textColor,
                  ),
                  data.visited
                      ? Icon(Icons.check, color: textColor)
                      //? const Icon(Icons.check, color: Colors.lightGreenAccent)
                      : Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
