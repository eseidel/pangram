import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pangram/board_stats.dart';
import 'package:http/http.dart' as http;

class MaxScoreAllPuzzles extends StatelessWidget {
  final List<Bucket> maxScores;
  MaxScoreAllPuzzles(this.maxScores);
  @override
  Widget build(BuildContext context) {
    return BarChart(
      buildBarChartData(),
    );
  }

  BarChartData buildBarChartData() {
    List<BarChartGroupData> barGroups = <BarChartGroupData>[];
    int sum = maxScores.fold(0, (sum, bucket) => sum + bucket.sum);
    for (Bucket bucket in maxScores) {
      barGroups.add(BarChartGroupData(
        x: bucket.first,
        barRods: [
          BarChartRodData(
            y: (bucket.sum.toDouble() / sum),
            colors: [Colors.lightBlueAccent, Colors.greenAccent],
          )
        ],
      ));
    }
    return BarChartData(
      barGroups: barGroups,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) =>
              const TextStyle(color: Color(0xff939393), fontSize: 10),
          margin: 10,
          getTitles: (double value) {
            // This is a hack to try and show fewer lables.
            if (value % 100 < 25) {
              return (value ~/ 100 * 100).toString();
            }
            return "";
          },
        ),
      ),
    );
  }
}

class NumberOfAnswers extends StatelessWidget {
  final List<Bucket> numberOfAnswers;
  NumberOfAnswers(this.numberOfAnswers);
  @override
  Widget build(BuildContext context) {
    return BarChart(
      buildBarChartData(),
    );
  }

  BarChartData buildBarChartData() {
    List<BarChartGroupData> barGroups = <BarChartGroupData>[];
    int sum = numberOfAnswers.fold(0, (sum, bucket) => sum + bucket.sum);
    for (Bucket bucket in numberOfAnswers) {
      barGroups.add(BarChartGroupData(
        x: bucket.first,
        barRods: [
          BarChartRodData(
            y: (bucket.sum.toDouble() / sum),
            colors: [Colors.lightBlueAccent, Colors.greenAccent],
          )
        ],
      ));
    }
    return BarChartData(
      barGroups: barGroups,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) =>
              const TextStyle(color: Color(0xff939393), fontSize: 10),
          margin: 10,
          getTitles: (double value) {
            // This is a hack to try and show fewer lables.
            if (value % 50 < 5) {
              return (value ~/ 50 * 50).toString();
            }
            return "";
          },
        ),
      ),
    );
  }
}

class LetterFrequency extends StatelessWidget {
  final List<WordCount> letterFrequency;
  LetterFrequency(this.letterFrequency);
  @override
  Widget build(BuildContext context) {
    return BarChart(
      buildBarChartData(),
    );
  }

  int letterToInt(String letter) =>
      letter.codeUnits.first - 'a'.codeUnits.first;

  String intToLetter(int offset) =>
      String.fromCharCode('a'.codeUnits.first + offset);

  BarChartData buildBarChartData() {
    List<BarChartGroupData> barGroups = <BarChartGroupData>[];
    int sum = letterFrequency.fold(0, (sum, count) => sum + count.count);
    for (WordCount letterCount in letterFrequency) {
      barGroups.add(BarChartGroupData(
        x: letterToInt(letterCount.word),
        barRods: [
          BarChartRodData(
            y: (letterCount.count.toDouble() / sum),
            colors: [Colors.lightBlueAccent, Colors.greenAccent],
          )
        ],
      ));
    }
    return BarChartData(
      barGroups: barGroups,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) =>
              const TextStyle(color: Color(0xff939393), fontSize: 10),
          margin: 10,
          getTitles: (double value) {
            return intToLetter(value.toInt());
          },
        ),
      ),
    );
  }
}

class MostCommonWords extends StatelessWidget {
  final List<WordCount> commonWords;
  MostCommonWords(this.commonWords);
  @override
  Widget build(BuildContext context) {
    // TODO: This doesn't actually wrap yet. To be fixed.
    return Wrap(
      direction: Axis.vertical,
      children: commonWords
          .map((count) => Text("${count.word} : ${count.count}"))
          .toList(),
    );
  }
}

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  BoardStats? _stats;

  @override
  void initState() {
    super.initState();
    initialLoad();
  }

  Future initialLoad() async {
    print("initialLoad");
    String url = "boards/stats.json";
    http.Response response = await http.get(Uri.parse(url));
    BoardStats stats = BoardStats.fromJson(json.decode(response.body));

    setState(() {
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    var bodyChildren = <Widget>[];
    BoardStats? stats = _stats;
    if (stats == null) {
      bodyChildren = <Widget>[Text("Loading...")];
    } else {
      bodyChildren = <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text("Max Score in all Puzzles"),
                MaxScoreAllPuzzles(stats.maxScores),
              ],
            ),
            Column(
              children: [
                Text("Number of Answers in all Puzzles"),
                NumberOfAnswers(stats.numberOfAnswers),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Column(
              children: [
                Text("Center Letter Frequency"),
                LetterFrequency(stats.centerLetters),
              ],
            ),
            Column(
              children: [
                Text("Valid Letter Frequency"),
                LetterFrequency(stats.validLetters),
              ],
            ),
          ],
        ),
        MostCommonWords(stats.commonWords),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Stats"),
      ),
      body: Center(
        child: ListView(
          children: bodyChildren,
        ),
      ),
    );
  }
}
