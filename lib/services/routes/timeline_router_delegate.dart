import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/pages/timeline/details/timeline_details_page.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_results_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/pages/unknown_page.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/routes/timeline_route.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

class TimelineRouterDelegate extends RouterDelegate<TimelineRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<TimelineRoute> {
  bool show404 = false;

  int? _selectedEventId;
  int _selectedYear = 1972;
  //bool _showFilterPage = false;
  bool _showFilterPageResult = false;
  TimelineFilterParams? _selectedFilterParams;

  final Future<List<int>> yearsList = TimelineEventService.fetchYearsList();
  final Future<List<EventScope>> availableScopes =
      Future(() => EventScope.values);

  void _handleEventSelection(int event) {
    _selectedEventId = event;
    notifyListeners();
  }

  void _handleYearSelection(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  void _handleFilterSubmission(TimelineFilterParams filters, bool showResults) {
    LoggerService.instance.debug(
        "handledFilterSubmission with $filters ; showResults: $showResults");
    if (showResults) {
      //  _showFilterPage = false;
      _showFilterPageResult = true;
    }
    _selectedFilterParams = filters;
    notifyListeners();
  }

  String _logAll() {
    return 'TimelineRouterDelegate{show404: $show404, _selectedEventId: $_selectedEventId, _selectedYear: $_selectedYear, _showFilterPageResult: $_showFilterPageResult, _selectedFilterParams: $_selectedFilterParams, yearsList: $yearsList}';
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
          child: FutureBuilder<List<int>>(
              future: yearsList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int year;
                  if (snapshot.data!.contains(_selectedYear)) {
                    year = _selectedYear;
                  } else {
                    year = snapshot.data!.first;
                    _handleYearSelection(year);
                  }
                  return FutureBuilder<List<Event>>(
                      future: TimelineEventService.fetchEventsFromYear(
                          year: _selectedYear),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return TimelinePage(
                            selectedYear: year,
                            handleEventSelection: _handleEventSelection,
                            //handleFilterNavigation: _handleFilterNavigation,
                            handleFilterSubmission: _handleFilterSubmission,
                            handleYearSelection: _handleYearSelection,
                            yearsList: yearsList,
                            filteredEvents: snapshot.data!,
                          );
                        } else if (snapshot.hasError) {
                          return Scaffold(
                            body: ErrorWidget(snapshot.error!),
                          );
                        } else {
                          return const Scaffold(
                            body: LoadingWidget(),
                          );
                        }
                      });
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: ErrorWidget(snapshot.error!),
                  );
                } else {
                  return const Scaffold(
                    body: LoadingWidget(),
                  );
                }
              }),
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
/*        else if (_showFilterPage)
          MaterialPage(
            key: TimelineFilterPage.pageKey,
            child: TimelineFilterPage(
              handleEventSelection: _handleEventSelection,
              handleYearSelection: _handleYearSelection,
              handleFilterSubmission: _handleFilterSubmission,
              filterParams: _selectedFilterParams,
              yearsList: yearsList,
              availableTopics: availableTopics,
              availableScopes: availableScopes,
            ),
          )*/
        else if (_showFilterPageResult)
          MaterialPage(
            key: TimelineFilterResultsPage.pageKey,
            child: TimelineFilterResultsPage(
              timelineFilterParams: _selectedFilterParams!,
              handleEventSelection: _handleEventSelection,
              handleYearSelection: _handleYearSelection,
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
        //if (page.key == TimelineFilterPage.pageKey) {
        //   _showFilterPage = false;
        //}
        if (page.key == TimelineFilterResultsPage.pageKey) {
          _showFilterPageResult = false;
          //  _showFilterPage = true;
        }
        show404 = false;

        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(TimelineRoute configuration) async {
    _logAll();
    if (configuration.isUnknown) {
      _selectedEventId = null;
      //_showFilterPage = false;
      show404 = true;
      return;
    }

    if (configuration.isDetailsPage) {
      if (configuration.event_id!.isNegative) {
        show404 = true;
      } else {
        _selectedEventId = configuration.event_id;
      }
    } else {
      _selectedEventId = null;
    }

    /*if (path.isFilterPage) {
      _selectedFilterParams = path.filterParams;
        _showFilterPage = true;
    } else {
        _showFilterPage = false;
    }*/

    if (configuration.isFilterResultPage) {
      _selectedFilterParams = configuration.filterParams;
      _showFilterPageResult = true;
    } else {
      _showFilterPageResult = false;
    }

    _selectedYear = configuration.timelineYear ?? _selectedYear;
    show404 = false;
    return;
  }

  @override
  TimelineRoute get currentConfiguration {
    _logAll();
    if (show404) {
      return TimelineRoute.unknown();
    }
    //if (_showFilterPage) {
    //  return TimelineRoute.filter(filterParams: _selectedFilterParams);
    //}
    if (_showFilterPageResult) {
      return TimelineRoute.filterResult(filterParams: _selectedFilterParams);
    }

    if (_selectedEventId != null) {
      return TimelineRoute.details(_selectedEventId);
    }

    return TimelineRoute.home(year: _selectedYear);
  }
}
