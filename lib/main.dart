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

  bool isFullScreened = false;

  @override
  void initState() {
    super.initState();
    _registerImageElement();
    html.document.addEventListener('fullscreenchange', (event){
      fullScreenListner();
    });
  }

  @override
  void dispose() {
    // dispose controller when widget is disposed
    _controller.dispose();
    super.dispose();
  }

  // HTML image element to show image via url
  final html.ImageElement imageElement = html.ImageElement();

  // Html button used as Floating Action Button
  final html.ButtonElement fabElement = html.ButtonElement();

  // Maximize (image) button element
  final html.ButtonElement maxBtnElement = html.ButtonElement();

  // Minimize (image) button element
  final html.ButtonElement minBtnElement = html.ButtonElement();

  // Options div that holds maxBtnElement and minBtnElement in a column above fabElement
  final html.DivElement optionsContainer = html.DivElement();

  // Image container div
  // When full screen is disabled, it only contins imageElement
  // When full screen is enabled, it holds imageElement, fabElement and optionsContainer
  final html.DivElement imageContainer = html.DivElement();

  /// Registers an HTML `<img>` element for rendering inside the Flutter app.
  /// It must be called in init() function
  void _registerImageElement() {

    imageElement
      ..id = "img-element"
      ..onDoubleClick.listen((_) => _toggleFullscreen()); // Toggle fullscreen when double clicked on image
    
    imageElement.style
      ..width = "100%"
      ..height = "100%"
      ..objectFit = "contain";

    fabElement
      ..id = "fab-element"
      ..text = "+"
      ..onClick.listen((data) => _toggleMenu()); // Show/Hide fullscreen option menu
    
    fabElement.style
      ..fontSize = "25px"
      ..cursor = "pointer"
      ..right = "10px"
      ..bottom = "10px"
      ..height = "60px"
      ..width = "60px"
      ..margin = "0"
      ..position = "absolute"
      ..border = "none"
      ..borderRadius = "5px"
      ..boxShadow = "0 2px 5px 0 rgba(0,0,0,0.2)"
      ..backgroundColor = "white"
      ..color = "violet";
    
    maxBtnElement.onClick.listen((data) => _enableFullScreen()); // maximize image when clicked

    maxBtnElement
      ..id = "max-btn"
      ..text = "Enter Full Screen"
      ..style.fontSize = "15px"
      ..style.border = "none"
      ..style.borderRadius = "5px"
      ..style.height = "30px";
    
    minBtnElement.onClick.listen((data) => _disableFullScreen()); // minimize image when clicked
    
    minBtnElement
      ..id = "min-btn"
      ..text = "Exit Full Screen"
      ..style.fontSize = "15px"
      ..style.border = "none"
      ..style.borderRadius = "5px"
      ..style.height = "30px";

    optionsContainer.children.add(maxBtnElement); // Add maxBtnElement inside optionsContainer
    optionsContainer.children.add(minBtnElement); // Add minBtnElement inside optionsCOntainer

    optionsContainer.style
      ..display = "flex"
      ..flexDirection = "column"
      ..rowGap = "5px"
      ..right = "10px"
      ..bottom = "75px"
      ..height = "60px"
      ..width = "150px"
      ..margin = "0"
      ..position = "absolute";

    imageContainer
      ..id = "img-container"
      ..children.add(imageElement);
    
    
    // Register the HTML elements

    ui_web.platformViewRegistry.registerViewFactory(
      'imageElement',
      (int viewId) => imageElement,
    );

    ui_web.platformViewRegistry.registerViewFactory(
      'fabElement',
      (int viewId) => fabElement,
    );

    ui_web.platformViewRegistry.registerViewFactory(
      'imageContainer',
      (int viewId) => imageContainer,
    );

    ui_web.platformViewRegistry.registerViewFactory(
      'optionsContainer',
      (int viewId) => optionsContainer,
    );

    ui_web.platformViewRegistry.registerViewFactory(
      'maxBtnElement',
      (int viewId) => maxBtnElement,
    );

    ui_web.platformViewRegistry.registerViewFactory(
      'minBtnElement',
      (int viewId) => minBtnElement,
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
        document.getElementById("img-container").requestFullscreen();
      } else {
        document.exitFullscreen();
      }
      '''
    ]);
  }


  /// This function is called whenever the fullscreen mode is changed
  /// This function changes [isFullScreened] to show/hide the floating action button 
  /// over the html image element in [imageContainer] in full screen mode
  /// When in enabling fullscreen mode, it adds [fabElement] in [imageContainer]
  /// When fullscreen mode is disabled, it removes [fabElement] and/or [optionsContainer]
  void fullScreenListner(){
    setState(() {
      isFullScreened = !isFullScreened;
    });
    
    if(imageContainer.children.contains(fabElement)){
      imageContainer.children.remove(fabElement); 
    }else{
      imageContainer.children.add(fabElement);
    }

    if(imageContainer.children.contains(optionsContainer)){
      imageContainer.children.remove(optionsContainer);
    }
  }

  /// Function to enable fullscreen mode using [maxBtnElement]
  void _enableFullScreen(){
    if(!isFullScreened) _toggleFullscreen();
  }

  /// Function to enable fullscreen mode using [minBtnElement]
  void _disableFullScreen(){
    if(isFullScreened) _toggleFullscreen();
  }

  /// Toggles the visibility of the floating action button (FAB) menu.
  /// by setting [isMenuOpen] true/false 
  void _toggleMenu() {
    if(isFullScreened){
      isMenuOpen ? imageContainer.children.remove(optionsContainer) : imageContainer.children.add(optionsContainer);
      return;
    }
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
                      child: HtmlElementView(viewType: 'imageContainer'),
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
          ),

          if(!isFullScreened) 
            Positioned(
              bottom: 0,
              right: 0,
              child:SizedBox(
                width: 50,
                height: 50,
                child: HtmlElementView(viewType: 'fabElement')
              ),
            ),

          // Dimmed background when the menu is open.
          if (!isFullScreened && isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu, // Close menu when tapping outside.
                child: Container(
                  color: Colors.black.withAlpha(150),
                ),
              ),
            ),

          // Floating action button (FAB) menu.
          if (!isFullScreened && isMenuOpen)
            Positioned(
              bottom: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    height: 25,
                    child: HtmlElementView(viewType: 'optionsContainer')
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}