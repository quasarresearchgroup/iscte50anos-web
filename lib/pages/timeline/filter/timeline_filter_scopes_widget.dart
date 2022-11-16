import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

class ScopesFilterWidget extends StatelessWidget {
  const ScopesFilterWidget({
    Key? key,
    required this.filterParams,
    required this.availableScopes,
    required this.gridCount,
    required this.childAspectRatio,
  }) : super(key: key);

  final TimelineFilterParams filterParams;
  final Future<List<EventScope>> availableScopes;
  final int gridCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> _selectAllScopes() async {
    List<EventScope> allScopes = await availableScopes;
    filterParams.addAllScope(allScopes);
  }

  Future<void> _clearScopesList() async {
    filterParams.clearScopes();
  }

  Widget buildAvailableEventScopeHeader() {
    return SliverToBoxAdapter(
      child: Builder(builder: (context) {
        var text = Text(
          AppLocalizations.of(context)!.timelineAvailableScopes,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: IscteTheme.iscteColor),
        );
        var selectAllBtn = DynamicTextButton(
          onPressed: _selectAllScopes,
          child: Text(AppLocalizations.of(context)!.timelineSelectAllButton,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: IscteTheme.iscteColor)),
        );
        var clearAllBtn = DynamicTextButton(
          onPressed: _clearScopesList,
          child: Text(AppLocalizations.of(context)!.timelineSelectClearButton,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: IscteTheme.iscteColor)),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            direction: Axis.horizontal,
            verticalDirection: VerticalDirection.down,
            children: [text, selectAllBtn, clearAllBtn],
          ),
        );
      }),
    );
  }

  Widget buildEventScopesCheckBoxList() {
    return FutureBuilder<List<EventScope>>(
      future: availableScopes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<EventScope> data = snapshot.data!;
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCount,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return CheckboxListTile(
                  activeColor: IscteTheme.iscteColor,
                  value: filterParams.containsScope(data[index]),
                  title: SingleChildScrollView(
                    controller: ScrollController(),
                    scrollDirection: Axis.horizontal,
                    child: Text(data[index].name),
                  ),
                  onChanged: (bool? bool) {
                    if (bool != null) {
                      if (bool) {
                        filterParams.addScope(data[index]);
                      } else {
                        filterParams.removeScope(data[index]);
                      }
                    }
                  },
                );
              },
              childCount: data.length,
              addAutomaticKeepAlives: true,
            ),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
              child: ErrorWidget(AppLocalizations.of(context)!.generalError));
        } else {
          return const SliverToBoxAdapter(child: LoadingWidget());
        }
      },
    );
  }
}
