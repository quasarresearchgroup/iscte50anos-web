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
    required this.index,
    required this.handleEventSelection,
  }) : super(key: key);

  final int index;
  final bool isFirst;
  final bool isLast;
  final Event event;
  final LineStyle lineStyle;
  final void Function(int) handleEventSelection;

  @override
  State<EventTimelineTile> createState() => _EventTimelineTileState();
}

class _EventTimelineTileState extends State<EventTimelineTile> {
  final Color color2 = Colors.white.withOpacity(0.3);
  late bool isEven;

  @override
  void initState() {
    super.initState();
    isEven = widget.index % 2 == 0;
  }

  @override
  Widget build(BuildContext context) {
    Widget sizedBox = const SizedBox(
      width: 10,
    );

    Widget verticalConnector = Expanded(
      child: Container(
        width: 5,
        color: Colors.white,
      ),
    );

    return SizedBox(
      height: 100,
      child: InkWell(
        onTap: widget.event.contentCount > 0
            ? () {
                widget.handleEventSelection(widget.event.id);
              }
            : null,
        child: Card(
          margin: EdgeInsets.zero,
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.event.scopeIcon != null)
                SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: widget.event.scopeIcon!,
                    )),
              sizedBox,
              SizedBox(
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    !widget.isFirst ? verticalConnector : const Spacer(),
                    EventTimelineIndicator(isEven: isEven, event: widget.event),
                    !widget.isLast ? verticalConnector : const Spacer(),
                  ],
                ),
              ),
              sizedBox,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TimelineInformationChild(
                      isEven: isEven, data: widget.event),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventTimelineIndicator extends StatelessWidget {
  const EventTimelineIndicator({
    Key? key,
    required this.isEven,
    required this.event,
  }) : super(key: key);

  final bool isEven;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isEven ? Colors.transparent : Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              event.dateTime.monthName(),
              style: TextStyle(
                color: isEven ? Colors.white : null,
              ),
              textScaleFactor: 1,
              maxLines: 1,
            ),
            Text(
              event.dateTime.day.toString(),
              style: TextStyle(
                color: isEven ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
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
  final double padding = 10;

  @override
  Widget build(BuildContext context) {
    Color? textColor = !isEven ? Colors.white : null;
    return Container(
      decoration: BoxDecoration(
        color: !isEven ? Colors.transparent : Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                data.title,
                maxLines: 3,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  //fontSize: MediaQuery.of(context).size.width * 0.05,
                  color: textColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (data.contentCount > 0)
                    Icon(
                      Icons.adaptive.arrow_forward,
                      color: textColor,
                    ),
                  if (data.contentCount > 0)
                    data.visited
                        ? Icon(Icons.check, color: textColor)
                        //? const Icon(Icons.check, color: Colors.lightGreenAccent)
                        : Container(),
                  if (data.contentCount > 0)
                    Container(
                      decoration: BoxDecoration(
                          color: isEven
                              ? Theme.of(context).backgroundColor
                              : Theme.of(context).primaryColor,
                          shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Center(child: Text(data.contentCount.toString())),
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
