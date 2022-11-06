import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';

class YearTimelineTile extends StatefulWidget {
  const YearTimelineTile({
    Key? key,
    required this.changeYearFunction,
    required this.year,
    required this.isFirst,
    required this.isLast,
    required this.isSelected,
    required this.isHover,
  }) : super(key: key);

  final Function changeYearFunction;
  final int year;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;
  final bool isHover;

  @override
  State<YearTimelineTile> createState() => _YearTimelineTileState();
}

class _YearTimelineTileState extends State<YearTimelineTile> {
  final double textFontSize = 20.0;
  final double minWidth2 = 90;
  final double radius = 15;
  //final Color color2 = Colors.white.withOpacity(0.3);
  final double timelineIconOffset = 0.7;
  late bool isHover = widget.isHover;
  @override
  Widget build(BuildContext context) {
    LineStyle lineStyle = LineStyle(
        color: Theme.of(context).iconTheme.color ?? Colors.black, thickness: 6);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => isHover = true),
      onExit: (event) => setState(() => isHover = false),
      child: GestureDetector(
        //splashColor: color2,
        //highlightColor: color2,
        //enableFeedback: true,

        onTap: () {
          widget.changeYearFunction(widget.year);
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
            padding: EdgeInsets.symmetric(
                horizontal: widget.isHover || isHover ? 16 : 8.0),
            indicator: Center(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  widget.isSelected
                      ? FontAwesomeIcons.calendarCheck
                      : FontAwesomeIcons.calendar,
                  size: widget.isHover || isHover ? 34 : 24,
                ),
              ),
            ),
          ),
          startChild: Container(
            constraints: BoxConstraints(minWidth: minWidth2),
            child: Center(
              child: AnimatedDefaultTextStyle(
                style: (widget.isHover || isHover
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.headlineSmall)
                        ?.copyWith(
                      color: Theme.of(context).iconTheme.color,
                    ) ??
                    const TextStyle(),
                duration: const Duration(milliseconds: 500),
                child: Text(
                  widget.year.toString(),
                ),
              ),
            ),
          ),
          //),
        ),
      ),
    );
  }
}
