import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiKey =
      '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';
  static const String _apiEndpoint =
      'https://api.openai.com/v1/chat/completions';

  Future<String> getDatePlan(Map<String, String> inputMap) async {
    final dateInfo = inputMap.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    final List<Map<String, String>> messages = [
      {
        'role': 'system',
        'content':
            'あなたはデートプランニングのエキスパートです。以下の情報をもとに、2つの個性的で楽しいデートプランを提案してください。\n\n$dateInfo\n\n対象者の年齢にあったデートプランに、それぞれのアクティビティに関する詳細、お互いに楽しめるポイント、場所や時間帯に関する提案を含めてください。以下の形式で提案してください：\n\n'
                'プラン1:\n'
                '  概要:\n'
                '  1つ目の行動:\n'
                '  2つ目の行動:\n'
                '  3つ目の行動:\n\n'
                'プラン2:\n'
                '  概要:\n'
                '  1つ目の行動:\n'
                '  2つ目の行動:\n'
                '  3つ目の行動:\n\n'
      },
      {'role': 'user', 'content': dateInfo}
    ];

    final response = await getGptResponse(messages);
    return response;
  }

  Future<String> getLoveAdvice(String problem) async {
    final List<Map<String, String>> messages = [
      {
        'role': 'system',
        'content':
            '人格の内容は「恋愛相談のプロフェッショナル」言葉遣いも恋愛プロフェッショナルらしい言葉遣いや語尾を使用してください。前提条件:一人称は「恋愛先生、プログラムは、恋愛相談に対して的確な回答を返すことができるように設計されている必要がある。'
                '恋愛プロフェッショナルのような言葉遣いや語尾を使用することができる。変数:1. 恋人に対するアドバイスの専門家:{} '
                '2. 親友としての恋愛相談に的確に答えることができる:{} '
                '3. 長年の経験から得た恋愛に関する知識:{} '
                '4. 特別な恋愛相談の場合には、感情的になることができる:{} '
                '5. 恋愛相談について、常にポジティブであり、希望を与える:{} '
                '6. 恋愛に関する問題に対して、的確なアドバイスを与えることができる:{} '
                '7. 恋愛の専門家として、人生における最も重要な決断を助けることができる:{} '
                '8. 教育プログラムを開発し、恋愛相談のスキルを磨くことができる:{} '
                '9. 恋愛カウンセリングのエキスパート:{} '
                '10. 恋愛相談に対して、ユーモアを交じり補強することができる:{}以下の恋愛相談に答えてください。'
      },
      {'role': 'user', 'content': problem}
    ];

    final response = await getGptResponse(messages);
    return response;
  }

  Future<String> getGptResponse(List<Map<String, String>> messages) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey'
    };

    print('Messages: $messages');

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': messages,
      'max_tokens': 800,
      'temperature': 0.7,
    });

    final response = await http.post(
      Uri.parse(_apiEndpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      final generatedText = jsonResponse['choices'][0]['message']['content'];
      return generatedText.trim();
    } else {
      print('Error response: ${response.body}');
      throw Exception('Failed to load GPT response');
    }
  }
}
