import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:iscte_spots/pages/home/nav_drawer/page_routes.dart';
import 'package:iscte_spots/services/routes/timeline_route_information_parser.dart';
import 'package:iscte_spots/services/routes/timeline_router_delegate.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

const int puzzlePageIndex = 0;
const int qrPageIndex = 1;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  usePathUrlStrategy();
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
      darkTheme: IscteTheme.darkThemeData,
      theme: IscteTheme.lightThemeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerDelegate: TimelineRouterDelegate(),
      routeInformationParser: TimelineRouteInformationParser(),
      themeMode: ThemeMode.dark,

      //home: TimelinePage(),
      //onGenerateRoute: generatedRoutes,
      //routes: PageRouter.routes,
      /*onUnknownRoute: (settings) => PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                UnknownPage()),
        initialRoute: PageRouter.initialRoute,
        */
    );
  }
}

Route? generatedRoutes(RouteSettings routeSettings) {
  Widget widget =
      PageRouter.resolve(routeSettings.name ?? "", routeSettings.arguments);
  //var buildPageAsync = await _buildPageAsync(page: widget);
  return PageRouteBuilder(
    transitionDuration: const Duration(seconds: 1),
    maintainState: true,
    pageBuilder: (context, animation, secondaryAnimation) => widget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Animatable<Offset> tween =
          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
        CurveTween(curve: Curves.ease),
      );
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
