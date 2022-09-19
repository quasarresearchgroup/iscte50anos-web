import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/timeline/timeline_details_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/pages/unknown_page.dart';
import 'package:iscte_spots/services/routes/timeline_route.dart';
import 'package:logger/logger.dart';

class TimelineRouterDelegate extends RouterDelegate<TimelineRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<TimelineRoute> {
  bool show404 = false;

  int? _selectedEventId;
  int? _selectedYear;
  bool _showFilterPage = false;

  final Logger _logger = Logger();

  void _handleEventSelection(int event) {
    _selectedEventId = event;
    notifyListeners();
  }

  void _handleFilterNavigation() {
    _showFilterPage = true;
    notifyListeners();
  }

  void _logAll() {
    _logger.d(
        "Timeline routerDelegate: event_id:$_selectedEventId; showFilterPage:$_showFilterPage;");
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    _logAll();
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: TimelinePage.pageKey,
          child: TimelinePage(
            selectedYear: _selectedYear,
            handleEventSelection: _handleEventSelection,
            handleFilterNavigation: _handleFilterNavigation,
          ),
        ),
        if (show404)
          MaterialPage(key: const ValueKey("UnknownPage"), child: UnknownPage())
        else if (_selectedEventId != null)
          MaterialPage(
            key: TimeLineDetailsPage.pageKey,
            child: TimeLineDetailsPage(
              eventId: _selectedEventId!,
            ),
          )
        else if (_showFilterPage)
          MaterialPage(
            key: TimelineFilterPage.pageKey,
            child: TimelineFilterPage(
              handleEventSelection: _handleEventSelection,
            ),
          )
      ],
      onPopPage: (Route route, result) {
        final page = route.settings as MaterialPage;
        if (!route.didPop(result)) {
          return false;
        }
        if (page.key == TimeLineDetailsPage.pageKey) {
          _selectedEventId = null;
        }
        if (page.key == TimelineFilterPage.pageKey) {
          _showFilterPage = false;
        }
        show404 = false;

        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(TimelineRoute path) async {
    _logAll();
    if (path.isUnknown) {
      _selectedEventId = null;
      _showFilterPage = false;
      show404 = true;
      return;
    }

    if (path.isDetailsPage) {
      if (path.event_id!.isNegative) {
        show404 = true;
        return;
      }
      _selectedEventId = path.event_id;
    } else {
      _selectedEventId = null;
    }

    if (path.isFilterPage) {
      _selectedEventId = null;
      _showFilterPage = true;
    } else {
      _showFilterPage = false;
    }

    show404 = false;
    return;
  }

  @override
  TimelineRoute get currentConfiguration {
    if (show404) {
      return TimelineRoute.unknown();
    }
    if (_showFilterPage) {
      _logAll();
      return TimelineRoute.filter();
    }

    if (_selectedEventId != null) {
      return TimelineRoute.details(_selectedEventId);
    }
    //if (_selectedYear != null) {
    //return TimelineRoute.home(timelineYear: _selectedYear);
    //}

    return TimelineRoute.home();
  }
}
