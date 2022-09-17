import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/timeline_details_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/pages/unknown_page.dart';

class PageRouter {
  static Widget resolve(String route, Object? argument) {
    switch (route) {
      //case Home.pageRoute:
      //return Home();
      case TimelinePage.pageRoute:
        return TimelinePage();
      case TimeLineDetailsPage.pageRoute:
        return TimeLineDetailsPage(eventId: argument as int);
      case TimelineFilterPage.pageRoute:
        return TimelineFilterPage(
          defaultEvents: argument as List<Event>,
        );
      default:
        return TimelinePage();
    }
  }

  static String initialRoute = TimelinePage.pageRoute;

  static Map<String, Widget Function(BuildContext)> routes = {
    TimelinePage.pageRoute: (context) => TimelinePage(),
    TimeLineDetailsPage.pageRoute + "/*": (context) {
      //in your example: settings.name = "/post?id=123"
      final settingsUri =
          Uri.parse(ModalRoute.of(context)!.settings.name ?? "");
      if (settingsUri.pathSegments.length == 2 &&
          settingsUri.pathSegments[0] == TimeLineDetailsPage.pageRoute) {
        final int? id = int.tryParse(settingsUri.pathSegments[1]);
        return id != null ? TimeLineDetailsPage(eventId: id) : UnknownPage();
      } else {
        return UnknownPage();
      }
      //settingsUri.queryParameters is a map of all the query keys and values
    },
    TimelineFilterPage.pageRoute: (context) => TimelineFilterPage(
          defaultEvents: (ModalRoute.of(context)?.settings.arguments ??
              <Event>[]) as List<Event>,
        ),
  };
}
