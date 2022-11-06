import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/event_timeline_indicator.dart';
import 'package:iscte_spots/pages/timeline/events/timeline_information_child.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventTimelineTile extends StatefulWidget {
  EventTimelineTile({
    Key? key,
    required this.lineStyle,
    required this.isFirst,
    required this.isLast,
    required this.event,
    required this.index,
    required this.handleEventSelection,
    required this.isSelected,
  }) : super(key: key);

  final int index;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;
  final Event event;
  final LineStyle lineStyle;
  final void Function(int) handleEventSelection;

  @override
  State<EventTimelineTile> createState() => _EventTimelineTileState();
}

class _EventTimelineTileState extends State<EventTimelineTile> {
  final Color color2 = Colors.white.withOpacity(0.3);

  late bool isEven = widget.index % 2 == 0;

  final int flagFlex = 15;

  final int informationFlex = 85;

  final int dateFlex = 10;
  late bool isHover = widget.isSelected;
  @override
  Widget build(BuildContext context) {
    late Color? informationChildTextColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
    return GestureDetector(
      onTap: widget.event.contentCount > 0
          ? () {
              widget.handleEventSelection(widget.event.id);
            }
          : null,
      child: MouseRegion(
        cursor: widget.event.isVisitable
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (event) => setState(() => isHover = true),
        onExit: (event) => setState(() => isHover = false),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            height: widget.isSelected || isHover ? 130 : 100,
            child: Card(
              margin: EdgeInsets.zero,
              color: !isEven ? Colors.transparent : IscteTheme.greyColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.event.scopeIcon != null)
                    Flexible(
                        flex: flagFlex,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: widget.event.scopeIcon!,
                        )),
                  Flexible(
                    flex: dateFlex,
                    child: EventTimelineIndicator(
                      isEven: isEven,
                      event: widget.event,
                      textColor: informationChildTextColor,
                      isFirst: widget.isFirst,
                      isLast: widget.isLast,
                    ),
                  ),
                  Expanded(
                    flex: informationFlex,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TimelineInformationChild(
                        isEven: isEven,
                        data: widget.event,
                        //textColor: informationChildTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
