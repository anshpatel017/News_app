import 'package:flutter/material.dart';
import '../main.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String status = 'Testing connection...';

  @override
  void initState() {
    super.initState();
    testConnection();
  }

  Future<void> testConnection() async {
    try {
      final response = await supabase.from('articles').select().limit(5);

      setState(() {
        status =
            '✅ SUCCESS!\n\nFound ${response.length} articles\n\nSupabase is connected!';
      });
    } catch (e) {
      setState(() {
        status = '❌ ERROR:\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
