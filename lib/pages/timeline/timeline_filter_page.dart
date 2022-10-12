import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_field.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class TimelineFilterPage extends StatefulWidget {
  TimelineFilterPage({
    Key? key,
    required this.handleEventSelection,
    required this.handleYearSelection,
    required this.yearsList,
    required this.availableTopics,
    required this.handleFilterSubmission,
    this.filterParams,
  }) : super(key: key);

  static const String pageRoute = "filter";
  static const ValueKey pageKey = ValueKey(pageRoute);
  final Logger _logger = Logger();

  final void Function(int) handleEventSelection;
  final void Function(int) handleYearSelection;
  final void Function(TimelineFilterParams, bool) handleFilterSubmission;
  final Future<List<int>> yearsList;
  final Future<List<Topic>> availableTopics;
  final TimelineFilterParams? filterParams;

  @override
  State<TimelineFilterPage> createState() => _TimelineFilterPageState();
}

class _TimelineFilterPageState extends State<TimelineFilterPage> {
  // Set<Topic> selectedTopics = {};
  bool advancedSearch = true;
  TimelineFilterParams filterParams =
      TimelineFilterParams(topics: {}, searchText: "");

  late final Future<List<Topic>> availableTopics;
  late final TextEditingController searchBarController;

  @override
  void initState() {
    searchBarController = TextEditingController();
    super.initState();
    availableTopics = widget.availableTopics;
    if (widget.filterParams != null) {
      filterParams = widget.filterParams!;
      // selectedTopics.addAll(widget.filterParams!.topics);
      searchBarController.text = widget.filterParams!.searchText;
    } /*
    searchBarController.addListener(() {
      filterParams.searchText = searchBarController.text;
    });*/
    filterParams.addListener(() {
      Logger().d("listened to Filter Params");
      widget.handleFilterSubmission(filterParams, false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        leading: const DynamicBackIconButton(),
        trailing: (PlatformService.instance.isIos)
            ? CupertinoButton(
                onPressed: _enableAdvancedSearch,
                child: Icon(
                  advancedSearch
                      ? CupertinoIcons.settings
                      : CupertinoIcons.settings_solid,
                  semanticLabel: AppLocalizations.of(context)!
                      .timelineSearchHintInsideTopic,
                  color: Colors.white,
                ))
            : IconButton(
                tooltip:
                    AppLocalizations.of(context)!.timelineSearchHintInsideTopic,
                onPressed: _enableAdvancedSearch,
                icon: Icon(
                  advancedSearch ? Icons.filter_alt : Icons.filter_alt_outlined,
                  semanticLabel: AppLocalizations.of(context)!
                      .timelineSearchHintInsideTopic,
                )),
        middle: buildSearchBar(context, filterParams.isEmpty()),
      ),
      body: buildBody(context, filterParams.isEmpty()),
    );
  }

  Padding buildBody(BuildContext context, bool isEmptySelectedTopics) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: !advancedSearch
            ? Center(
                child: DynamicTextButton(
                  style: IscteTheme.iscteColor,
                  onPressed: _submitSelection,
                  child:
                      Text(AppLocalizations.of(context)!.timelineSearchButton),
                ),
              )
            : OrientationBuilder(
                builder: (BuildContext context, Orientation orientation) {
                const double dividerWidth = 20;
                const double dividerThickness = 2;
                Widget divider = (orientation == Orientation.landscape)
                    ? const VerticalDivider(
                        width: dividerWidth,
                        thickness: dividerThickness,
                      )
                    : const Divider(
                        height: dividerWidth, thickness: dividerThickness);

                var submitTextButton = DynamicTextButton(
                  style: IscteTheme.iscteColor,
                  onPressed: _submitSelection,
                  child:
                      Text(AppLocalizations.of(context)!.timelineSearchButton),
                );
                int rightProportion = 50;
                return (orientation == Orientation.landscape)
                    ? Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 100 - rightProportion,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SingleChildScrollView(
                                  child: selectedTopicsWidget(
                                      isEmptySelectedTopics,
                                      dividerWidth,
                                      dividerThickness),
                                ),
                                submitTextButton,
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            width: dividerWidth,
                            thickness: dividerThickness,
                          ),
                          Flexible(
                            flex: rightProportion,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildAvailableTopicsHeader(context),
                                buildTopicsCheckBoxList(),
                              ],
                            ),
                          )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          selectedTopicsWidget(isEmptySelectedTopics,
                              dividerWidth, dividerThickness),
                          buildAvailableTopicsHeader(context),
                          buildTopicsCheckBoxList(),
                          divider,
                          submitTextButton,
                        ],
                      );
              }),
      ),
    );
  }

  Padding buildAvailableTopicsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child:
                  Text(AppLocalizations.of(context)!.timelineAvailableTopics)),
          Expanded(
            child: Container(),
          ),
          DynamicTextButton(
            onPressed: _selectAllTopics,
            child: Text(AppLocalizations.of(context)!.timelineSelectAllButton,
                style: const TextStyle(color: IscteTheme.iscteColor)),
          ),
          DynamicTextButton(
            onPressed: _clearTopicsList,
            child: Text(AppLocalizations.of(context)!.timelineSelectClearButton,
                style: const TextStyle(color: IscteTheme.iscteColor)),
          ),
        ],
      ),
    );
  }

  Widget selectedTopicsWidget(final bool isEmptySelectedTopics,
      final double dividerWidth, final double dividerThickness) {
    Widget wrap = Wrap(
      spacing: 5,
      runSpacing: 5,
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      children: filterParams.getTopics
          .map((Topic topic) => Chip(
                label: Text(topic.title ?? ""),
                backgroundColor: IscteTheme.iscteColor,
                onDeleted: () {
                  setState(() {
                    filterParams.removeTopic(topic);
                  });
                },
              ))
          .toList(),
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: isEmptySelectedTopics
          ? Container()
          : Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      AppLocalizations.of(context)!.timelineSelectedTopics),
                ),
              ),
              wrap,
              Divider(height: dividerWidth, thickness: dividerThickness),
            ]),
    );
  }

  Widget buildSearchBar(BuildContext context, bool isEmptySelectedTopics) {
    return Center(
      child: DynamicTextField(
        style: const TextStyle(color: Colors.white),
        controller: searchBarController,
        placeholderStyle: const TextStyle(color: Colors.white70),
        prefix: (PlatformService.instance.isIos)
            ? CupertinoButton(
                onPressed: _submitSelection,
                child: const Icon(
                  CupertinoIcons.search,
                  color: Colors.white,
                ))
            : IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: _submitSelection,
              ),
        suffix: (PlatformService.instance.isIos)
            ? CupertinoButton(
                onPressed: searchBarController.clear,
                child: const Icon(
                  CupertinoIcons.clear,
                  color: Colors.white,
                ))
            : IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: searchBarController.clear),
        placeholder: !advancedSearch
            ? AppLocalizations.of(context)!.timelineSearchHint
            : AppLocalizations.of(context)!.timelineSearchHintInsideTopic,
        //border: InputBorder.none,
      ),
    );
  }

  Widget buildTopicsCheckBoxList() {
    return Expanded(
      child: FutureBuilder<List<Topic>>(
        future: availableTopics,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Topic> data = snapshot.data!;
            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 16 / 4),
                semanticChildCount: data.length,
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    activeColor: IscteTheme.iscteColor,
                    value: filterParams.containsTopic(data[index]),
                    title: SingleChildScrollView(
                      controller: ScrollController(),
                      scrollDirection: Axis.horizontal,
                      child: Text(data[index].title ?? ""),
                    ),
                    onChanged: (bool? bool) {
                      if (bool != null) {
                        if (bool) {
                          setState(() {
                            filterParams.addTopic(data[index]);
                          });
                        } else {
                          setState(() {
                            filterParams.removeTopic(data[index]);
                          });
                        }
                        widget._logger.d(filterParams);
                      }
                    },
                  );
                });
          } else if (snapshot.hasError) {
            return ErrorWidget(AppLocalizations.of(context)!.generalError);
          } else {
            return const LoadingWidget();
          }
        },
      ),
    );
  }

  void _selectAllTopics() async {
    List<Topic> allTopics = await availableTopics;
    setState(() {
      filterParams.addAllTopic(allTopics);
    });
  }

  void _clearTopicsList() {
    setState(() {
      filterParams.clearTopics();
    });
  }

  void _enableAdvancedSearch() {
    setState(() {
      advancedSearch = !advancedSearch;
      if (!advancedSearch) {
        filterParams.clearTopics();
      }
    });
    widget._logger.d("advancedSearch: $advancedSearch");
  }

  void _submitSelection() async {
    /*TimelineFilterParams timelineFilterParams = TimelineFilterParams(
        topics: filterParams.topics, searchText: searchBarController.text);

    widget._logger.d(timelineFilterParams);
    widget.handleFilterSubmission(timelineFilterParams, true);*/
    filterParams.searchText = searchBarController.text;
    widget._logger.d(filterParams);
    widget.handleFilterSubmission(filterParams, true);

    // Set<Event> setOfEvents = {};
    // List<int> topicIds = selectedTopics.map((e) => e.id).toList();
    // setOfEvents
    //     .addAll(await TimelineTopicService.fetchEvents(topicIds: topicIds));
    // if (selectedTopics.isEmpty) {
    //   setOfEvents.addAll(widget.defaultEvents ?? []);
    // }
    //
    // widget._logger.d("events from topics: $setOfEvents");
    // String textSearchBar = searchBarController.text.toLowerCase();
    // if (textSearchBar.isNotEmpty) {
    //   setOfEvents = setOfEvents.where((Event element) {
    //     String eventTitle = (element.title).toLowerCase();
    //     return eventTitle.contains(textSearchBar) ||
    //         textSearchBar.contains(eventTitle);
    //   }).toSet();
    //   widget._logger
    //       .d("filtering with $textSearchBar; resulting events: $setOfEvents");
    // }
    // if (mounted) {
    //   Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => Theme(
    //       data: Theme.of(context).copyWith(
    //         appBarTheme: Theme.of(context).appBarTheme.copyWith(
    //               shape: const ContinuousRectangleBorder(),
    //             ),
    //       ),
    //       child: Scaffold(
    //         appBar: MyAppBar(
    //           leading: const DynamicBackIconButton(),
    //           title: AppLocalizations.of(context)!.timelineSearchResults,
    //         ),
    //         body: TimeLineBody(
    //           filteredEvents: setOfEvents.toList(),
    //           selectedYear: setOfEvents.last.dateTime.year,
    //           handleEventSelection: widget.handleEventSelection,
    //           handleYearSelection: widget.handleYearSelection,
    //         ),
    //       ),
    //     ),
    //   ));
    // }
  }
}
