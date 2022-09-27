import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

  final List<YoutubePlayerController> _youtubeControllers = [];

  @override
  void initState() {
    event = TimelineEventService.fetchEvent(id: widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.timelineDetailsScreen,
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
                          return ListView.builder(
                            addAutomaticKeepAlives: true,
                            itemCount: (snapshot.data?.length)! + 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return ListTile(
                                  //leading: snapshotEvent.scopeIcon,
                                  title: Text(snapshotEvent.title),
                                  subtitle: Text(subtitleText),
                                );
                              } else if (index == 1) {
                                return const Divider(
                                  color: Colors.white,
                                );
                              } else {
                                return buildContent(snapshot.data![index - 2]);
                              }
                            },
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
              return LoadingWidget();
            }
          }),
    );
  }

  Widget buildContent(Content content) {
    if (content.link.contains("youtube")) {
      YoutubePlayerController _controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(content.link)!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          loop: false,
          hideControls: false,
          isLive: false,
          forceHD: false,
        ),
      );
      return Wrap(
        children: [
          YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
              ),
              builder: (context, player) => player),
        ],
      );
    } else if (content.link.contains("www.flickr.com/photos")) {
      return FutureBuilder<FlickrPhoto>(
          future: FlickrUrlConverterService.getPhotofromFlickrURL(content.link),
          builder: (BuildContext context, AsyncSnapshot<FlickrPhoto> snapshot) {
            if (snapshot.hasData) {
              FlickrPhoto photo = snapshot.data!;
              return Card(
                color: IscteTheme.iscteColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(photo.title),
                      ),
                      InteractiveViewer(
                        child: CachedNetworkImage(
                            imageUrl: photo.url,
                            fadeOutDuration: const Duration(seconds: 1),
                            fadeInDuration: const Duration(seconds: 3),
                            progressIndicatorBuilder: (BuildContext context,
                                    String url, DownloadProgress progress) =>
                                const LoadingWidget()),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return NetworkError(onRefresh: () {});
            } else {
              return const LoadingWidget();
            }
          });
    } else {
      return ListTile(
        leading: content.contentIcon,
        title: Text(content.description ?? ""),
        subtitle: Text(content.link),
        onTap: () {
          _logger.d(content);
          if (content.link.isNotEmpty) {
            HelperMethods.launchURL(content.link);
          }
        },
      );
    }
  }

  void launchLink(String link) async {
    var url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void deactivate() {
    for (YoutubePlayerController controller in _youtubeControllers) {
      controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    for (YoutubePlayerController controller in _youtubeControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
