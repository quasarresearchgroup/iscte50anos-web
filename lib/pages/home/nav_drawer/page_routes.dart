import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/timeline_details_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';

class PageRouter {
  static Widget resolve(String route, Object? argument) {
    switch (route) {
      //case Home.pageRoute:
      //return Home();
      case TimelinePage.pageRoute:
        return TimelinePage();
      case TimeLineDetailsPage.pageRoute:
        return TimeLineDetailsPage(event: argument as Event);
      case TimelineFilterPage.pageRoute:
        return TimelineFilterPage(
          defaultEvents: argument as List<Event>,
        );
      default:
        return TimelinePage();
    }
  }
}
