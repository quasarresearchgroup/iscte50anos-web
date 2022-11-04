import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Text(
              data.title,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,

              //fontSize: MediaQuery.of(context).size.width * 0.05,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (data.contentCount > 0)
                Icon(
                  Icons.adaptive.arrow_forward,
                ),
              if (data.contentCount > 0 && data.visited)
                const Icon(Icons.check),
              if (data.contentCount > 0)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "#${data.contentCount.toString()}",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).iconTheme.color),
                    ),
                  ),
                )
            ],
          ),
        )
      ],
    );
  }
}
