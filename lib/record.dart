import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("홈 화면"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecordPage(),
                  ),
                );
              },
              child: const Text("기록 화면 열기"),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  int foodCount = 0;
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoodCount();
  }

  Future<void> _loadFoodCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      foodCount = prefs.getInt('foodCount') ?? 0;
    });
  }

  Future<void> _saveFoodCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('foodCount', count);
  }

  void _goToHome(BuildContext context, [int? sugarG]) {
    Navigator.pop(context, sugarG);
  }

  void _showFoodAlert(BuildContext context, String food) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("알림"),
          content: Text("$food 당 5g 추가입니다."),
          actions: [
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

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MM/dd').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('식단 & 당 기록'),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 16),
              const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/foodcolor.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '음식 먹은 횟수',
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          '$foodCount',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              foodCount++;
                              _saveFoodCount(foodCount);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _foodController,
                decoration: InputDecoration(
                  hintText: '먹은 음식과 양을 입력해주세요 Ex. 김치찌개 1인분',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _showFoodAlert(context, value); // 입력값 알림창 띄우기
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sugarController,
                decoration: InputDecoration(
                  hintText: '당 g을 숫자만 입력해주세요 Ex. 10',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check_circle),
                    onPressed: () {
                      int sugarG = int.tryParse(_sugarController.text) ?? 0;
                      _goToHome(context, sugarG);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) {
                  int sugarG = int.tryParse(value) ?? 0;
                  _goToHome(context, sugarG);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
