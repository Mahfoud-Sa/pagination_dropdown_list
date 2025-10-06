import 'package:flutter/material.dart';

class PaginationDropdownList<T> extends StatefulWidget {
  final String textTitle;
  final String hintText;
  final String Function(T) itemParser;
  final ValueChanged<T?> onChanged;
  final Future<List<T>> Function(int page, int pageSize) fetchItems;
  final Color? selectedColor;
  final int pageSize;
  final String? noMoreItemsMessage;
  final String? errorMessage;
  final String? notItemMessage;

  const PaginationDropdownList({
    Key? key,
    required this.textTitle,
    required this.hintText,
    required this.onChanged,
    required this.itemParser,
    required this.fetchItems,
    this.selectedColor,
    this.pageSize = 10,
    this.noMoreItemsMessage,
    this.errorMessage,
    this.notItemMessage,
  }) : super(key: key);

  @override
  State<PaginationDropdownList<T>> createState() =>
      _PaginationDropdownListState<T>();
}

class _PaginationDropdownListState<T> extends State<PaginationDropdownList<T>> {
  final LayerLink _layerLink = LayerLink();
  final ScrollController _scrollController = ScrollController();

  List<T> _items = [];
  bool _isDropdownOpen = false;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  int _currentPage = 0; // Start from 0, increment before first fetch
  OverlayEntry? _overlayEntry;
  T? _selectedItem;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !_isLoading &&
          _hasMore &&
          !_hasError) {
        _fetchItems();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final nextPage = _currentPage + 1;
      final newItems = await widget.fetchItems(nextPage, widget.pageSize);

      setState(() {
        if (newItems.isEmpty) {
          _hasMore = false;
        } else {
          _currentPage = nextPage;
          _items.addAll(newItems);
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching items: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _resetAndFetch() {
    setState(() {
      _items.clear();
      _currentPage = 0;
      _hasMore = true;
      _hasError = false;
    });
    _fetchItems();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    // Reset and load fresh data when opening dropdown
    _resetAndFetch();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: widget.selectedColor ?? Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: _buildDropdownList(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isDropdownOpen = false);
  }

  Widget _buildDropdownList() {
    if (_hasError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.errorMessage ?? 'Error loading items'),
          ),
          TextButton(onPressed: _resetAndFetch, child: const Text('Retry')),
        ],
      );
    }

    if (_items.isEmpty && _isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_items.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(widget.notItemMessage ?? 'No items found'),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: _items.length + (_isLoading ? 1 : 0) + (_hasMore ? 0 : 1),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index == _items.length && _isLoading) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        // Show "no more items" message
        if (index == _items.length && !_hasMore) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                widget.noMoreItemsMessage ?? 'No more items',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }

        final item = _items[index];
        return ListTile(
          title: Text(widget.itemParser(item)),
          onTap: () {
            setState(() {
              _selectedItem = item;
            });
            _closeDropdown();
            widget.onChanged(item);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.textTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedItem != null
                          ? widget.itemParser(_selectedItem!)
                          : widget.hintText,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isDropdownOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
