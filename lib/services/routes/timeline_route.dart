class TimelineRoute {
  final int? event_id;
  //final int? timelineYear;
  final bool _isUnknown;
  final bool _isFilter;

  //TimelineRoute.home({int? timelineYear})
  TimelineRoute.home()
      : event_id = null,
        //timelineYear = timelineYear,
        _isFilter = false,
        _isUnknown = false;
  TimelineRoute.details(this.event_id)
      : _isFilter = false,
        //timelineYear = null,
        _isUnknown = false;
  TimelineRoute.unknown()
      : event_id = null,
        _isFilter = false,
        // timelineYear = null,
        _isUnknown = true;
  TimelineRoute.filter()
      : event_id = null,
        _isFilter = true,
        //timelineYear = null,
        _isUnknown = false;

  bool get isHomePage => event_id == null && !_isFilter;
  bool get isFilterPage => _isFilter;
  bool get isDetailsPage => event_id != null;

  bool get isUnknown => _isUnknown;
}
