import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/services/routes/timeline_route_information_parser.dart';
import 'package:iscte_spots/services/routes/timeline_router_delegate.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

const int puzzlePageIndex = 0;
const int qrPageIndex = 1;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (details) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Ocorreu um problema!"),
              Text(details.summary.toString()),
            ],
          ),
        ),
      );
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static Future<Widget> _buildPageAsync({required Widget page}) async {
    return Future.microtask(
      () {
        return page;
      },
    );
  }
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      //showSemanticsDebugger: true,
      debugShowCheckedModeBanner: false,
      title: 'IscteSpots',
      //darkTheme: IscteTheme.darkThemeData,
      theme: IscteTheme.lightThemeData,
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerDelegate: TimelineRouterDelegate(),
      routeInformationParser: TimelineRouteInformationParser(),
    );
  }
}
