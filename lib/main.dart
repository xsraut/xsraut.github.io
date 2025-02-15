import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'dart:js' as js;

/// The main entry point of the application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the Flutter application.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Image Viewer',
      home: const HomePage(),
    );
  }
}

/// A [StatefulWidget] representing the home page.
class HomePage extends StatefulWidget {
  /// Creates a [HomePage] widget.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// The state for [HomePage], handling UI interactions.
class _HomePageState extends State<HomePage> {
  /// Controller for the image URL text field.
  final TextEditingController _controller = TextEditingController();

  /// Whether the floating action button (FAB) menu is open.
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _registerImageElement();
  }

  @override
  void dispose() {
    // dispose controller when widget is disposed
    _controller.dispose();
    super.dispose();
  }

  /// Registers an HTML `<img>` element for rendering inside the Flutter app.
  void _registerImageElement() {
    final html.ImageElement imgElement = html.ImageElement()
      ..id = "img-element"
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.objectFit = 'contain'
      ..onDoubleClick.listen((_) => _toggleFullscreen());

    // Registers the HTML image element so Flutter can render it inside a widget.
    ui_web.platformViewRegistry.registerViewFactory(
      'imageElement',
      (int viewId) => imgElement,
    );
  }

  /// Loads the entered URL into the HTML `<img>` element.
  void _loadImage() {
    final html.ImageElement? imgElement =
        html.document.getElementById("img-element") as html.ImageElement?;

    if (imgElement != null && _controller.text.isNotEmpty) {
      imgElement.src = _controller.text;
    }
  }

  /// Toggles fullscreen mode using JavaScript.
  void _toggleFullscreen() {
    js.context.callMethod('eval', [
      // js fucntion to toggle fullscreen
      '''
      if (!document.fullscreenElement) {
        document.getElementById("img-element").requestFullscreen();
      } else {
        document.exitFullscreen();
      }
      '''
    ]);
  }

  /// Toggles the visibility of the floating action button (FAB) menu.
  /// by setting [isMenuOpen] true/false 
  void _toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  /// Closes the menu if it's open.
  void _closeMenu() {
    if (isMenuOpen) {
      setState(() {
        isMenuOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Close the menu when tapping outside of it.
      onTap: _closeMenu,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      // Shows HTML image inside flutter widget
                      child: HtmlElementView(viewType: 'imageElement'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Enter Image URL',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _loadImage,
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _toggleMenu,
              child: const Icon(Icons.add),
            ),
          ),

          // Dimmed background when the menu is open.
          if (isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu, // Close menu when tapping outside.
                child: Container(
                  color: Colors.black.withAlpha(150),
                ),
              ),
            ),

          // Floating action button (FAB) menu.
          if (isMenuOpen)
            Positioned(
              bottom: 80,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _menuOption("Enter Fullscreen", _toggleFullscreen),
                  _menuOption("Exit Fullscreen", (){}),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Creates a menu option button with a given [label] and [onTap] callback.
  Widget _menuOption(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
        _closeMenu();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 225, 216, 237),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: 120,
          child: Text(
            label, 
            style: const TextStyle(fontSize: 16, inherit: false)
          )
        ),
      ),
    );
  }
}
