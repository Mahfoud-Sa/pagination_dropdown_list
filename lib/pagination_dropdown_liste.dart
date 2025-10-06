// Copyright 2024 Your Name. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2024 Your Name. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library pagination_dropdown_list;

export 'src/pagination_dropdown_list.dart';

/// {@template pagination_dropdown_list}
/// A dropdown list with pagination support for efficiently handling large datasets.
///
/// ## Features
///
/// - **Pagination**: Loads first page on open and subsequent pages as user scrolls
/// - **Loading States**: Shows loading indicators during data fetch
/// - **Error Handling**: Displays error states with retry functionality
/// - **Customizable**: Fully customizable appearance and behavior
/// - **RTL Support**: Proper right-to-left text direction support
///
/// ## Usage
///
/// ```dart
/// PaginationDropdownList(
///   textTitle: 'Select Item',
///   hintText: 'Choose an item',
///   onChanged: (value) => print('Selected: $value'),
///   itemParser: (item) => item.name,
///   fetchItems: (page, pageSize) async {
///     return await api.getItems(page, pageSize);
///   },
/// )
/// ```
///
/// See also:
///
/// * [DropdownButton], for a simple dropdown without pagination
/// * [ListView.builder], for building custom lists with pagination
/// {@endtemplate}
