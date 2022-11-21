import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';

class TimelineRoute {
  int? event_id;
  int? timelineYear;
  TimelineFilterParams? filterParams;
  bool _isUnknown = false;
  // bool _isFilter = false;

  //TimelineRoute.home({int? timelineYear})
  TimelineRoute.home({required int year}) : timelineYear = year;
  TimelineRoute.details(this.event_id);
  TimelineRoute.unknown() : _isUnknown = true;
  //TimelineRoute.filter({this.filterParams}) : _isFilter = true;
  TimelineRoute.filterResult({required this.filterParams});

  bool get isHomePage =>
      timelineYear != null &&
      !isDetailsPage &&
      // !isFilterPage &&
      !isFilterResultPage;

  bool get isDetailsPage =>
      event_id != null && !isHomePage && !isFilterResultPage;
  //event_id != null && !isHomePage && !isFilterPage && !isFilterResultPage;

  //bool get isFilterPage => _isFilter && !isDetailsPage;

  //bool get isFilterResultPage => filterParams != null && !isFilterPage;
  bool get isFilterResultPage => filterParams != null;

  bool get isUnknown => _isUnknown;
}
