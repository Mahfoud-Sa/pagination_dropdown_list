# Example – Pagination Dropdown List

This example demonstrates how to use the **PaginationDropdownList** widget to create a dropdown list that supports **lazy loading (pagination)** when scrolling.  
Each time the user reaches the end of the list, the widget automatically fetches the next page of data.

---

## 🧩 Example Code

```dart
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagination Dropdown Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Pagination Dropdown List Example"),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ScaleTransition(
            scale: AlwaysStoppedAnimation(1.0),
            child: PaginationDropdownList<User>(
              textTitle: 'User',
              hintText: 'Select user',
              initialItem: currentUser.name, // Pre-selected value
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
```

---

## ⚙️ How It Works

- The `PaginationDropdownList` widget loads the **first page** of users when opened.
- As the user scrolls to the bottom, the widget automatically calls the `fetchItems` function to get the **next page**.
- It displays a **loading spinner** while fetching new data.
- The `itemParser` callback defines how each item will be displayed.
- You can pass an `initialItem` to preselect an item when the widget is rendered.

---

## 🧠 Key Parameters

| Parameter | Description |
|------------|-------------|
| `textTitle` | The label shown above the dropdown. |
| `hintText` | Placeholder text displayed before selection. |
| `initialItem` | Preselected item to display initially. |
| `onChanged` | Callback when an item is selected. |
| `itemParser` | Function to map your item model to a string for display. |
| `fetchItems` | Async function called to load items with pagination support. |

---

## 📸 Preview

When you open the dropdown, it will:
- Load the first page of items (`User 1` to `User 10` by default).
- Automatically fetch more users (`User 11`, `User 12`, etc.) as you scroll.

---

## 🧾 Notes

- This example uses a **mock API** (`ApiService`) that simulates delayed network calls.
- You can easily replace it with your own API endpoint.

---

**Package:** [pagination_dropdown_liste](https://pub.dev/packages/pagination_dropdown_liste)
