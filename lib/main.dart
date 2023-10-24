import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maps_launcher/maps_launcher.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SafeArea(child: JourneyPlannerApp()),
    );
  }
}

class JourneyPlannerApp extends StatefulWidget {
  const JourneyPlannerApp({super.key});

  @override
  _JourneyPlannerAppState createState() => _JourneyPlannerAppState();
}

class _JourneyPlannerAppState extends State<JourneyPlannerApp> {
  String searchText = '';
  List<dynamic> searchResults = [];

  Future<void> searchLocations(String query) async {
    final url = Uri.parse(
        'https://mvvvip1.defas-fgi.de/mvv/XML_STOPFINDER_REQUEST?language=de&outputFormat=RapidJSON&type_sf=any&name_sf=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        searchResults = json.decode(response.body)['locations'];
      });
    } else {
      //Handle Error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Journey Planner'),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) => searchLocations(value),
                      onChanged: (text) {
                        setState(() {
                          searchText = text;
                        });
                      },
                      decoration: const InputDecoration(
                          labelText: 'Enter a starting point'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      searchLocations(searchText);
                    },
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  //Get info to display
                  final result = searchResults[index];
                  String assembledName = result['name'];
                  String name = result['disassembledName'] ?? assembledName;
                  String location = result['parent']['name'];
                  String type = result['type'];

                  //Convert displayed info to utf-8
                  name = const Utf8Decoder().convert(name.codeUnits);
                  location = const Utf8Decoder().convert(location.codeUnits);
                  type = const Utf8Decoder().convert(type.codeUnits);
                  assembledName =
                      const Utf8Decoder().convert(assembledName.codeUnits);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      iconColor: Colors.blue,
                      collapsedShape: const RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.white,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.blue,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      expandedAlignment: Alignment.centerLeft,
                      collapsedBackgroundColor: Colors.white.withAlpha(150),
                      backgroundColor: Colors.white.withAlpha(150),
                      title: Text(
                        'Name: $name, ($type)',
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        'Ort: $location',
                        style: const TextStyle(color: Colors.black),
                      ),
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  LOREM_IPSUM50,
                                  softWrap: true,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Placeholder(
                                  fallbackHeight:
                                      MediaQuery.of(context).size.height * .12,
                                  fallbackWidth:
                                      MediaQuery.of(context).size.width * .18,
                                ),
                                TextButton(
                                    onPressed: () {
                                      //Coords delivered by api are not valid
                                      MapsLauncher.launchQuery(assembledName);
                                    },
                                    child: const Text('Find in Maps'))
                              ],
                            )
                          ],
                        ),
                      ],
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

const String LOREM_IPSUM50 =
    'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.';
