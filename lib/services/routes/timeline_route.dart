class TimelineRoute {
  final int? id;
  final bool isUnknown;

  TimelineRoute.home()
      : id = null,
        isUnknown = false;
  TimelineRoute.details(this.id) : isUnknown = false;
  TimelineRoute.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;

  bool get isDetailsPage => id != null;
}
