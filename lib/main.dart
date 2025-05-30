import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


// Entry point of the Flutter app. Runs the TemperatureConverterApp widget.
void main() {
  runApp(const TemperatureConverterApp());
}

class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TempXpert',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TemperatureConverterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() =>
      _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _temperatureController = TextEditingController();
  ConversionType _conversionType = ConversionType.celsiusToFahrenheit;
  String _result = '';
  final List<ConversionRecord> _conversionHistory = [];
  late AnimationController _animationController;
  Animation<double>? _animation;

  @override
  void initState()
  // Initialize the AnimationController and Animation for the AnimatedSwitcher transition.
  // This adds a scale transition effect when switching between conversion results.
  {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure animation is properly initialized after first frame
    _animation ??= CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      );
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _convertTemperature() {
    final input = _temperatureController.text;
    if (input.isEmpty) {
      _showError('Please enter a temperature value');
      return;
    }

    final double? temperature = double.tryParse(input);
    if (temperature == null) {
      _showError('Please enter a valid number');
      return;
    }

    double convertedTemp;
    String fromUnit, toUnit;
    IconData conversionIcon;

    if (_conversionType == ConversionType.celsiusToFahrenheit) {
      convertedTemp = (temperature * 9 / 5) + 32;
      fromUnit = '°C';
      toUnit = '°F';
      conversionIcon = Icons.arrow_upward;
    } else {
      convertedTemp = (temperature - 32) * 5 / 9;
      fromUnit = '°F';
      toUnit = '°C';
      conversionIcon = Icons.arrow_downward;
    }

    setState(() {
      _result = '${convertedTemp.toStringAsFixed(2)}$toUnit';
      _conversionHistory.insert(0, ConversionRecord(
        fromValue: temperature,
        toValue: convertedTemp,
        fromUnit: fromUnit,
        toUnit: toUnit,
        conversionType: _conversionType,
        icon: conversionIcon,
      ));
    });

    _animationController.reset();
    _animationController.forward();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _clearHistory() {
    setState(() {
      _conversionHistory.clear();
    });
  }

  void _copyResult() {
    if (_result.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Result copied to clipboard'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TempXpert'),
        centerTitle: true,
        actions: [
          if (_conversionHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearHistory,
              tooltip: 'Clear history',
            ),
        ],
      ),

      // Adjusts the app layout dynamically based on device orientation.
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputSection(colorScheme, textTheme),
                  const SizedBox(height: 24),
                  _animation == null
                      ? _buildResultSection(colorScheme, textTheme)
                      : ScaleTransition(
                    scale: _animation!,
                    child: _buildResultSection(colorScheme, textTheme),
                  ),
                  const SizedBox(height: 24),
                  _buildHistorySection(orientation, colorScheme, textTheme), // Displays a scrollable list of past conversions along with timestamps.
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature Input',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _temperatureController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                hintText: 'Enter temperature value',
                prefixIcon: Icon(
                  Icons.thermostat,
                  color: colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.onSurface),
                  onPressed: () => _temperatureController.clear(),
                ),
              ),
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Conversion Type',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<ConversionType>(
              segments: const [
                ButtonSegment(
                  value: ConversionType.celsiusToFahrenheit,
                  icon: Icon(Icons.arrow_upward),
                  label: Text('°C → °F'),
                ),
                ButtonSegment(
                  value: ConversionType.fahrenheitToCelsius,
                  icon: Icon(Icons.arrow_downward),
                  label: Text('°F → °C'),
                ),
              ],
              selected: {_conversionType},
              onSelectionChanged: (Set<ConversionType> newSelection) {
                setState(() {
                  _conversionType = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: colorScheme.surfaceVariant,
                side: BorderSide(color: colorScheme.outline),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _convertTemperature,
              icon: const Icon(Icons.autorenew),
              label: const Text('Convert'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conversion Result',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                if (_result.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.copy, color: colorScheme.primary),
                    onPressed: _copyResult,
                    tooltip: 'Copy result',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _result.isEmpty
                  ? Text(
                'No conversion yet',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _result,
                    style: textTheme.displaySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _conversionType == ConversionType.celsiusToFahrenheit
                        ? 'Celsius to Fahrenheit'
                        : 'Fahrenheit to Celsius',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(
      Orientation orientation, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conversion History',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                if (_conversionHistory.isNotEmpty)
                  Text(
                    '${_conversionHistory.length} items',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: orientation == Orientation.portrait ? 250 : 150,
              child: _conversionHistory.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No conversion history yet',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _conversionHistory.length,
                itemBuilder: (context, index) {
                  final record = _conversionHistory[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          record.icon,
                          color: colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        '${record.fromValue.toStringAsFixed(2)}${record.fromUnit} → ${record.toValue.toStringAsFixed(2)}${record.toUnit}',
                        style: textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        record.conversionType ==
                            ConversionType.celsiusToFahrenheit
                            ? 'Celsius to Fahrenheit'
                            : 'Fahrenheit to Celsius',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      trailing: Text(
                        '${record.toValue.toStringAsFixed(2)}${record.toUnit}',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ConversionType { celsiusToFahrenheit, fahrenheitToCelsius }

class ConversionRecord {
  final double fromValue;
  final double toValue;
  final String fromUnit;
  final String toUnit;
  final ConversionType conversionType;
  final IconData icon;

  ConversionRecord({
    required this.fromValue,
    required this.toValue,
    required this.fromUnit,
    required this.toUnit,
    required this.conversionType,
    required this.icon,
  });
}