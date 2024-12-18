import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

final items = [
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

  @override
  Widget build(BuildContext context) {
    return Dock(
      items: items,
      builder: (e) {
        return const SizedBox.shrink();
      },
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
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
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  bool _isDragging = false;

  void onDragStart(int index){
    setState(() {
      _isDragging = true;
      _isPlaced = false;
      _oldIndex = index;
    });
  }

  void onDragEnd(){
    setState(() {
      _isDragging = false;
      _expandIndex = -1;
      _willAccept = false;
    });
  }

  int _expandIndex = -1;

  bool _willAccept = false;
  void onWillAccept(int index){
    setState(() {
      _expandIndex = index;
      _willAccept = true;
      _newIndex = index;
      // _oldIndex = _expandIndex;
    });
  }

  int _oldIndex = -1;
  int _newIndex = -1;
  bool _isPlaced = false;
  void onAccept(int oldIndex, int newIndex){
    setState(() {
      if(newIndex > items.length-1) newIndex = items.length - 1;
      IconData item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      _isPlaced = true;
      _willAccept = false;
      _oldIndex = oldIndex;
      _newIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for(int i = 0; i< items.length; i++)...[
                ExpandableAnimatedContainer(
                  canExpand: (_oldIndex < _newIndex) 
                  ? _expandIndex +1  == i && _willAccept
                  : _expandIndex == i && _willAccept,
                  isPlaced: _isPlaced,
                ),
                if(i< items.length)
                CustomDraggable(
                  onDragEnd: onDragEnd, 
                  onDragStart: onDragStart, 
                  e: items[i],
                ),
                if(i == (items.length - 1))
                ExpandableAnimatedContainer(
                  canExpand: _expandIndex == i,
                  isPlaced: _isPlaced,
                ),
              ]
            ],
          ),
          if(_isDragging)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for(int i =0; i< (items.length *2) - 1; i++)
              HoverDragTarget(
                index: i~/2, 
                onWillAccept: onWillAccept,
                onAccept: onAccept,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpandableAnimatedContainer extends StatefulWidget {
  const ExpandableAnimatedContainer({
    required this.canExpand,
    required this.isPlaced,
    super.key,
  });

  final bool canExpand;
  final bool isPlaced;
  @override
  State<ExpandableAnimatedContainer> createState() => _ExpandableAnimatedContainerState();
}

class _ExpandableAnimatedContainerState extends State<ExpandableAnimatedContainer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: widget.isPlaced ? 0 : 300),
      width: widget.canExpand ? 64 : 0,
      height: 64,
      // color: Colors.blue.withAlpha(100),                                              // Debug Visual
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
    return Container(
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

class CustomDraggable extends StatefulWidget {
  const CustomDraggable({
    required this.onDragEnd,
    required this.onDragStart,
    required this.e,
    super.key,
  });

  final IconData e;
  final Function(int) onDragStart;
  final Function onDragEnd;

  @override
  State<CustomDraggable> createState() => _CustomDraggableState();
}

class _CustomDraggableState extends State<CustomDraggable> {

  bool _isDragStarted = false;
  bool _isAnimationStarted = false;

  bool selected = false;
  int animation_speed = 300;
  double initial_x = 0;
  double initial_y = 0;
  late double x = initial_x;
  late double y = initial_y;  

  double initial_width = 48 + 16;
  double current_width = 48 + 16;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, (){
      setState(() {
        x = 0;
        y = 0;
        animation_speed = 300;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: animation_speed),
      margin: _isDragStarted||_isAnimationStarted ? EdgeInsets.all(0) : EdgeInsets.all(8),
      width:  _isDragStarted||_isAnimationStarted ? 0 : 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.center,
        children: [
          AnimatedPositioned(
            top:  y,
            left: x,
            duration: Duration(milliseconds: animation_speed),
            curve: Curves.fastOutSlowIn,
            child: Draggable<IconData>(
              data: widget.e,
              feedback: CustomIcon(e: widget.e),
              childWhenDragging: const SizedBox.shrink(),
              child: Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[widget.e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(widget.e, color: Colors.white)),
              ),
            
              onDragStarted: () async{
                setState(() {
                  _isDragStarted = true;
                  _isAnimationStarted = true;
                });

                widget.onDragStart(items.indexOf(widget.e));
                setState(() {
                  animation_speed = 300;
                });
                await Future.delayed(const Duration(milliseconds: 10));
                setState(() {
                  current_width = 0;
                });
              },
            
              onDragUpdate: (details) {
                setState(() {
                  animation_speed = 1;
                  x = x + details.delta.dx;
                  y = y + details.delta.dy;
                });
              },
            
              onDraggableCanceled: (velocity, offset) async{
                setState(() {
                  animation_speed = 300;
                  x = initial_x;
                  y = initial_y;
                });
            
                widget.onDragEnd();
            
                setState(() {
                  animation_speed = 300;
                });
                await Future.delayed(const Duration(milliseconds: 10));
                setState(() {
                  current_width = initial_width;
                });
              },
            
              onDragEnd: (_){
                setState(() {
                  _isDragStarted = false;
                  _isAnimationStarted = false;
                });
                widget.onDragEnd();
              },
            
              onDragCompleted: (){
                setState(() {
                  x = 0;
                  y = 0;
                  if(!_isDragStarted){
                    animation_speed = 0;
                  }else{
                    animation_speed = 300;
                  }
                  _isDragStarted = false;
                  _isAnimationStarted = false;
                });
                widget.onDragEnd();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HoverDragTarget extends StatefulWidget {
  const HoverDragTarget({
    super.key,
    required this.index,
    required this.onWillAccept,
    required this.onAccept,
  });

  final int index;
  final Function(int) onWillAccept;
  final Function(int, int) onAccept;

  @override
  State<HoverDragTarget> createState() => _HoverDragTargetState();
}

class _HoverDragTargetState extends State<HoverDragTarget> {
  
  bool _canAccept = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<IconData>(
      onWillAcceptWithDetails: (details) {
        widget.onWillAccept(widget.index);
        setState(() {
          _canAccept = true;
        });
        return true;
      },
      onLeave: (data) {
        widget.onWillAccept(-1);
        setState(() {
          _canAccept = false;
        });
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _canAccept = false;
        });
        final oldIndex = items.indexOf(details.data);
        final newIndex = widget.index;
        widget.onAccept(oldIndex, newIndex);
        widget.onWillAccept(-1);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 64,
          // decoration: BoxDecoration(                                                // Debug Visual
          //   color: Colors.red.withAlpha(100),
          //   border: Border.all(color: Colors.black.withAlpha(100))
          // ),
          width: _canAccept ? 64 : 32
        );
      }
    );
  }
}
