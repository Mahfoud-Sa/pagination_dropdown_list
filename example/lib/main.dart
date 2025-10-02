import 'package:flutter/material.dart';
import 'package:pagination_dropdown_liste/pagination_dropdown_liste.dart';

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
          child: PaginatedDropdownList(
            textTitle: 'التصنيف',
            hintText: 'العنصر المطلوب',
            onChanged: (String) {},
            itemParser: (item) => item,
            initialItem: 'Item 1',
            pageSize: 10,
            notItemMessage: 'لا يوجد عناصر',
            fetchItems: (pageIndex, pageSize) async {
              await Future.delayed(const Duration(seconds: 2));
              return List.generate(
                5,
                (index) => 'Item ${index + 1 + (pageIndex - 1) * pageSize}',
              );
            },
          ),
        ),
      ),
    );
  }
}
