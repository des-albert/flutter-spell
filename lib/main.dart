import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpellBee',
      home: SpellForm(),
    );
  }
}

class SpellForm extends StatefulWidget {
  const SpellForm({super.key});

  @override
  State<SpellForm> createState() => _SpellFormState();
}

class _SpellFormState extends State<SpellForm> {
  TextEditingController outerLetters = TextEditingController();
  TextEditingController centerLetter = TextEditingController();

  LineSplitter ls = const LineSplitter();
  int wordLimit = 4;
  int outer = ~0;
  int common = 0;
  int score = 0;
  String base = "";
  String center = "";

  late List<String> results = [];

  bool _resultVisible = false;

  Future<void> _loadData() async {
    String loadedData = await rootBundle.loadString('assets/words.txt');
    List<String> words = ls.convert(loadedData);

    score = 0;

    for (String word in words) {
      int mask = 0;
      int match = 0;
      int center = 0;

      List<int> chars = word.codeUnits;
      for (int p in chars) {
        if (p < 97) {
          mask |= 1 << (p - 65);
        } else {
          mask |= 1 << (p - 97);
        }
      }
      match = mask & outer;
      center = mask & common;
      if (match == 0 && center != 0 && word.length >= wordLimit) {
        results.add(word);
        if (word.length > 4)
          score += word.length;
        else
          score += 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DB\'r SpellBee Solver'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          const Divider(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 60,
                height: 30,
                child: TextField(
                  controller: centerLetter,
                  style: const TextStyle(
                    fontSize: 25,
                    color: Colors.green,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: 'center',
                      hintStyle: TextStyle(fontSize: 15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      contentPadding: EdgeInsets.zero),
                ),
              ),
              Container(
                width: 150,
                height: 30,
                child: TextField(
                  controller: outerLetters,
                  style: const TextStyle(
                    fontSize: 25,
                    color: Colors.deepOrangeAccent,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: 'outer letters',
                      hintStyle: TextStyle(fontSize: 15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      contentPadding: EdgeInsets.zero),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () async {
                  base = outerLetters.text;
                  List<int> chars = base.codeUnits;

                  outer = ~0;
                  for (int p in chars) {
                    if (p < 97) {
                      outer ^= 1 << (p - 65);
                    } else {
                      outer ^= 1 << (p - 97);
                    }
                  }

                  common = 0;
                  center = centerLetter.text;
                  int c = center.codeUnitAt(0);
                  if (c < 97) {
                    common |= 1 << (c - 65);
                  } else {
                    common |= 1 << (c - 97);
                  }

                  outer ^= common;

                  results.clear();

                  await _loadData();

                  setState(() {
                    results.length;
                  });
                  _resultVisible = true;
                },
                child: const Text('Solve'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () async {
                  centerLetter.text = "";
                  outerLetters.text = "";
                  _resultVisible = false;
                  setState(() {});
                },
                child: const Text('Clear'),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Word Length'),
              Radio(
                value: 4,
                groupValue: wordLimit,
                onChanged: (val) {
                  setState(() {
                    wordLimit = val!;
                  });
                },
              ),
              const Text('4'),
              Radio(
                value: 5,
                groupValue: wordLimit,
                onChanged: (val) {
                  setState(() {
                    wordLimit = val!;
                  });
                },
              ),
              const Text('5')
            ],
          ),
          const Divider(
            height: 10,
          ),
          Visibility(
            visible: _resultVisible,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                    '${results.length} words score ${score}'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Visibility(
                    visible: _resultVisible,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 200,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: results.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Text(
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.blueAccent,
                                ),
                                results[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
