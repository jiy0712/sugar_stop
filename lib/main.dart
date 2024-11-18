import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'bmi.dart';
import 'record.dart';
import 'doctor.dart';
import 'graph.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'sugarstop',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isshow = true;
  int size = 0;
  int _selectIndex = 2;

  final List<Widget> _p = [
    const Center(child: Text('설정 페이지')),
    const GraphPage(),
    const Center(child: Text('홈 페이지')),
    const DoctorPage(),
    const Center(child: Text('마이 페이지')),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isshow) {
        _popup(context);
      }
    });
    _loadSugarG();
  }

  Future<void> _loadSugarG() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      size = prefs.getInt('sugarG') ?? 0;
    });
  }

  Future<void> _updateSugarG(int additionalSugar) async {
    setState(() {
      size += additionalSugar;
      if (size > 60) {
        _warning();
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sugarG', size);
  }

  void _popup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("BMI 검사"),
          content: const Text("BMI 검사 하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _isshow = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text("X"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BmiPage()),
                );
              },
              child: const Text("O"),
            ),
          ],
        );
      },
    );
  }

  void _warning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("경고"),
          content: const Text("당 섭취량이 60g을 초과했습니다!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _t(int index) {
    setState(() {
      _selectIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MM/dd').format(now);

    return Scaffold(
      body: Stack(
        children: [
          _selectIndex == 2
              ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontFamily: 'CustomFontTitle',
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '월요일',
                      style: TextStyle(
                        fontFamily: 'CustomFontWeek',
                        fontSize: 15,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '1일차',
                      style: TextStyle(
                        fontFamily: 'CustomFontDay',
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),
                    CircleAvatar(
                      radius: (size * 2).toDouble(),
                      backgroundColor: Colors.orange.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'sugar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${size}g',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecordPage(),
                          ),
                        );

                        if (result != null && result is int) {
                          _updateSugarG(result);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      child: const Text(
                        '식단 기록하기',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
              : _p[_selectIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectIndex,
        onTap: _t,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: '전문가',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '지영',
          ),
        ],
        selectedItemColor: Color(0xFFF8D5B8),
        unselectedItemColor: Colors.black,
      ),
    );
  }
}
