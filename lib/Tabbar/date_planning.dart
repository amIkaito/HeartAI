import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DatePlanningInputFields extends StatefulWidget {
  final ApiService apiService;
  final Future<String> Function(Map<String, String>) apiFunction;

  DatePlanningInputFields({
    required this.apiService,
    required this.apiFunction,
  });

  @override
  _DatePlanningInputFieldsState createState() =>
      _DatePlanningInputFieldsState();
}

class _DatePlanningInputFieldsState extends State<DatePlanningInputFields> {
  TextEditingController _locationController = TextEditingController();
  TextEditingController _hobbiesController = TextEditingController();
  TextEditingController _avoidController = TextEditingController();
  TextEditingController _additionalInfoController = TextEditingController();

  String _outputText = '';
  bool _isLoading = false;
  String? _selectedWeather = null; // 初期値をnullに設定
  String? _selectedTemperature = null; // ;
  String? _selectedStartTime = null; // ;
  String? _selectedDuration = null; // ;
  String? _selectedMaleAge = null;
  String? _selectedFemaleAge = null;
  String? _selectedDatePurpose = null;
  String? _selectedBudget = null;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String createPrompt() {
    return 'あなたは恋愛相談10年のプロフェッショナルです。どの年齢からの相談でも適切に年齢に合ったデートプランの提案ができます。以下の情報をもとに、デートプランを2つ提案してください。提出方法の形式も以下に記載してあるのでその記載方法を使用してください。\n\n'
        '男性の年齢: $_selectedMaleAge\n'
        '女性の年齢: $_selectedFemaleAge\n'
        'デートの目的: $_selectedDatePurpose\n'
        '予算: $_selectedBudget\n'
        '天候: $_selectedWeather\n'
        '行きたい場所: $_locationController.text\n'
        '気温: $_selectedTemperature\n'
        'デートの開始時間: $_selectedStartTime\n'
        'デートの所要時間: $_selectedDuration\n'
        'その他の情報: $_additionalInfoController.text\n'
        '相手の趣味: $_hobbiesController.text\n'
        'デートで避けたいもの: $_avoidController.text\n\n'
        'それぞれのデートプランは、以下の形式で提案してください：\n\n'
        'プラン1:\n'
        '  概要:\n'
        '  1つ目の行動:\n'
        '  2つ目の行動:\n'
        '  3つ目の行動:\n\n'
        'プラン2:\n'
        '  概要:\n'
        '  1つ目の行動:\n'
        '  2つ目の行動:\n'
        '  3つ目の行動:\n\n';
  }

  void _resetInputFields() {
    _locationController.clear();
    _hobbiesController.clear();
    _avoidController.clear();
    _additionalInfoController.clear();

    setState(() {
      _selectedWeather = null;
      _selectedTemperature = null;
      _selectedStartTime = null;
      _selectedDuration = null;
      _selectedMaleAge = null;
      _selectedFemaleAge = null;
      _selectedDatePurpose = null;
      _selectedBudget = null;
    });
  }

  Future<void> _sendRequest() async {
    List<String> errorMessages = [];
    if (_selectedWeather == null) {
      errorMessages.add("「天候」を選択してください");
    }
    if (_selectedTemperature == null) {
      errorMessages.add("「気温」を選択してください");
    }
    if (_selectedStartTime == null) {
      errorMessages.add("「デートの開始時間」を選択してください");
    }
    if (_selectedDuration == null) {
      errorMessages.add("「デートの所要時間」を選択してください");
    }
    if (_selectedMaleAge == null) {
      errorMessages.add("「男性の年齢」を選択してください");
    }
    if (_selectedFemaleAge == null) {
      errorMessages.add("「女性の年齢」を選択してください");
    }
    if (_selectedDatePurpose == null) {
      errorMessages.add("「デートの目的」を選択してください");
    }
    if (_selectedBudget == null) {
      errorMessages.add("「予算」を選択してください");
    }
    if (_locationController.text.isEmpty) {
      errorMessages.add("「行きたい場所」を入力してください");
    }
    if (_hobbiesController.text.isEmpty) {
      errorMessages.add("「相手の趣味」を入力してください");
    }
    if (_avoidController.text.isEmpty) {
      errorMessages.add("「デートで避けたいもの」を入力してください");
    }
    if (_additionalInfoController.text.isEmpty) {
      errorMessages.add("「その他の情報」を入力してください");
    }

    if (errorMessages.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("注意"),
            content: Text(errorMessages.join('\n')),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _isLoading = true;
      });

      final inputMapNullable = {
        '男性の年齢': _selectedMaleAge,
        '女性の年齢': _selectedFemaleAge,
        'デートの目的': _selectedDatePurpose,
        '予算': _selectedBudget,
        'デートの開始時間': _selectedStartTime,
        'デートの所要時間': _selectedDuration,
        '行きたい場所': _locationController.text,
        '天候': _selectedWeather,
        '気温': _selectedTemperature,
        '相手の趣味': _hobbiesController.text,
        'デートで避けたいもの': _avoidController.text,
        'その他の情報': _additionalInfoController.text,
      };

      // nullでない値を持つエントリのみを新しいMapに追加する
      final inputMap = Map<String, String>.fromEntries(
        inputMapNullable.entries.where((entry) => entry.value != null).map(
              (entry) => MapEntry(entry.key, entry.value!),
            ),
      );

      try {
        final response = await widget.apiService.getDatePlan(inputMap);
        setState(() {
          _outputText = response;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _outputText = 'エラーが発生しました。再試行してください。';
          _isLoading = false;
        });
      }

      _resetInputFields(); // ここでリセット関数を呼び出す
    }
  }

  Widget _buildOutputField() {
    List<TextSpan> formattedOutputTextSpans = _formatOutputText(_outputText);

    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '恋愛先生',
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 8),
              if (_isLoading)
                LoadingAnimationWidget.threeArchedCircle(
                  color: Colors.pinkAccent,
                  size: 16,
                ),
            ],
          ),
          SizedBox(height: 8), // 恋愛先生の名前と回答の間にスペースを追加
          RichText(
            text: TextSpan(
              children: formattedOutputTextSpans,
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _formatOutputText(String outputText) {
    List<String> lines = outputText.split('\n');
    List<TextSpan> textSpans = [];

    for (String line in lines) {
      if (line.startsWith(
        'プラン',
      )) {
        textSpans.add(
          TextSpan(
            text: line,
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900),
          ),
        );
      } else if (line.startsWith('概要:') ||
          line.startsWith('1つ目の行動:') ||
          line.startsWith('2つ目の行動:') ||
          line.startsWith('3つ目の行動:')) {
        textSpans.add(
          TextSpan(
            text: line,
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900),
          ),
        );
      } else {
        textSpans.add(
          TextSpan(
            text: line,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        );
      }
      textSpans.add(TextSpan(text: '\n\n'));
    }
    return textSpans;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.pinkAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromRGBO(68, 138, 255, 1), Colors.pinkAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8), // 2つのドロップダウンメニュー間のスペース
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            height: 177,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Step1 天気＆気温を選んでね！',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    DropdownButton<String>(
                                      value: _selectedWeather,
                                      hint: Center(child: Text('天候を選択')),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedWeather = newValue;
                                        });
                                      },
                                      items: <String>['晴れ', '曇り', '雨', '雪']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 8), // 2つのドロップダウンメニュー間のスペース
                                    DropdownButton<String>(
                                      value: _selectedTemperature,
                                      hint: Text('気温を選択'),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedTemperature = newValue;
                                        });
                                      },
                                      items: <String>[
                                        '寒い',
                                        '涼しい',
                                        '適温',
                                        '暖かい',
                                        '暑い'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8), // 2つのカード間のスペース
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Step2 ふたりの年齢を選択！',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButton<String>(
                                    value: _selectedMaleAge,
                                    hint: Text('男性の年齢を選択'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedMaleAge = newValue;
                                      });
                                    },
                                    items: List<String>.generate(
                                            100, (i) => (i + 18).toString())
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 8), // 2つのドロップダウンメニュー間のスペース
                                  DropdownButton<String>(
                                    value: _selectedFemaleAge,
                                    hint: Text('女性の年齢を選択'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedFemaleAge = newValue;
                                      });
                                    },
                                    items: List<String>.generate(
                                            100, (i) => (i + 18).toString())
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    // 2つのドロップダウンメニュー間のスペース
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Step3 デートの目的＆予算を設定！',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButton<String>(
                                    value: _selectedDatePurpose,
                                    hint: Text('デートの目的を選択'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedDatePurpose = newValue;
                                      });
                                    },
                                    items: <String>[
                                      '友達として',
                                      '恋人として',
                                      '結婚を考える相手として'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButton<String>(
                                    value: _selectedBudget,
                                    hint: Text('予算を選択'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedBudget = newValue;
                                      });
                                    },
                                    items: <String>[
                                      '5,000円以下',
                                      '5,000円～10,000円',
                                      '10,000円～20,000円',
                                      '20,000円以上'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Step4 開始時間＆デートの長さを決めよう',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButton<String>(
                                    value: _selectedStartTime,
                                    hint: Text('デート開始時間を選択'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedStartTime = newValue;
                                      });
                                    },
                                    items: <String>['午前中', '昼', '夕方', '夜']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButton<String>(
                                    value: _selectedDuration,
                                    hint: Text('デート所要時間を選択'),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedDuration = newValue;
                                      });
                                    },
                                    items: <String>[
                                      '1時間',
                                      '2時間',
                                      '3時間',
                                      '半日',
                                      '1日'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Step5 行きたい場所を決めよう！',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                TextField(
                                  controller: _locationController,
                                  decoration: InputDecoration(
                                    hintText: 'デートの場所 (例: 東京タワー)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Step6 その他の情報を記入しよう！　',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                TextField(
                                  controller: _additionalInfoController,
                                  decoration: InputDecoration(
                                    hintText: '特別なイベント(例:誕生日 クリスマス)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Step7 相手の趣味を把握しよう！',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                TextField(
                                  controller: _hobbiesController,
                                  decoration: InputDecoration(
                                    hintText: '映画鑑賞、カフェ巡り、アウトドアなど',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Step8 デートで避けたいものをリストアップ！',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                TextField(
                                  controller: _avoidController,
                                  decoration: InputDecoration(
                                    hintText: '過度な運動など',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                await _sendRequest();
                              },
                        child: Text('デートプランニングしてもらう'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.pinkAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontFamily: 'DancingScript',
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildOutputField(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
