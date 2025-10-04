import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pagination_dropdown_liste/pagination_dropdown_liste.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              textTitle: 'التصنيف',
              hintText: 'العنصر المطلوب',
              onChanged: (String) {},
              itemParser: (item) => item,
              //initialItem: 'المن',
              pageSize: 10,
              noMoreItemsMessage: 'لا يوجد المزيد من العناصر',
              notItemMessage: 'لا يوجد عناصر',
              fetchItems: (pageIndex, pageSize) async {
                try {
                  final response = await http.get(
                    Uri.parse(
                      'https://www.sindibad-back.com:82/api/Categories?pageNumber=$pageIndex&pageSize=$pageSize',
                    ),
                    headers: {'accept': 'text/plain'},
                  );

                  if (response.statusCode == 200) {
                    final Map<String, dynamic> responseData = json.decode(
                      response.body,
                    );

                    if (responseData['success'] == true) {
                      final Map<String, dynamic> data = responseData['data'];
                      final List<dynamic> items = data['items'];

                      // Store the full objects
                      final List<Map<String, dynamic>> categoryObjects = items
                          .cast<Map<String, dynamic>>();

                      // Add to our master list
                      // _allCategories.addAll(categoryObjects);

                      // Return just the names for the dropdown
                      return categoryObjects.map<String>((item) {
                        return item['name']?.toString() ?? 'Unknown Category';
                      }).toList();
                    } else {
                      throw Exception('API Error: ${responseData['message']}');
                    }
                  } else {
                    throw Exception('HTTP Error: ${response.statusCode}');
                  }
                } catch (e) {
                  throw Exception('Network error: $e');
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
