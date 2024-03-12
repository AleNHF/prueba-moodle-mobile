// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moodle_mobile/models/user.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cursos Moodle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
  final String moodleUrl =
      'http://localhost/escuela-moodle/moodle/webservice/rest/server.php';
  final String wsToken = 'cabeb2dd739b6f1f17d4b5114bbd32e1';

  List<User> users = [];
  User? selectedUser;
  List<Map<String, dynamic>> enrolledCourses = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url =
        '$moodleUrl/webservice/rest/server.php?wstoken=$wsToken&wsfunction=core_user_get_users&moodlewsrestformat=json&criteria[0][key]=&criteria[0][value]';

    print('URL USERS $url');

    try {
      final response = await http.post(Uri.parse(url));
      print('RESPONSE CODE ${response.statusCode}');
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final userList = (decodedResponse['users'] as List)
            .map((userJson) => User.fromJson(userJson))
            .toList();

        setState(() {
          users = userList;
        });
        print('USERS $users');
      } else {
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchEnrolledCourses() async {
    final url =
        '$moodleUrl/webservice/rest/server.php?wstoken=$wsToken&wsfunction=core_enrol_get_users_courses&moodlewsrestformat=json&userid=${selectedUser!.id}';

    print('url courses $url');

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print('DCOURSES $decodedResponse');
        if (decodedResponse is List) {
          setState(() {
            enrolledCourses = List<Map<String, dynamic>>.from(decodedResponse);
          });
          print('COURSES $enrolledCourses');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos Inscritos en Moodle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.yellow[900], 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona al usuario'),
            DropdownButton<User>(
              value: selectedUser,
              hint: const Text('Seleccionar Usuario'),
              onChanged: (User? newValue) {
                setState(() {
                  selectedUser = newValue;
                });
              },
              items: users.map((User user) {
                return DropdownMenuItem<User>(
                  value: user,
                  child: Text(user.username),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                fetchEnrolledCourses();
              },
              child: const Text('Mostrar Cursos'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: enrolledCourses.length,
                itemBuilder: (context, index) {
                  final course = enrolledCourses[index];
                  return Card(
                    elevation: 2.0, // Ajustar según sea necesario
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(course['fullname']),
                      subtitle: Text(course['shortname']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
