#  Temperature Converter App

A polished Flutter application that converts temperatures between Celsius and Fahrenheit with a responsive layout, interactive animations, and a detailed history log.

##  Features

-  **Two-way Conversion**: Toggle between Celsius ⇌ Fahrenheit using a Switch.
-  **Stateful Widget Architecture**: Uses `StatefulWidget` and `setState()` to manage app logic and reactivity.
-  **Conversion History Log**: Tracks all conversions with timestamps for easy reference.
-  **Input Validation**: Accepts only valid temperature values and provides user feedback.
-  **Responsive UI**: Adapts seamlessly between **portrait** and **landscape** orientations using `OrientationBuilder`.
-  **Clean & Creative UI**: Uses `Material Design`, custom spacing, and a consistent layout.
-  **Animated Transitions**: Applies subtle scale animations via `AnimatedSwitcher` for a smooth user experience.
-  **Copy & Clear Buttons**: Copy the result or clear the display with intuitive controls.

## Installation

1. Ensure Flutter is installed: [Flutter Setup Guide](https://docs.flutter.dev/get-started/install)
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/temperature_converter_app.git
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

##  How to Use

1. Enter a temperature value in the input field.
2. Use the switch to select conversion mode:
   - Celsius to Fahrenheit  Fahrenheit to Celsius
3. Tap the Convert button.
4. View the animated result below.
5. Scroll through your conversion history.
6. Use Copy to copy results or Clear to reset.

##  Dependencies

- Flutter SDK (Stable Channel)
- Material Design (built-in)
- AnimatedSwitcher and OrientationBuilder (built-in Flutter widgets)

##  Code Highlights

- Uses StatefulWidget and setState() for reactive UI updates.
- Well-structured with modular widget-building methods (_buildInputSection, _buildResultSection, etc.).
- Includes clear, concise comments explaining design choices and logic.
- Maintains clean code conventions: descriptive names, consistent formatting, and UI separation.

##  Folder Structure

```
lib/
├── main.dart       # Main application file with state logic and widget structure
```

##  License

This project is open source and available under the MIT License.
