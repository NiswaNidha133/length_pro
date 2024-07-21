import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'history_page.dart';

class LengthConverterPage extends StatefulWidget {
  @override
  _LengthConverterPageState createState() => _LengthConverterPageState();
}

class _LengthConverterPageState extends State<LengthConverterPage> {
  final TextEditingController _inputController = TextEditingController();
  String _inputUnit = 'Meters (m)';
  String _outputUnit = 'Kilometers (km)';
  String _result = '';
  String _error = ''; // To hold error messages
  bool _showResult = false; //To track result display
  bool _hasConverted = false; // Track if a conversion has been made
  late Box _historyBox; // Make the Hive box variable late

  final Map<String, Map<String, double>> _conversionTable = {
    'Millimeters (mm)': {
      'Centimeters (cm)': 0.1,
      'Meters (m)': 0.001,
      'Kilometers (km)': 0.000001,
      'Inches (in)': 0.0393701,
      'Feet (ft)': 0.00328084,
    },
    'Centimeters (cm)': {
      'Millimeters (mm)': 10,
      'Meters (m)': 0.01,
      'Kilometers (km)': 0.00001,
      'Inches (in)': 0.393701,
      'Feet (ft)': 0.0328084,
    },
    'Meters (m)': {
      'Millimeters (mm)': 1000,
      'Centimeters (cm)': 100,
      'Kilometers (km)': 0.001,
      'Inches (in)': 39.3701,
      'Feet (ft)': 3.28084,
    },
    'Kilometers (km)': {
      'Millimeters (mm)': 1000000,
      'Centimeters (cm)': 100000,
      'Meters (m)': 1000,
      'Inches (in)': 39370.1,
      'Feet (ft)': 3280.84,
    },
    'Inches (in)': {
      'Millimeters (mm)': 25.4,
      'Centimeters (cm)': 2.54,
      'Meters (m)': 0.0254,
      'Kilometers (km)': 0.0000254,
      'Feet (ft)': 0.0833333,
    },
    'Feet (ft)': {
      'Millimeters (mm)': 304.8,
      'Centimeters (cm)': 30.48,
      'Meters (m)': 0.3048,
      'Kilometers (km)': 0.0003048,
      'Inches (in)': 12,
    },
  };

  final Map<String, String> _unitShortForms = {
    'Millimeters (mm)': 'mm',
    'Centimeters (cm)': 'cm',
    'Meters (m)': 'm',
    'Kilometers (km)': 'km',
    'Inches (in)': 'in',
    'Feet (ft)': 'ft',
  };

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    _historyBox = await Hive.openBox('historyBox'); // Initialize the Hive box
  }

  void _convert() {
    if (_inputController.text.isEmpty) {
      setState(() {
        _result = '';
        _error = 'Please enter a value';
        _showResult = false; // Hide the result box for the error message
        _hasConverted = false;
      });
      return;
    }

    double inputValue;
    try {
      inputValue = double.parse(_inputController.text);
    } catch (e) {
      setState(() {
        _result = '';
        _error = 'Invalid input. Please enter a number.';
        _showResult = false; // Hide the result box for the error message
        _hasConverted = false;
      });
      return;
    }

    double outputValue;
    try {
      outputValue =
          inputValue * (_conversionTable[_inputUnit]![_outputUnit] ?? 0);
    } catch (e) {
      setState(() {
        _result = '';
        _error = 'Error in conversion.';
        _showResult = false;
        _hasConverted = false;
      });
      return;
    }

    // Convert units to their short forms
    String inputUnitShort = _unitShortForms[_inputUnit] ?? _inputUnit;
    String outputUnitShort = _unitShortForms[_outputUnit] ?? _outputUnit;

    setState(() {
      _result = '$inputValue $inputUnitShort = $outputValue $outputUnitShort';
      _error = '';
      _showResult = true; // Show the result box
      _hasConverted = true; // Mark that a conversion has been made
    });

    // Create a unique identifier for the conversion
    String uniqueId =
        '${inputValue}_${_inputUnit}_${outputValue}_${_outputUnit}';

    // Check if a similar entry already exists in history
    bool exists = _historyBox.values
        .cast<Map>()
        .any((entry) => entry['uniqueId'] == uniqueId);

    if (!exists) {
      // Save the conversion to history if it doesn't exist
      try {
        _historyBox.add({
          'inputValue': inputValue,
          'inputUnit': _inputUnit,
          'outputValue': outputValue,
          'outputUnit': _outputUnit,
          'timestamp': DateTime.now().toIso8601String(),
          'uniqueId': uniqueId, // Add the unique identifier
        });
      } catch (e) {
        print('Error saving to history: $e');
      }
    }
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(0xFF9172EC); // Define the theme color

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Length Pro',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: themeColor, // Use the theme color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color of the box
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.3), // Theme color shadow
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: TextField(
                controller: _inputController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: InputBorder.none, // Removes the default underline
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  labelText: 'Enter length',
                  errorText:
                      _error.isNotEmpty ? _error : null, // Show error message
                ),
                onChanged: (text) {
                  setState(() {
                    _error = ''; // Clear error when user starts typing
                  });
                },
                onSubmitted: (text) {
                  _convert(); // Trigger conversion when Enter is pressed
                },
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      bottom: 4.0), // Reduced space below the first dropdown
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color of the box
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color:
                            themeColor.withOpacity(0.3), // Theme color shadow
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _inputUnit,
                    underline: Container(), // Removes the default underline
                    items: _conversionTable.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Text(key),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _inputUnit = newValue!;
                      });
                    },
                  ),
                ),
                SizedBox(
                    height:
                        4), // Reduced space between the text and second dropdown
                Text(
                  'to', // Label text
                  style: TextStyle(
                    fontSize: 16, // Slightly smaller font size
                    fontWeight: FontWeight.bold,
                    color: themeColor, // Use the theme color
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(
                    height:
                        4), // Reduced space between the label and the second dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color of the box
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color:
                            themeColor.withOpacity(0.3), // Theme color shadow
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _outputUnit,
                    underline: Container(), // Removes the default underline
                    items: _conversionTable[_inputUnit]!.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Text(key),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _outputUnit = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center, // Center the button horizontally
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 150, // Adjust max width as needed
                ),
                child: ElevatedButton(
                  onPressed: _convert,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        themeColor), // Button color set to theme color
                    foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.white), // Text color
                  ),
                  child: Text('Convert'),
                ),
              ),
            ),
            SizedBox(height: 20),
            _showResult
                ? Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color:
                              themeColor.withOpacity(0.3), // Theme color shadow
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Conversion Result:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          _result,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : Container(), // Empty container when result is not available
            Spacer(), // Pushes the button to the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: _showHistory,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      themeColor), // Button color set to theme color
                  foregroundColor: WidgetStateProperty.all<Color>(
                      Colors.white), // Text color
                ),
                child: Text('View History'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('historyBox');
  runApp(MaterialApp(
    home: LengthConverterPage(),
    routes: {
      '/history': (context) => HistoryPage(),
    },
  ));
}
