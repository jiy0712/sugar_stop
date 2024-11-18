import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BmiPage extends StatelessWidget {
  const BmiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController heightController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    Future<void> calculateBMI(BuildContext context) async {
      final double height = double.tryParse(heightController.text) ?? 0;
      final double weight = double.tryParse(weightController.text) ?? 0;

      if (height > 0 && weight > 0) {
        double bmi;
        String status;

        try {
          final response = await http.post(
            Uri.parse('http://..../bmi'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': '123',
              'height': height,
              'weight': weight,
            }),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            bmi = data['user_data']['bmi'];
          } else {
            throw Exception('Server error: ${response.statusCode}');
          }
        } catch (error) {
          bmi = weight / ((height / 100) * (height / 100));
        }

        if (bmi < 18.5) {
          status = "저체중";
        } else if (bmi < 24.9) {
          status = "정상";
        } else if (bmi < 29.9) {
          status = "과체중";
        } else {
          status = "비만";
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '나의 BMI : ${bmi.toStringAsFixed(2)} ($status)',
                  style: TextStyle(
                    fontSize: 18,
                    color: status == "정상"
                        ? Colors.green
                        : (status == "저체중" ? Colors.blue : Colors.red),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBmiRangeBox('저체중', '~ 18.5', Colors.blue),
                    _buildBmiRangeBox('정상', '18.5~24.9', Colors.green),
                    _buildBmiRangeBox('과체중', '25~29.9', Colors.orange),
                    _buildBmiRangeBox('비만', '30 ~', Colors.red),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context); // Go back to the home screen
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '키 (cm)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '몸무게 (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => calculateBMI(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[100],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              ),
              child: const Text(
                'BMI 확인하기',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiRangeBox(String label, String range, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(range),
      ],
    );
  }
}
