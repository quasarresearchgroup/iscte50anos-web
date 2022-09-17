import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/timeline/timeline_details_page.dart';
import 'package:iscte_spots/services/routes/timeline_route.dart';

class TimelineRouteInformationParser
    extends RouteInformationParser<TimelineRoute> {
  @override
  Future<TimelineRoute> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? "");
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return TimelineRoute.home();
    }

    // Handle '/event/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != TimeLineDetailsPage.pageRoute) {
        return TimelineRoute.unknown();
      }
      String remaining = uri.pathSegments[1];
      int? id = int.tryParse(remaining);
      if (id == null) return TimelineRoute.unknown();
      return TimelineRoute.details(id);
    }

    // Handle unknown routes
    return TimelineRoute.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(TimelineRoute configuration) {
    if (configuration.isUnknown) {
      return const RouteInformation(location: '/404');
    }
    if (configuration.isHomePage) {
      return const RouteInformation(location: '/');
    }
    if (configuration.isDetailsPage) {
      return RouteInformation(location: '/event/${configuration.id}');
    }
    return null;
  }
}
