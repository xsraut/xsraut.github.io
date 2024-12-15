import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return CustomDraggable(key: ValueKey(e), e: e);
            },
          ),
        ),
      ),
    );
  }
}

class CustomDraggable extends StatefulWidget {
  const CustomDraggable({
    required this.e,
    super.key,
  });

  final IconData e;

  @override
  State<CustomDraggable> createState() => _CustomDraggableState();
}

class _CustomDraggableState extends State<CustomDraggable> {

  bool _isDragging = false;
  bool _isDragCompleted = false;

  @override
  Widget build(BuildContext context) {

    if(_isDragCompleted){
      return const SizedBox.shrink();
    }
    else
    {
      print("${widget.e} $_isDragCompleted $_isDragging");
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          if(!_isDragCompleted && !_isDragging)
          const CustomDragTarget(isLeft: true,),

          if(!_isDragCompleted && !_isDragging)
          Draggable<IconData>(
            data: widget.e,
            onDragStarted: () => setState(() {
              _isDragging = true;
            }),
            onDragCompleted: () => setState(() {
              _isDragging = false;
              _isDragCompleted =true;
            }),
            onDragEnd: (_) => setState(() {
              _isDragging = false;
            }),
            onDraggableCanceled: (_, __) => setState(() {
              _isDragging = false;
            }),
            feedback: CustomAnimatedContainer(dragging: false, e: widget.e),
            childWhenDragging: CustomAnimatedContainer(dragging: true, e: widget.e),
            child: CustomAnimatedContainer(
              dragging: _isDragging, 
              e: widget.e,
            ),
          ),

          if(!_isDragCompleted && !_isDragging)
          const CustomDragTarget(isLeft: false,),
        ],
      );
    }
  }
}

class CustomDragTarget extends StatefulWidget {
  const CustomDragTarget({
    required this.isLeft,
    super.key,
  });


  final bool isLeft;

  @override
  State<CustomDragTarget> createState() => _CustomDragTargetState();
}

class _CustomDragTargetState extends State<CustomDragTarget> {

  bool _willAccept = false;
  bool _isAccepted = false;
  IconData? e;

  bool isAnimationCompleted = false;

  void _onAnimationComplete(){
    setState(() {
      isAnimationCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(isAnimationCompleted){
      return Row(
        children: [
          if(!widget.isLeft)
          const CustomDragTarget(isLeft: true,),
          CustomDraggable(key: ValueKey(e), e: e!),
          if(widget.isLeft)
          const CustomDragTarget(isLeft: false,),
        ],
      );
    }
    return DragTarget<IconData>(
      onWillAcceptWithDetails: (data) {
        if (_isAccepted) return false;
        setState(() {
          _willAccept = true;
        });
        return true;
      },

      onLeave: (_) {
        if (_isAccepted) return;
        setState(() {
          _willAccept = false;
        });
      },

      onAcceptWithDetails: (data) {
        if (_isAccepted) return;
        setState(() {
          _isAccepted = true;
          e = data.data;
        });
        print("asdasdasdadasd ${e}");
      },
      builder: (context, acceptedData, rejectedData) {
        print("mmmmmmmmmmmmmmmmmmmmmmmmmmmmm ${e}");
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          onEnd: () {
            if(_isAccepted)
            _onAnimationComplete();
          } ,
          height: 48 + 8,
          // width:  _willAccept ? 48 + 24 : 8,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 
          _isAccepted ? 48 + 16 :
          _willAccept ? 48 + 16 : 8),
          color: (_isAccepted)? Colors.blue:Colors.red,
          child: e!= null? Center(child: CustomDraggable(key: ValueKey(e), e: e!))
          : null,
          // child: (_isAccepted) ? Center(child: CustomDraggable(key: ValueKey(e), e: e))
          // : null,
        );
      }
    );
  }
}

class CustomAnimatedContainer extends StatelessWidget {
  const CustomAnimatedContainer({
    required this.dragging,
    required this.e,
    super.key,
  });

  final bool dragging;
  final IconData e;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: dragging ? 0 : 48,
      height: 48,
      // margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[e.hashCode % Colors.primaries.length],
      ),
      child: dragging ? null : Center(child: Icon(e, color: Colors.white)),
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

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();

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
        children: _items.map(widget.builder).toList(),
      ),
    );
  }
}
