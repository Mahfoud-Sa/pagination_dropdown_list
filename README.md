# pagination_dropdown_list

A powerful and easy-to-use Flutter widget that displays a **dropdown list with built-in pagination** support.  
Perfect for loading large datasets efficiently without fetching all data at once.

---

## 🚀 Features

✅ Load data in pages as the user scrolls  
✅ Display loading spinner while fetching next page  
✅ Handle empty, error, and “no more data” states  
✅ Support for custom item parsing and pre-selected items  
✅ Fully customizable design  
✅ Easy integration with any API or data source

---

## 📦 Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  pagination_dropdown_list: ^1.0.0
```

Then, import it in your Dart file:

```dart
import 'package:pagination_dropdown_list/pagination_dropdown_list.dart';
```

---

## 🧩 Example

```dart
PaginationDropdownList(
  textTitle: 'User',
  hintText: 'Select user',
  initialItem: currentUser.name,
  onChanged: (user) => print('Selected: $user'),
  itemParser: (user) => user.name,
  fetchItems: (page, pageSize) async => await ApiService().getUsers(page, pageSize),
)
```

---

## ⚙️ Parameters

| Parameter | Type | Description |
|------------|------|-------------|
| **textTitle** | `String` | Title shown above the dropdown. |
| **hintText** | `String` | Hint text displayed when no item is selected. |
| **initialItem** | `dynamic` | Pre-selected value shown when the widget loads. |
| **onChanged** | `Function(T item)` | Callback triggered when a user selects an item. |
| **itemParser** | `Function(T item)` | Function that defines how to display each item as a string. |
| **fetchItems** | `Future<List<T>> Function(int page, int pageSize)` | Asynchronous function used to fetch data by page. |
| **pageSize** | `int` | Number of items per page (default: 10). |
| **noMoreItemsMessage** | `String?` | Message displayed when no more data is available. |
| **errorMessage** | `String?` | Message displayed when an error occurs. |
| **notItemMessage** | `String?` | Message displayed when no items are found. |

---

## 🧠 How It Works

1. When the dropdown opens, it calls `fetchItems(page = 1)` to load the first page.  
2. As the user scrolls, it automatically triggers `fetchItems(page++)` when reaching the end.  
3. The widget handles loading and "no more items" states automatically.  
4. You can replace the simulated API with your own backend service.

---

## 🎨 Customization

You can style the dropdown, adjust its size, and use custom item builders for advanced UI.  
It’s fully compatible with **Material 3** and **Directionality (RTL/LTR)**.

---

## 📸 Preview


![Example preview]!(preview_img.png)
## 🧾 Notes

- Works perfectly with REST APIs, Firebase, or any async data source.  
- Pagination logic runs independently of your UI, so your app stays responsive.  
- Ideal for large datasets like products, users, or countries.

---

## ❤️ Contributing

Contributions, issues, and feature requests are welcome!  
Feel free to open a PR or issue on GitHub.

---

**Developed by:** Engineer Mahfoud Mohammed Bin Sabbah  
**License:** MIT  
**Pub.dev:** [pagination_dropdown_list](https://pub.dev/packages/pagination_dropdown_list)
