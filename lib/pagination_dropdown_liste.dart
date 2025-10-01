import 'package:flutter/material.dart';


/// Dropdown list with pagination support.
/// - Loads first page on open
/// - Loads next page as user scrolls
/// - Shows a spinner at bottom while fetching more
class PaginatedDropdownList extends StatefulWidget {
  final String textTitle;
  final String hintText;
  final bool enabled;
  final String? initialItem;
  final bool? isRequired;
  final Function(String?) onChanged;

  /// Function that fetches a page of items.
  /// The [page] starts from 1.
  final Future<List<dynamic>> Function(int page, int pageSize)? fetchItems;

  /// Converts raw API item to a displayable string.
  final String Function(dynamic item) itemParser;

  /// Optional widget to display when no items are available
  final Widget? emptyStateWidget;

  /// Optional widget to display when there's an error
  final Widget? errorStateWidget;

  /// Page size for pagination (default: 10)
  final int pageSize;

  const PaginatedDropdownList({
    Key? key,
    required this.textTitle,
    required this.hintText,
    required this.onChanged,
    required this.itemParser,
    this.enabled = true,
    this.initialItem,
    this.isRequired,
    this.fetchItems,
    this.emptyStateWidget,
    this.errorStateWidget,
    this.pageSize = 2,
  }) : super(key: key);

  @override
  State<PaginatedDropdownList> createState() => _PaginatedDropdownListState();
}

class _PaginatedDropdownListState extends State<PaginatedDropdownList> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  List<String> _items = [];
  String? _selectedItem;

  bool _isOpen = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;

  // Pagination variables
  int _currentPage = 1;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem;

    // Listen for bottom scroll to trigger pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_isLoadingMore &&
        _hasMore &&
        !_hasError &&
        widget.fetchItems != null) {
      _fetchMoreData();
    }
  }

  /// Fetch the first page of items
  Future<void> _fetchInitialData() async {
    if (widget.fetchItems == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentPage = 1; // Reset to page 1
      _items.clear();
      _hasMore = true;
    });

    try {
      // Call fetchItems with page 1 and pageSize
      final rawItems = await widget.fetchItems!(_currentPage, widget.pageSize);
      final stringItems =
          rawItems.map((item) => widget.itemParser(item)).toList();

      setState(() {
        _items = stringItems;
        _hasMore = stringItems.length == widget.pageSize; // If we got less items than pageSize, no more pages
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() {
        _hasError = true;
        _hasMore = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fetch the next page of items
  Future<void> _fetchMoreData() async {
    if (widget.fetchItems == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1; // Increment page number
      
      // Call fetchItems with the next page number and pageSize
      final rawItems = await widget.fetchItems!(nextPage, widget.pageSize);
      final stringItems =
          rawItems.map((item) => widget.itemParser(item)).toList();

      setState(() {
        if (stringItems.isEmpty) {
          _hasMore = false;
        } else {
          _currentPage = nextPage; // Update current page
          _items.addAll(stringItems);
          _hasMore = stringItems.length == widget.pageSize; // Check if there might be more pages
        }
      });
    } catch (e) {
      debugPrint("Error fetching more data: $e");
      // Don't set _hasMore to false on error, allow retry on next scroll
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
      if (_items.isEmpty && !_isLoading && !_hasError) {
        _fetchInitialData();
      }
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size(400.w, 50.h);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _removeOverlay,
          behavior: HitTestBehavior.translucent,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(child: Container(color: Colors.transparent)),
                Positioned(
                  width: size.width,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: Offset(0, size.height),
                    child: _buildDropdownContent(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlay?.insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  Widget _buildDropdownContent() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        ),
        constraints: BoxConstraints(
          maxHeight: 200.h,
          minHeight: 50.h,
        ),
        child: _buildListContent(),
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading && _items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError && _items.isEmpty) {
      return widget.errorStateWidget ??
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 24.w),
                SizedBox(height: 8.h),
                Text(
                  'Failed to load items',
                  style: KTextStyle.textStyle13.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                OutlinedButton(
                  onPressed: () {
                    _fetchInitialData();
                    _overlayEntry?.markNeedsBuild();
                  },
                  child: Text('Retry', style: KTextStyle.textStyle13),
                ),
              ],
            ),
          );
    }

    if (_items.isEmpty) {
      return widget.emptyStateWidget ??
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'No items available',
                style: KTextStyle.textStyle13.copyWith(color: AppColors.greyLight),
              ),
            ),
          );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: _items.length + (_isLoadingMore ? 1 : 0) + (_hasMore ? 0 : 1),
        itemBuilder: (context, index) {
          if (index < _items.length) {
            final item = _items[index];
            return _buildListItem(item);
          } else if (index == _items.length && _isLoadingMore) {
            return _buildLoadingMoreItem();
          } else {
            return _buildNoMoreItems();
          }
        },
      ),
    );
  }

  Widget _buildListItem(String item) {
    final isSelected = item == _selectedItem;
    return Material(
      color: isSelected ? AppColors.grey.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        title: Text(
          item,
          style: KTextStyle.textStyle13.copyWith(
            color: isSelected ? AppColors.primary : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedItem = item;
          });
          widget.onChanged(item);
          _removeOverlay();
        },
      ),
    );
  }

  Widget _buildLoadingMoreItem() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildNoMoreItems() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: Text(
          'No more items',
          style: KTextStyle.textStyle13.copyWith(
            color: AppColors.greyLight,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    
    if (_isOpen && _overlayEntry != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.textTitle.isNotEmpty) ...[
          Row(
            children: [
              Text(
                widget.textTitle,
                style: KTextStyle.textStyle13.copyWith(
                  color: AppColors.greyLight,
                ),
              ),
              if (widget.isRequired == true) ...[
                SizedBox(width: 4.w),
                Text(
                  '*',
                  style: KTextStyle.textStyle13.copyWith(
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 5.h),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              width: 400.w,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isOpen ? AppColors.primary : AppColors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
                color: widget.enabled ? Colors.white : AppColors.grey.withOpacity(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedItem ?? widget.hintText,
                      style: KTextStyle.textStyle13.copyWith(
                        color: _selectedItem != null
                            ? Colors.black
                            : AppColors.greyLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: widget.enabled ? AppColors.grey : AppColors.greyLight,
                    size: 20.w,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}