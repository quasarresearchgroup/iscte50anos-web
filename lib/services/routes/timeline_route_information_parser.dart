import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/pages/timeline/details/timeline_details_page.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/services/routes/timeline_route.dart';
import 'package:logger/logger.dart';

class TimelineRouteInformationParser
    extends RouteInformationParser<TimelineRoute> {
  final Logger _logger = Logger();
  final int defaultYear = 1972;

  @override
  Future<TimelineRoute> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? "");
    _logger.d(
        "parseRouteInformation\nuri:$uri\n${uri.pathSegments}\n${uri.pathSegments.length}");

    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == TimelinePage.pageRoute) {
        // Handle '/timeline/:year'
        if (int.tryParse(uri.pathSegments[1]) != null) {
          String remaining = uri.pathSegments[1];
          int? timelineYear = int.tryParse(remaining);
          Logger().d(timelineYear);
          if (timelineYear == null)
            return TimelineRoute.home(year: defaultYear);
          return TimelineRoute.home(year: timelineYear);
        }
      }
    }
    // Handle '/timeline/filter/:params/result'
    if (uri.pathSegments.length == 4 &&
        uri.pathSegments[0] == TimelinePage.pageRoute &&
        uri.pathSegments[1] == TimelineFilterPage.pageRoute &&
        uri.pathSegments[3] == "results") {
      try {
        TimelineFilterParams timelineFilterParams =
            TimelineFilterParams.decode(uri.pathSegments[2]);
        return TimelineRoute.filterResult(
          filterParams: timelineFilterParams,
        );
      } catch (e, stacktrace) {
        _logger.e(e);
        return TimelineRoute.home(year: defaultYear);
      }
    }

    // Handle '/timeline/filter/:params'
    //if ((uri.pathSegments.length == 3 || uri.pathSegments.length == 4) &&
    //    uri.pathSegments[0] == TimelinePage.pageRoute) {
    //  if (uri.pathSegments[1] == TimelineFilterPage.pageRoute) {
    //    try {
    //      TimelineFilterParams timelineFilterParams =
    //          TimelineFilterParams.decode(uri.pathSegments[2]);
    // Handle '/timeline/filter/:params/result'
    //    if (uri.pathSegments.length == 4) {
    //      if (uri.pathSegments[3] == "results") {
    //        return TimelineRoute.filterResult(
    //          filterParams: timelineFilterParams,
    //        );
    //      }
    //    } else {
    //      return TimelineRoute.filter(filterParams: timelineFilterParams);
    //    }
    //  } catch (e, stacktrace) {
    //    _logger.e("$e");
    //    //return TimelineRoute.filter();
    //    return TimelineRoute.home(year: timelineYear);
    //  }
    //}
    //}

    // Handle '/timeline/event/:id'
    if (uri.pathSegments.length == 3 &&
        uri.pathSegments[0] == TimelinePage.pageRoute &&
        uri.pathSegments[1] == TimeLineDetailsPage.pageRoute) {
      String remaining = uri.pathSegments[2];
      int? id = int.tryParse(remaining);
      if (id == null) return TimelineRoute.unknown();
      return TimelineRoute.details(id);
    }

    // Handle unknown routes
    return TimelineRoute.home(year: 1972);
  }

  @override
  RouteInformation? restoreRouteInformation(TimelineRoute configuration) {
    String location;
    if (configuration.isUnknown) {
      location = '/404';
    } else if (configuration.isHomePage) {
      location = '/${TimelinePage.pageRoute}/${configuration.timelineYear}';
    } else if (configuration.isDetailsPage) {
      location =
          '/${TimelinePage.pageRoute}/${TimeLineDetailsPage.pageRoute}/${configuration.event_id}';
      //} else if (configuration.isFilterPage) {
      //  location =
      //      '/${TimelinePage.pageRoute}/${TimelineFilterPage.pageRoute}/${(configuration.filterParams?.encode()) ?? ""}';
    } else if (configuration.isFilterResultPage) {
      location =
          '/${TimelinePage.pageRoute}/${TimelineFilterPage.pageRoute}/${(configuration.filterParams?.encode()) ?? ""}/results';
    } else {
      return null;
    }
    _logger.d(location);
    return RouteInformation(location: location);
  }
}
