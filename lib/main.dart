import 'package:flutter/material.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

List<IconData> iconsList = [
  Icons.person,
  Icons.message,
  Icons.call,
  Icons.camera,
  Icons.photo,
];

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CustomDock(),
        ),
      ),
    );
  }
}

class CustomDock extends StatefulWidget {
  const CustomDock({
    super.key,
  });

  @override
  State<CustomDock> createState() => _CustomDockState();
}

class _CustomDockState extends State<CustomDock> {
  void onAccept(int index, IconData item) {

    int _currentIndex = iconsList.indexOf(item);
    int _finalIndex = 0;
    if(_currentIndex >= index) _finalIndex = index;
    if(_currentIndex < index) _finalIndex = index - 1;
    if(_currentIndex == 0) _finalIndex = index - 1;
    
    setState(() {
      iconsList.remove(item);
      iconsList.insert(_finalIndex, item);
    });
  }

  // bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Dock(
      items: iconsList,
      builder: (e) {

        int left = iconsList.indexOf(e);
        int right = iconsList.indexOf(e) + 1;
        if(left < 0) left = 0;
        // if(right > iconsList.length - 1) right = iconsList.length - 1;

        return Row(
          children: [
            CustomDragTarget(
              index: left,
              onAccept: onAccept,
            ),

            Draggable<IconData>(
              data: e,
              feedback: CustomIcon(e: e),
              childWhenDragging: const SizedBox.shrink(),
              child: CustomIcon(e: e),
            ),
            
            CustomDragTarget(
              index: right,
              onAccept: onAccept,
            ),
          ],
        );
      },
    );
  }
}

class CustomIcon extends StatelessWidget {
  const CustomIcon({
    required this.e,
    super.key,
  });

  final IconData e;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[e.hashCode % Colors.primaries.length],
      ),
      child: Center(child: Icon(e, color: Colors.white)),
    );
  }
}

class CustomDragTarget extends StatelessWidget {
  const CustomDragTarget({
    required this.index,
    required this.onAccept,
    super.key,
  });

  final int index;
  final Function(int, IconData) onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<IconData>(
      
      onAcceptWithDetails: (data) {
        onAccept(index, data.data);
      },
      
      onWillAcceptWithDetails: (data) {
        // if(iconsList.indexOf(data.data) + 1 == index) return false;
        return true;
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: candidateData.isNotEmpty ? 48 : 8,
          height: 64,
          // color: candidateData.isNotEmpty ? Colors.green : Colors.red,
          // child: Text(index.toString()),
        );
      },
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatelessWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

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
        children: items.map(builder).toList(),
      ),
    );
  }
}
