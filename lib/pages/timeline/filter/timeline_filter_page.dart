import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_scopes_widget.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_topics_widget.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_field.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:logger/logger.dart';

class TimelineFilterPage extends StatefulWidget {
  TimelineFilterPage({
    Key? key,
    required this.handleEventSelection,
    required this.handleYearSelection,
    required this.yearsList,
    required this.availableTopics,
    required this.availableScopes,
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
  final Future<List<EventScope>> availableScopes;
  final TimelineFilterParams? filterParams;

  @override
  State<TimelineFilterPage> createState() => _TimelineFilterPageState();
}

class _TimelineFilterPageState extends State<TimelineFilterPage> {
  // Set<Topic> selectedTopics = {};
  bool advancedSearch = true;
  TimelineFilterParams filterParams =
      TimelineFilterParams(topics: {}, scopes: {}, searchText: "");

  late final TextEditingController searchBarController;
  final double childAspectRatio = 20 / 4;
  @override
  void initState() {
    searchBarController = TextEditingController();
    super.initState();
    if (widget.filterParams != null) {
      filterParams = widget.filterParams!;
      // selectedTopics.addAll(widget.filterParams!.topics);
      searchBarController.text = widget.filterParams!.searchText;
    } /*
    searchBarController.addListener(() {
      filterParams.searchText = searchBarController.text;
    });*/
    filterParams.addListener(() {
      //widget.handleFilterSubmission(filterParams, false);
      setState(() {});
    });
  }

  int gridCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width > 2000
        ? 4
        : width > 1500
            ? 3
            : width > 1000
                ? 2
                : 1;
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
        /*trailing: (PlatformService.instance.isIos)
            ? CupertinoButton(
                onPressed: _enableAdvancedSearch,
                child: Icon(
                  advancedSearch
                      ? CupertinoIcons.settings
                      : CupertinoIcons.settings_solid,
                  semanticLabel: AppLocalizations.of(context)!
                      .timelineSearchHintInsideTopic,
                ))
            : IconButton(
                tooltip:
                    AppLocalizations.of(context)!.timelineSearchHintInsideTopic,
                onPressed: _enableAdvancedSearch,
                icon: Icon(
                  advancedSearch ? Icons.filter_alt : Icons.filter_alt_outlined,
                  semanticLabel: AppLocalizations.of(context)!
                      .timelineSearchHintInsideTopic,
                )),*/
        middle: buildSearchBar(context),
      ),
      body: buildBody(context),
    );
  }

  Padding buildBody(BuildContext context) {
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
                            flex: rightProportion,
                            child: CustomScrollView(
                              scrollDirection: Axis.vertical,
                              slivers: [
                                ScopesFilterWidget(
                                  filterParams: filterParams,
                                  availableScopes: widget.availableScopes,
                                  childAspectRatio: childAspectRatio,
                                  gridCount: gridCount(context),
                                ),
                                TopicsFilterWidget(
                                  filterParams: filterParams,
                                  availableTopics: widget.availableTopics,
                                  childAspectRatio: childAspectRatio,
                                  gridCount: gridCount(context),
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            width: dividerWidth,
                            thickness: dividerThickness,
                          ),
                          Flexible(
                            flex: 100 - rightProportion,
                            child: CustomScrollView(
                              scrollDirection: Axis.vertical,
                              slivers: [
                                selectedTopicsWidget(
                                    dividerWidth, dividerThickness),
                                selectedScopesWidget(
                                    dividerWidth, dividerThickness),
                                SliverToBoxAdapter(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: submitTextButton,
                                )),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: CustomScrollView(
                              scrollDirection: Axis.vertical,
                              slivers: [
                                selectedScopesWidget(
                                    dividerWidth, dividerThickness),
                                selectedTopicsWidget(
                                    dividerWidth, dividerThickness),
                                ScopesFilterWidget(
                                  filterParams: filterParams,
                                  availableScopes: widget.availableScopes,
                                  childAspectRatio: childAspectRatio,
                                  gridCount: gridCount(context),
                                ),
                                TopicsFilterWidget(
                                  filterParams: filterParams,
                                  availableTopics: widget.availableTopics,
                                  childAspectRatio: childAspectRatio,
                                  gridCount: gridCount(context),
                                ),
                                //SliverToBoxAdapter(child: divider),
                                //SliverToBoxAdapter(child: submitTextButton),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: submitTextButton,
                          ),
                        ],
                      );
              }),
      ),
    );
  }

  //region Topics

  Widget selectedTopicsWidget(
      final double dividerWidth, final double dividerThickness) {
    Widget wrap = AnimatedBuilder(
        animation: filterParams,
        builder: (context, child) {
          return Wrap(
            spacing: 5,
            runSpacing: 5,
            alignment: WrapAlignment.start,
            direction: Axis.horizontal,
            children: filterParams.getTopics
                .map((Topic topic) => Chip(
                      label: Text(topic.title),
                      onDeleted: () {
                        filterParams.removeTopic(topic);
                      },
                    ))
                .toList(),
          );
        });
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: filterParams.isTopicsEmpty()
            ? Container()
            : Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.timelineSelectedTopics,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: IscteTheme.iscteColor),
                    ),
                  ),
                ),
                wrap,
                Divider(height: dividerWidth, thickness: dividerThickness),
              ]),
      ),
    );
  }

  //endregion

  //region EventScopes

  Widget selectedScopesWidget(
      final double dividerWidth, final double dividerThickness) {
    Widget wrap = Wrap(
      spacing: 5,
      runSpacing: 5,
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      children: filterParams.getScopes
          .map((EventScope scope) => Chip(
                label: Text(scope.name),
                onDeleted: () {
                  setState(() {
                    filterParams.removeScope(scope);
                  });
                },
              ))
          .toList(),
    );
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: filterParams.isScopesEmpty()
            ? Container()
            : Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Selected Scopes",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: IscteTheme.iscteColor),
                    ),
                  ),
                ),
                wrap,
                Divider(height: dividerWidth, thickness: dividerThickness),
              ]),
      ),
    );
  }

  //endregion

  Widget buildSearchBar(BuildContext context) {
    TextStyle? theme = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: IscteTheme.iscteColor);
    return ListTile(
      leading: (PlatformService.instance.isIos)
          ? CupertinoButton(
              onPressed: _submitSelection,
              child: const Icon(CupertinoIcons.search))
          : IconButton(
              icon: const Icon(Icons.search),
              onPressed: _submitSelection,
            ),
      trailing: (PlatformService.instance.isIos)
          ? CupertinoButton(
              onPressed: searchBarController.clear,
              child: const Icon(CupertinoIcons.clear))
          : IconButton(
              icon: const Icon(Icons.clear),
              onPressed: searchBarController.clear),
      title: DynamicTextField(
        style: theme,
        controller: searchBarController,
        placeholder: "Pesquise aqui",
        placeholderStyle: theme,

        //border: InputBorder.none,
      ),
    );
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
    filterParams.searchText = searchBarController.text;
    widget.handleFilterSubmission(filterParams, true);
  }
}
