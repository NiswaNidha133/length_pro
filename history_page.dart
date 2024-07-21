import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conversion History',
          style: TextStyle(
            color: Colors.white, 
          ),
        ),
        backgroundColor: Color(0xFF9172EC), 
        iconTheme: IconThemeData(
          color: Colors.white, 
        ),
      ),
      body: FutureBuilder(
        future: Hive.openBox('historyBox'),
        builder: (context, AsyncSnapshot<Box> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Box historyBox = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: historyBox.listenable(),
                    builder: (context, Box box, widget) {
                      if (box.isEmpty) {
                        return Center(
                          child: Text('No history available.'),
                        );
                      }

                      // Debug print to see the contents of the box
                      print('Box contents: ${box.toMap()}');

                      // Define a map for unit short forms
                      final Map<String, String> unitShortForms = {
                        'Millimeters (mm)': 'mm',
                        'Centimeters (cm)': 'cm',
                        'Meters (m)': 'm',
                        'Kilometers (km)': 'km',
                        'Inches (in)': 'in',
                        'Feet (ft)': 'ft',
                      };
                      // Group entries by date
                      Map<String, List<Map>> groupedEntries = {};
                      List<Map> entries =
                          box.toMap().values.cast<Map>().toList();
                      for (var entry in entries) {
                        print('Entry: $entry'); // Debug print
                        String timestamp = entry['timestamp'] ?? '';
                        try {
                          DateTime parsedDate = DateTime.parse(timestamp);
                          String date =
                              DateFormat('dd/MM/yyyy').format(parsedDate);
                          if (!groupedEntries.containsKey(date)) {
                            groupedEntries[date] = [];
                          }
                          groupedEntries[date]!.add(entry);
                        } catch (e) {
                          print(
                              'Error parsing timestamp $timestamp: $e'); // Debug print
                        }
                      }

                      List<String> dates = groupedEntries.keys.toList();
                      dates.sort((a, b) =>
                          b.compareTo(a)); // Sort dates in descending order

                      return ListView(
                        padding: EdgeInsets.all(16.0),
                        children: dates.map((date) {
                          List<Map> dateEntries = groupedEntries[date]!;

                          // Sort entries of the same date by time in descending order
                          dateEntries.sort((a, b) =>
                              DateTime.parse(b['timestamp'])
                                  .compareTo(DateTime.parse(a['timestamp'])));

                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    20.0), // Increased spacing between items
                            padding: EdgeInsets.all(
                                16.0), // Adjust padding inside the box
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  12.0), // Increased border radius for rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF9172EC).withOpacity(
                                      0.3), 
                                  spreadRadius: 4,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: Text(
                                    date,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color:
                                          Color(0xFF9172EC), 
                                    ),
                                  ),
                                ),
                                ...dateEntries.map((entry) {
                                  
                                  String inputUnitShort =
                                      unitShortForms[entry['inputUnit']] ??
                                          entry['inputUnit'];
                                  String outputUnitShort =
                                      unitShortForms[entry['outputUnit']] ??
                                          entry['outputUnit'];

                                  return Container(
                                    margin: EdgeInsets.only(
                                        bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${entry['inputValue']} $inputUnitShort = ${entry['outputValue']} $outputUnitShort',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          // Ensure the time is displayed properly
                                          DateFormat('h:mm a').format(
                                              DateTime.parse(
                                                  entry['timestamp'])),
                                          style: TextStyle(
                                            color: Color(
                                                0xFF9172EC), // Time text color
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            int entryKey = box.keys.firstWhere(
                                              (key) =>
                                                  (box.get(key)
                                                      as Map)['timestamp'] ==
                                                  entry['timestamp'],
                                              orElse: () => -1,
                                            );
                                            if (entryKey != -1) {
                                              bool? confirm = await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text('Delete Entry'),
                                                  content: Text(
                                                      'Are you sure you want to delete this entry?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                      child: Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                await box.delete(entryKey);
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Clear History'),
                          content: Text(
                              'Are you sure you want to clear all history?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Clear'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        historyBox.clear();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Color(
                          0xFF9172EC)), // Button color set to Portage (#9172EC)
                      foregroundColor: WidgetStateProperty.all<Color>(
                          Colors.white), // Text color
                    ),
                    child: Text('Clear History'),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
