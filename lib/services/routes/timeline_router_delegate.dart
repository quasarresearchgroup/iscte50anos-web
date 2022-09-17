import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/timeline/timeline_details_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/pages/unknown_page.dart';
import 'package:iscte_spots/services/routes/timeline_route.dart';

class TimelineRouterDelegate extends RouterDelegate<TimelineRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<TimelineRoute> {
  bool show404 = false;

  int? _selectedEventId;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey(TimelinePage.pageRoute),
          child: TimelinePage(),
        ),
        if (show404)
          MaterialPage(key: ValueKey("UnknownPage"), child: UnknownPage())
        else if (_selectedEventId != null)
          MaterialPage(
            key: ValueKey(TimeLineDetailsPage.pageRoute),
            child: TimeLineDetailsPage(
              eventId: _selectedEventId!,
            ),
          )
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        _selectedEventId = null;
        show404 = false;
        notifyListeners();

        return true;
      },
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey<NavigatorState>();

  @override
  Future<void> setNewRoutePath(TimelineRoute path) async {
    if (path.isUnknown) {
      _selectedEventId = null;
      show404 = true;
      return;
    }
    if (path.isDetailsPage) {
      if (path.id! < 0) {
        show404 = true;
        return;
      }
      _selectedEventId = path.id;
    } else {
      _selectedEventId = null;
    }
    show404 = false;
    return;
  }

  TimelineRoute get currentConfiguration {
    if (show404) {
      return TimelineRoute.unknown();
    }
    return _selectedEventId == null
        ? TimelineRoute.home()
        : TimelineRoute.details(_selectedEventId);
  }
}
