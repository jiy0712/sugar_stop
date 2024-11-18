import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({Key? key}) : super(key: key);

  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final List<Map<String, String>> _m = [];
  final TextEditingController _c = TextEditingController();

  void _send() {
    if (_c.text.trim().isEmpty) return;

    String Time = DateFormat('HH:mm').format(DateTime.now());

    setState(() {
      _m.add({
        "message": _c.text.trim(),
        "time": Time,
        "isReply": "false"
      });
      _c.clear();
    });

    Future.delayed(const Duration(seconds: 1), _r);
  }

  void _r() {
    String Time = DateFormat('HH:mm').format(DateTime.now());
    String lm = _m.last["message"] ?? "";
    String rm;

    if (lm.contains('안녕') || lm.contains('hi') || lm.contains('hello') || lm.contains('하이')) {
      rm = "안녕하세요. 저는 당신을 위한 당 전문가입니다 ~! \n 질문을 하고 싶다면 '질문'을, 고민상담을 받고 싶다면 '고민', 그 밖의 대화는 '기타'를 보내주세요 ~!";
    }
    else if (lm.contains('질문')) {
      rm = "네! 저에게 질문해주세요 ~!";
    }
    else if (lm.contains('하루 당')) {
      rm = "하루 적정 당류는 WHO 성인 기준으로는 약 50g 이하의 당류 섭취를 권고합니다.";
    }
    else if (lm.contains('당뇨 하루 당')) {
      rm = "하루 적정 당류 섭취량: WHO 성인 기준으로 하루 당류 섭취량은 약 50g 이하가 권장돼요.\n당뇨가 의심되거나 당뇨병이 있다면 25g 이하가 더 좋다고 해요.";
    }
    else if (lm.contains('당 줄')) {
      rm = "당류 섭취를 줄이려면 가공식품을 피하고, 제품의 영양 성분을 확인해서 건강한 식습관을 유지하는 게 중요해요.\n규칙적인 식사를 통해 혈당을 안정적으로 관리하는 것도 중요한 팁이에요!";
    }
    else if (lm.contains('과일 당')) {
      rm = "당 함량이 높은 과일은 바나나, 망고, 포도, 자두, 수박 등이 있어요. 반면, 사과, 배, 블루베리, 라즈베리는 당분이 적어서 더 좋은 선택이에요.\n하루 권장 과일 섭취량은 200g을 넘지 않도록 해주세요.";
    }
    else if (lm.contains('당 건강')) {
      rm = "당 섭취를 적정량으로 줄이면 체중 관리나 혈당 조절, 심혈관 건강, 정신 건강에 긍정적인 영향을 줄 수 있어요.\n반대로 당 섭취를 늘리면 비만, 당뇨병, 심혈관 질환, 치아 건강 악화 등 부정적인 영향을 줄 수 있답니다.";
    }
    else if (lm.contains('가공')) {
      rm = "가공식품은 가능한 피하는 게 좋지만, 당 함량이 낮은 제품을 선택하는 게 좋다고 알려져 있어요.";
    }
    else if (lm.contains('BMI')) {
      rm = "BMI에 따라 권장되는 당 섭취량이 달라요. 예를 들어, BMI가 18.5 이하일 땐 45g, 18.5에서 24.9는 50g, 25에서 29.9는 45g, 30 이상은 40g이 적당하다고 해요.\n하지만 개인의 상태에 따라 다를 수 있으니 전문가와 상담하는 게 중요해요!";
    }
    else if (lm.contains('고민')) {
      rm = "고민을 말씀해주세요, 들어드릴게요!";
    }
    else if (lm.contains('이야..')) {
      rm = "그거 정말 고민될 수 있죠. 어떻게 해결할 수 있을지 함께 생각해볼까요?";
    }
    else if (lm.contains('ㅜㅜ')) {
      rm = "ㅠㅠ 무슨 일이 있었나요? 제가 조금이라도 도움이 될 수 있으면 좋겠네요 ㅠㅠ";
    }
    else if (lm.contains('기타')) {
      rm = "네! 뭐든 대화해봐요 ~!";
    }
    else if (lm.contains('몇살')) {
      rm = "저는 나이를 가진 존재는 아니에요!\n대신 언제든지 도움이 될 수 있는 정보나 이야기를 나눌 준비가 되어 있답니다!";
    }
    else if (lm.contains('누구')) {
      rm = "저는 당 전문가 챗봇입니다!\n언제든지 도움이 될 수 있는 정보나 이야기를 나눌 준비가 되어 있답니다!";
    }
    else {
      rm = "답변을 분석할 수 없습니다. 다시 입력해 주세요.";
    }

    setState(() {
      _m.add({
        "message": rm,
        "time": Time,
        "isReply": "true"
      });
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '당 전문가',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _m.length,
                itemBuilder: (context, index) {
                  bool isReply = _m[index]["isReply"] == "true";

                  return Align(
                    alignment: isReply ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isReply ? Colors.blue.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _m[index]["message"]!,
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _m[index]["time"]!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _c,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
