import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/models/flickr/flickr_photo.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/services/flickr/flickr_url_converter_service.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TimeLineDetailsPage extends StatefulWidget {
  const TimeLineDetailsPage({
    required this.eventId,
    Key? key,
  }) : super(key: key);
  final int eventId;
  static const String pageRoute = "event";
  static const ValueKey pageKey = ValueKey(pageRoute);

  @override
  State<TimeLineDetailsPage> createState() => _TimeLineDetailsPageState();
}

class _TimeLineDetailsPageState extends State<TimeLineDetailsPage> {
  final double textweight = 2;
  final Logger _logger = Logger();
  late final Future<Event> event;
  late final Future<String> eventTitle;
  final List<YoutubePlayerController> _videoControllers = [];

  @override
  void initState() {
    event = TimelineEventService.fetchEvent(id: widget.eventId);
    eventTitle = event.then((value) => value.title);
  }

  void addVideoController(YoutubePlayerController controller) {
    _videoControllers.add(controller);
  }

  Widget contentListChildBuilder(context, index, snapshot) {
    return TimelineDetailContent(
      content: snapshot.data![index],
      isEven: index % 2 == 0,
      addVideoControllerCallback: addVideoController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        middle: FutureBuilder<String>(
            future: eventTitle,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text("Details: ${snapshot.data!}");
              } else {
                return const Text("Details");
              }
            }),
        leading: const DynamicBackIconButton(),
      ),
      body: FutureBuilder<Event>(
          future: event,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Event snapshotEvent = snapshot.data!;
              Future<List<Content>> allContentFromEvent =
                  snapshotEvent.getContentList;
              Future<List<Topic>> allTopicFromEvent =
                  snapshotEvent.getTopicsList;
              String subtitleText = "id: ${snapshotEvent.id}";
              allTopicFromEvent.then((value) {
                subtitleText +=
                    "; topics: ${value.map((e) => e.title ?? "").join(", ")}";
              });
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: FutureBuilder<List<Content>>(
                      future: allContentFromEvent,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          snapshot.data!.sort((Content a, Content b) {
                            if (a.type != null && b.type != null) {
                              return b.type!.index - a.type!.index;
                            } else {
                              return b.id - a.id;
                            }
                          });
                          _logger.d(
                              "event: $snapshotEvent\ndata:${snapshot.data!} ");
                          double mediaQuerryWidth =
                              MediaQuery.of(context).size.width;
                          int gridViewCrossAxisCountMediaQuery =
                              mediaQuerryWidth > 500
                                  ? mediaQuerryWidth > 1000
                                      ? 4
                                      : 2
                                  : 1;
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ListTile(
                                  leading: snapshotEvent.scopeIcon,
                                  title: Text(snapshotEvent.title),
                                  subtitle: Text(subtitleText),
                                ),
                                const Divider(
                                  color: Colors.white,
                                ),
                                gridViewCrossAxisCountMediaQuery != 1
                                    ? GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: (snapshot
                                                      .data?.length)! <
                                                  gridViewCrossAxisCountMediaQuery
                                              ? (snapshot.data?.length)!
                                              : gridViewCrossAxisCountMediaQuery,
                                        ),
                                        scrollDirection: Axis.vertical,
                                        addAutomaticKeepAlives: true,
                                        shrinkWrap: true,
                                        itemCount: (snapshot.data?.length)!,
                                        itemBuilder: (context, index) {
                                          return contentListChildBuilder(
                                              context, index, snapshot);
                                        })
                                    : ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        addAutomaticKeepAlives: true,
                                        shrinkWrap: true,
                                        itemCount: (snapshot.data?.length)!,
                                        itemBuilder: (context, index) {
                                          return contentListChildBuilder(
                                              context, index, snapshot);
                                        }),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return NetworkError(onRefresh: () {
                            setState(() {
                              allContentFromEvent =
                                  snapshotEvent.getContentList;
                            });
                          });
                        } else {
                          return const LoadingWidget();
                        }
                      }),
                ),
              );
            } else {
              return const LoadingWidget();
            }
          }),
    );
  }

  @override
  void deactivate() {
    for (YoutubePlayerController controller in _videoControllers) {
      controller.pauseVideo();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    for (YoutubePlayerController controller in _videoControllers) {
      controller.close();
    }
    super.dispose();
  }
}

class TimelineDetailContent extends StatelessWidget {
  TimelineDetailContent(
      {Key? key,
      required this.content,
      required this.isEven,
      required this.addVideoControllerCallback})
      : super(key: key);

  final Content content;
  final bool isEven;
  final void Function(YoutubePlayerController controller)
      addVideoControllerCallback;
  final Logger _logger = Logger();
  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (content.link.contains("youtube")) {
      late YoutubePlayerController controller;
      controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          mute: false,
          showFullscreenButton: true,
          loop: false,
        ),
      )..onInit = () {
          controller.loadVideo(content.link);
          controller.pauseVideo();
        };
      addVideoControllerCallback(controller);

      child = YoutubePlayer(
        controller: controller,
      );
    } else if (content.link.contains("www.flickr.com/photos")) {
      child = FutureBuilder<FlickrPhoto>(
          future: FlickrUrlConverterService.getPhotofromFlickrURL(content.link),
          builder: (BuildContext context, AsyncSnapshot<FlickrPhoto> snapshot) {
            if (snapshot.hasData) {
              FlickrPhoto photo = snapshot.data!;

              return Expanded(
                child: CachedNetworkImage(
                  fit: BoxFit.contain,
                  height: 100,
                  imageUrl: photo.url,
                  fadeOutDuration: const Duration(seconds: 1),
                  fadeInDuration: const Duration(seconds: 3),
                  progressIndicatorBuilder: (BuildContext context, String url,
                          DownloadProgress progress) =>
                      const LoadingWidget(),
                ),
              );
            } else if (snapshot.hasError) {
              return NetworkError(onRefresh: () {});
            } else {
              return const LoadingWidget();
            }
          });
    } else {
      child = null;
    }
    return GridTile(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                _logger.d("Tapped $content");
                if (content.link.isNotEmpty) {
                  HelperMethods.launchURL(content.link);
                }
              },
              tileColor: isEven ? IscteTheme.iscteColor : Colors.transparent,
              leading: content.contentIcon,
              title: Text(content.description ?? content.link,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            if (child != null) child,
          ],
        ),
      ),
    );
  }
}
