# Flutter Web Image Viewer

## Overview
Flutter Web Image Viewer is a simple web application built using Flutter that allows users to load and view images from a provided URL. The app also supports fullscreen viewing via JavaScript integration.

## Features
- Load images from a user-provided URL
- View images in a responsive aspect ratio
- Toggle fullscreen mode using JavaScript
- Interactive Floating Action Button (FAB) menu

## Installation
To run this project locally, follow these steps:

1. **Clone the repository**
   ```sh
   git clone https://github.com/your-username/flutter-web-image-viewer.git
   ```
2. **Navigate to the project directory**
   ```sh
   cd flutter-web-image-viewer
   ```
3. **Ensure Flutter is installed**
   Make sure you have Flutter installed. If not, follow the official installation guide: [Flutter Install](https://flutter.dev/docs/get-started/install)

4. **Run the project**
   ```sh
   flutter run -d chrome
   ```

## Usage
1. Enter an image URL in the provided text field.
2. Click the arrow button to load the image.
3. Use the floating action button (FAB) to access options:
   - Enter fullscreen mode.
   - Exit fullscreen mode.

## Technical Details
- Uses `HtmlElementView` to embed an `<img>` HTML element inside Flutter.
- JavaScript integration is handled using `dart:js`.
- `dart:html` is used for DOM manipulation.

## Dependencies
Ensure you have Flutter installed and configured for web development.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

## Author
Developed by [Sourabh Raut](https://github.com/xsraut). Contributions are welcome!

