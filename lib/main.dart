import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// The main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          /// A custom widget that displays a dock of draggable items
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (IconData e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
            onDragOut: (item) {
              debugPrint('Item dragged out: $item');
            },
          ),
        ),
      ),
    );
  }
}

/// A custom widget that creates a dock of draggable items
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
    this.onDragOut,
  });

  /// The list of items to be displayed in the dock
  final List<T> items;

  /// A builder function that builds the widget for each item
  final Widget Function(T) builder;

  /// A callback function that is called when an item is dragged out of the dock
  final void Function(T)? onDragOut;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  /// A copy of the items list to manage the state of the dock.
  late final List<T> _items = widget.items.toList();

  /// The item currently being dragged
  T? _draggedItem;

  /// The index of the item currently being dragged
  int? _draggedIndex;

  /// Builds a draggable item
  Widget _buildDraggableItem(T item, int index) {
    return Draggable<MapEntry<int, T>>(
      data: MapEntry(index, item),
      feedback: widget.builder(item),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: widget.builder(item),
      ),
      onDragStarted: () {
        setState(() {
          _draggedItem = item;
          _draggedIndex = index;
        });
      },
      onDragEnd: (details) {
        if (details.wasAccepted == false && _draggedItem != null) {
          widget.onDragOut?.call(_draggedItem!);
        }
        setState(() {
          _draggedItem = null;
          _draggedIndex = null;
        });
      },
      child: widget.builder(item),
    );
  }

  /// Builds a drag target for reordering items
  Widget _buildDragTarget(int index) {
    return DragTarget<MapEntry<int, T>>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 8,
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty ? Colors.black.withOpacity(0.6) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
      onWillAccept: (data) => data != null && data.key != index && data.key != index - 1,
      onAccept: (data) {
        setState(() {
          final item = data.value;
          final oldIndex = data.key;
          _items.removeAt(oldIndex);

          final newIndex = index > oldIndex ? index - 1 : index;
          _items.insert(newIndex, item);
        });
      },
    );
  }

  /// Builds the widget tree for the dock
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragTarget(0),
          for (int i = 0; i < _items.length; i++) ...[
            _buildDraggableItem(_items[i], i),
            _buildDragTarget(i + 1),
          ],
        ],
      ),
    );
  }
}