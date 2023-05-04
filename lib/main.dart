import 'package:flutter/material.dart';
import 'api_service.dart';
import 'Tabbar/date_planning.dart';
import 'Tabbar/love_advice.dart'; // 追加: import LoveAdvicePage
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPT Love & Date Planner',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
        popupMenuTheme: PopupMenuThemeData(),
      ),
      home: MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  String? dropdownValue;
  ApiService _apiService = ApiService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15, top: 70),
                  child: TabBar(
                    indicatorWeight: 0.1,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.pinkAccent,
                    ),
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    tabs: [
                      Padding(
                        padding: const EdgeInsets.all(2.10),
                        child: SizedBox(
                          width: 100,
                          child: Tab(
                            text: '恋愛相談',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Tab(
                          text: 'デートプランニング',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 140.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  LoveAdvicePage(apiService: _apiService),
                  DatePlanningInputFields(
                    apiService: _apiService,
                    apiFunction: _apiService.getDatePlan,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
