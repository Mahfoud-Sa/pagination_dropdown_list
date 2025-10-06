import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pagination_dropdown_liste/pagination_dropdown_liste.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name']);
  }
}

class ApiService {
  ApiService();

  Future<List<User>> getUsers(int page, int pageSize) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    return List.generate(pageSize, (index) {
      int userId = (page - 1) * pageSize + index + 1;
      return User(id: userId, name: 'User $userId');
    });
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final User currentUser = User(
    id: 1,
    name: 'John Doe',
  ); // Example pre-selected user

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,

          title: Text("paganation list dropdown"),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ScaleTransition(
            scale: AlwaysStoppedAnimation(1.0), // You can animate this
            child: PaginationDropdownList(
              textTitle: 'User',
              hintText: 'Select user',
              initialItem: currentUser.name, // Pre-select a User object
              onChanged: (user) => print('Selected: $user'),
              itemParser: (user) => user.name,
              fetchItems: (page, pageSize) async =>
                  await ApiService().getUsers(page, pageSize),
            ),
          ),
        ),
      ),
    );
  }
}
