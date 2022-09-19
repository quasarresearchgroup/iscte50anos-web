import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/timeline/timeline_details_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/services/routes/timeline_route.dart';

class TimelineRouteInformationParser
    extends RouteInformationParser<TimelineRoute> {
  @override
  Future<TimelineRoute> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? "");

    // Handle '/timeline'
    if (uri.pathSegments.length == 1 &&
        uri.pathSegments[0] == TimelinePage.pageRoute) {
      //String remaining = uri.pathSegments[1];
      //int? timelineYear = int.tryParse(remaining);
      //if (timelineYear == null) return TimelineRoute.home();
      //return TimelineRoute.home(timelineYear: timelineYear);
      return TimelineRoute.home();
    }

    // Handle '/timeline/event/:id'
    if (uri.pathSegments.length == 3 &&
        uri.pathSegments[0] == TimelinePage.pageRoute &&
        uri.pathSegments[1] == TimeLineDetailsPage.pageRoute) {
      String remaining = uri.pathSegments[2];
      int? id = int.tryParse(remaining);
      if (id == null) return TimelineRoute.unknown();
      return TimelineRoute.details(id);
    }
    // Handle '/timeline/filter'
    if (uri.pathSegments.length == 2 &&
        uri.pathSegments[0] == TimelinePage.pageRoute &&
        uri.pathSegments[1] == TimelineFilterPage.pageRoute) {
      return TimelineRoute.filter();
    }

    // Handle unknown routes
    return TimelineRoute.home();
  }

  @override
  RouteInformation? restoreRouteInformation(TimelineRoute configuration) {
    if (configuration.isUnknown) {
      return const RouteInformation(location: '/404');
    }
    if (configuration.isHomePage) {
      /*if (configuration.timelineYear != null) {
        return RouteInformation(
            location: '/timeline/${configuration.timelineYear}');
      } else {*/
      return const RouteInformation(location: '/${TimelinePage.pageRoute}');
      //}
    }
    if (configuration.isDetailsPage) {
      return RouteInformation(
          location:
              '/${TimelinePage.pageRoute}/${TimeLineDetailsPage.pageRoute}/${configuration.event_id}');
    }
    if (configuration.isFilterPage) {
      return const RouteInformation(
          location:
              '/${TimelinePage.pageRoute}/${TimelineFilterPage.pageRoute}');
    }
    return null;
  }
}
