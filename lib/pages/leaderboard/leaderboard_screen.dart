import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LeaderBoardPage());
}

class LeaderBoardPage extends StatefulWidget {
  static const pageRoute = "/leaderboard";

  const LeaderBoardPage({Key? key}) : super(key: key);

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  Logger logger = Logger();


  static const List<Widget> _pages = <Widget>[
    GlobalLeaderboard(),
    AffiliationLeaderboard(),
  ];

  //Page Selection Mechanics
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // APP BAR THEME
    AppBarTheme appBarTheme = const AppBarTheme(
      elevation: 0, // This removes the shadow from all App Bars.
      centerTitle: true,
      toolbarHeight: 55,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );

    var darkTheme = ThemeData.dark();

    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: const Color.fromRGBO(14, 41, 194, 1),
          appBarTheme: appBarTheme.copyWith(
            backgroundColor: const Color.fromRGBO(14, 41, 194, 1),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Color.fromRGBO(14, 41, 194, 1),
              statusBarIconBrightness: Brightness.light, // For Android (dark icons)
              statusBarBrightness: Brightness.light, // For iOS (dark icons)
            ),
          ),
      ),
      darkTheme: ThemeData.dark().copyWith(
          appBarTheme: appBarTheme.copyWith(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: darkTheme.bottomAppBarColor,
              statusBarIconBrightness: Brightness.light, // For Android (dark icons)
              statusBarBrightness: Brightness.light, // For iOS (dark icons)
            ),
          )
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Leaderboard"),//AppLocalizations.of(context)!.quizPageTitle)
        ),
        drawer: const NavigationDrawer(),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.globe),
              label: 'Global',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Afiliação',
            ),
          ],
          currentIndex: _selectedIndex,
            //selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),//Scaffold
      debugShowCheckedModeBanner: false,
    ); //MaterialApp
  }
}

class AffiliationLeaderboard extends StatefulWidget {
  const AffiliationLeaderboard({Key? key}) : super(key: key);

  @override
  _AffiliationLeaderboardState createState() => _AffiliationLeaderboardState();
}

class _AffiliationLeaderboardState extends State<AffiliationLeaderboard> {

  String selectedType = "-";
  String selectedAffiliation = "-";
  bool firstSearch = false;
  bool canSearch = false;

  Map<String, dynamic> maps = {"Aluno":"student", "Docente":"professor", "Investigador":"researcher", "Funcionário":"staff"};


  late Map<String, dynamic> affiliationMap;
  bool readJson = false;

  Future<List<dynamic>> fetchLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.124/api/users/leaderboard?type=${maps[selectedType]}&affiliation=$selectedAffiliation'));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.body.codeUnits));
      }
      throw Exception('Failed to load leaderboard');
    }finally{
    }
  }

  Future<String> loadAffiliationData() async {
    var jsonText = await rootBundle.loadString('Resources/affiliations_abbr.json');
    readJson = true;
    setState(() => affiliationMap = json.decode(utf8.decode(jsonText.codeUnits)));
    return 'success';
  }

  @override
  void initState() {
    super.initState();
    loadAffiliationData();
  }

  @override
  Widget build(BuildContext context) {
      return Column(
        children: [
          const SizedBox( // Container to hold the description
            height: 50,
            child: Center(
              child: Text("Top 10 por Afiliação",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  )
              ),
            ),
          ),
          if (readJson) Row(
            children: [
              SizedBox(
                width:120,
                child: Column(
                  children: [
                    const Text("Tipo"),
                    DropdownButton(
                      isExpanded: true,
                      value: selectedType,
                      items:
                      (affiliationMap.keys.toList()).map((type) =>
                          DropdownMenuItem<String>(
                              value: type, child: Text(type,overflow: TextOverflow.ellipsis)),
                      ).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          canSearch=false;
                          selectedType = newValue!;
                          selectedAffiliation = "-";
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width:120,
                child: Column(
                  children: [
                    const Text("Sub-tipo"),
                    DropdownButton(
                      isExpanded: true,
                      value: selectedAffiliation,
                      items:
                      (affiliationMap[selectedType] as List<dynamic>).map((
                          aff) =>
                          DropdownMenuItem<String>(
                              value: aff, child: Text(aff,overflow: TextOverflow.ellipsis)),
                      ).toList(),
                      onChanged: (selectedType == "-") ? null : (String? newValue) {
                        if(newValue != "-"){
                          setState(() {
                            canSearch=true;
                            firstSearch=true;
                            selectedAffiliation = newValue!;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width:120,
                child: Column(
                  children: [
                    const Text("Afiliação"),
                    DropdownButton(
                      isExpanded:true,
                      value: selectedAffiliation,
                      items:
                      (affiliationMap[selectedType] as List<dynamic>).map((
                          aff) =>
                          DropdownMenuItem<String>(
                              value: aff, child: Text(aff,overflow: TextOverflow.ellipsis)),
                      ).toList(),
                      onChanged: (selectedType == "-") ? null : (String? newValue) {
                        if(newValue != "-"){
                          setState(() {
                            canSearch=true;
                            firstSearch=true;
                            selectedAffiliation = newValue!;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          if(canSearch) Expanded(child: LeaderboardList(key: UniqueKey(),fetchFunction: fetchLeaderboard))
          else if(!firstSearch && readJson) const Expanded(child: Center(child:Text("Selecione a afiliação pretendida", style: TextStyle(
              fontSize: 16
          )))),
        ],
      );
  }
}

class GlobalLeaderboard extends StatelessWidget{
  const GlobalLeaderboard({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.124/api/users/leaderboard'));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.body.codeUnits));
      }
      throw Exception('Failed to load leaderboard');
    }finally{
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(  // Container to hold the description
          height: 50,
          child: Center(
            child: Text( "Top 10 Global",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                )
            ),
          ),
        ),
        Expanded(child: LeaderboardList(fetchFunction: fetchLeaderboard)),
      ],
    );
  }
}


class LeaderboardList extends StatefulWidget {

  final Future<List<dynamic>> Function() fetchFunction;

  const LeaderboardList({Key? key, required this.fetchFunction}) : super(key: key);

  @override
  _LeaderboardListState createState() => _LeaderboardListState();

}

class _LeaderboardListState extends State<LeaderboardList> {

  late Future<List<dynamic>> futureLeaderboard;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureLeaderboard = widget.fetchFunction();
  }

  Future<List<dynamic>> fetchLeaderboard() async {
    try {
      isLoading = true;
      final response = await http.get(Uri.parse('http://192.168.1.124/api/users/leaderboard'));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.body.codeUnits));
      }
      throw Exception('Failed to load leaderboard');
    }finally{
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureLeaderboard,
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          var items = snapshot.data as List<dynamic>;
          return RefreshIndicator(
            onRefresh: () async{
              setState(() {
                if(!isLoading) {
                  futureLeaderboard = widget.fetchFunction();
                }
              });
            },
            child: items.isEmpty ? const Center(child:Text("Não foram encontrados resultados")) :
            ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left:10.0, right:10.0),
                  child: Card(
                    child: ListTile(
                      title: Text(utf8.decode(utf8.encode(items[index]["name"])),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          )
                      ),
                      subtitle: Text("Pontos: ${items[index]["points"]} \nAfiliação: ${items[index]["affiliation"]}"),
                      //isThreeLine: true,
                      //dense:true,
                      minVerticalPadding: 10.0,
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            index == 0 ? Image.asset("Resources/Img/LeaderBoardIcons/gold_medal.png") :
                            index == 1 ? Image.asset("Resources/Img/LeaderBoardIcons/silver_medal.png") :
                            index == 2 ? Image.asset("Resources/Img/LeaderBoardIcons/bronze_medal.png") :
                              Container(),
                            const SizedBox(width:10),
                            Text( "#${index+1}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                )
                            ),
                          ]),
                    ),
                  ),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Ocorreu um erro a descarregar os dados'),
            ),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('Tocar aqui para recarregar', style: TextStyle(fontWeight: FontWeight.bold),),
            ),

          ];
        } else {
          children = const <Widget>[
            SizedBox(
              child: CircularProgressIndicator.adaptive(),
              width: 60,
              height: 60,
            ),
          ];
        }
        return GestureDetector(
          onTap: () {
            setState(() {
              if(!isLoading){
                futureLeaderboard = widget.fetchFunction();
              }
            });
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ),
        );
      },

    );
  }
}

