
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Market Scans',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> scans = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://coding-assignment.bombayrunning.com/data.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          scans = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Market Scans'),
      ),
      body: ListView.builder(
        itemCount: scans.length,
        itemBuilder: (context, index) => Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanDetailsScreen(scan: scans[index]),
                ),
              ),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    scans[index]['name'],
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${scans[index]['tag']}',
                      style: TextStyle(color: getColorFromTag(scans[index]['color'])),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      )
      );
  }
}

Color getColorFromTag(String tagColor) {
    switch (tagColor) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

class ScanDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> scan;

  const ScanDetailsScreen({Key? key, required this.scan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scan['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${scan['tag']}',
              style: TextStyle(color: getColorFromTag(scan['color'])),
            ),
            const SizedBox(height: 16.0),
            const Text('Criteria:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var criteria in scan['criteria'])
              buildCriteriaWidget(criteria),
          ],
        ),
      ),
    );
  }

  Widget buildCriteriaWidget(Map<String, dynamic> criteria) {
    final String type = criteria['type'];
    final String text = criteria['text'];
    final dynamic variable = criteria['variable'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0),
        Text(
          type == 'plain_text' ? text : buildVariableText(text, variable),
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  String buildVariableText(String text, dynamic variable) {
    if (variable == null) {
      return text;
    }

    if (variable is List<Map<String, dynamic>>) {
      String formattedText = text;
      for (var variableItem in variable) {
        final String variableName = variableItem.keys.first;
        final dynamic variableData = variableItem.values.first;
        if (variableName != null && variableData != null) {
          final String? variableType = variableData['type'];
          final dynamic variableValues = variableData['values'];
          if (variableType == 'value' && variableValues != null) {
            final String formattedValue = variableValues.isNotEmpty ? '(${variableValues[0]})' : '';
            formattedText = formattedText.replaceAll('\$$variableName', formattedValue);
          } else if (variableType == 'indicator') {
          }
        }
      }
      return formattedText;
    }

    return text;
  }

  Color getColorFromTag(String tagColor) {
    switch (tagColor) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
