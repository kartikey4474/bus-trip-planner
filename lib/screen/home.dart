import 'dart:convert';
import 'dart:ffi';
import 'package:experimentt/models/route_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RouteDetails> busRoutes = [];
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  String outputintermediate = "";

  String output = "";
  String intermediateStop = "";

  @override
  Widget build(BuildContext context) {
    final double referenceWidth =
        428; // Use the width of the iPhone 13 Pro Max in Figma
    final double screenWidth = MediaQuery.of(context).size.width;
    final double convertedWidth = screenWidth / referenceWidth;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Image.asset(
                        'assets/yellowdot.png',
                        height: 16,
                        width: 16,
                      ),
                      const Dash(
                        length: 42,
                        dashColor: Color(0xFFA3A3A3),
                        direction: Axis.vertical,
                      ),
                      Image.asset(
                        'assets/Vector.png',
                        height: 32,
                        width: 32,
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        TextField(
                          controller: originController,
                          style: const TextStyle(fontSize: 24),
                          decoration: const InputDecoration(
                            hintText: 'Origin',
                            border: InputBorder.none,
                            filled: false,
                            fillColor: null,
                            hintStyle: TextStyle(fontSize: 24),
                          ),
                        ),
                        const Divider(thickness: 2),
                        TextField(
                          controller: destinationController,
                          style: const TextStyle(fontSize: 24),
                          decoration: const InputDecoration(
                            hintText: 'Destination',
                            border: InputBorder.none,
                            filled: false,
                            fillColor: null,
                            hintStyle: TextStyle(fontSize: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFFFEB844),
                    ),
                    child: IconButton(
                      onPressed: () {
                        String temp = originController.text;
                        originController.text = destinationController.text;
                        destinationController.text = temp;
                      },
                      icon: const Icon(Icons.swap_vert),
                      iconSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const SizedBox(
                    width: 38,
                  ),
                  SizedBox(
                    width: convertedWidth * 275,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          busRoutes.clear();
                        });
                        fetchDirections();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        primary: const Color(0xFFFEB844),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16),
                      ),
                      child: const Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Available Routes',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: busRoutes.length,
                    itemBuilder: (context, index) {
                      final route = busRoutes[index];
                      final duration = route.busDuration ?? '';
                      output = "";
                      outputintermediate = "";
                      intermediateStop = "";

                      final startingStopBusNumbers = <String>[];
                      final intermediateStopBusNumbers = <String>[];

                      // Iterate through each bus number and determine whether it is a starting stop bus number or an intermediate stop bus number
                      for (int i = 0; i < route.busNumbers.length; i++) {
                        final busNumber = route.busNumbers[i];

                        if (i == 0) {
                          // First bus number is considered as a starting stop bus number
                          output += "${route.busNumbers[i]} ";
                          if (i < route.busNumbers.length - 1) {
                            output += ", ";
                          }
                        } else {
                          // Remaining bus numbers are considered as intermediate stop bus numbers
                          outputintermediate += busNumber;
                          if (i < route.busNumbers.length - 1) {
                            outputintermediate += ", ";
                          }
                        }
                      }

                      for (final stop in route.intermediateStops) {
                        intermediateStop += stop;
                      }

                      // for (int i = 0; i < route.busNumbers.length; i++)
                      //   if (route.busNumbers[i].isNotEmpty)
                      //     output += route.busNumbers[i] + " ";

                      return GestureDetector(
                        //   onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => RouteDetailsPage(route: route),
                        //     ),
                        //   );
                        // },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          height: convertedWidth * 139 + 85,
                          width: convertedWidth * 396,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Column(children: [
                            if (route.busNumbers.isNotEmpty)
                              const SizedBox(
                                height: 16,
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 16,
                                ),
                                Image.asset(
                                  'assets/busicon.png',
                                  height: 16,
                                  width: 16,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Text(
                                    output,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  'assets/yellowdot.png',
                                  height: 16,
                                  width: 16,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                    child: Text(
                                  route.startingStop ?? 'Unknown',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                )),
                              ],
                            ),
                            const Row(
                              children: [
                                SizedBox(
                                  width: 196,
                                ),
                                Dash(
                                  length: 25,
                                  dashColor: Color(0xFFA3A3A3),
                                  direction: Axis.vertical,
                                ),
                              ],
                            ),
                            if (route.intermediateStops.isNotEmpty ||
                                route.finalStop != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Image.asset(
                                    'assets/busicon.png',
                                    height: 16,
                                    width: 16,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      outputintermediate,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width: 8,
                                  // ),
                                  Image.asset(
                                    'assets/bluedot.png',
                                    height: 16,
                                    width: 16,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),

                                  Expanded(
                                      child: Text(
                                    intermediateStop,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )),
                                ],
                              ),
                            const Row(
                              children: [
                                SizedBox(
                                  width: 196,
                                ),
                                Dash(
                                  length: 25,
                                  dashColor: Color(0xFFA3A3A3),
                                  direction: Axis.vertical,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 32,
                                ),
                                // Image.asset(
                                //   'assets/busicon.png',
                                //   height: 16,
                                //   width: 16,
                                // ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                // SizedBox(
                                //   width: 8,
                                // ),
                                Image.asset(
                                  'assets/bluedot.png',
                                  height: 16,
                                  width: 16,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    route.finalStop ?? 'Unknown',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Row(
                              children: [
                                Dash(
                                  length: 350,
                                  dashColor: Color(0xFFA3A3A3),
                                  direction: Axis.horizontal,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 4,
                                ),
                                Container(
                                  width: 157,
                                  height: 29,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 1, color: Color(0xFFFEB844)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Row(children: [
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Image.asset(
                                      'assets/arrow.png',
                                      height: 16,
                                      width: 16,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      'View directions',
                                      style: TextStyle(
                                        color: Color(0xFFFEB844),
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ]),
                                ),
                                // Text(
                                //   'Arriving in 99 min',
                                //   style: GoogleFonts.poppins(
                                //     fontSize: 16,
                                //     fontWeight: FontWeight.normal,
                                //   ),
                                // ),
                                SizedBox(
                                  width: 98,
                                ),
                                Image.asset(
                                  'assets/clockicon.png',
                                  height: 24,
                                  width: 24,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Text(
                                    duration,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ]),
                        ),
                      );

                      // return Card(
                      //   elevation: 4.0,
                      //   margin: const EdgeInsets.symmetric(vertical: 8.0),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Align(
                      //         alignment: Alignment.topRight,
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Text(
                      //             duration,
                      //             style: const TextStyle(
                      //               fontSize: 16.0,
                      //               fontWeight: FontWeight.bold,
                      //               color: Colors.deepPurple,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       ListTile(
                      //         title: Text(
                      //           'Route ${index + 1}',
                      //           style:
                      //               const TextStyle(fontWeight: FontWeight.bold),
                      //         ),
                      //         subtitle: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             if (route.busNumbers.isNotEmpty)
                      //               Padding(
                      //                 padding: const EdgeInsets.only(bottom: 8.0),
                      //                 child: Row(
                      //                   children: [
                      //                     for (int i = 0;
                      //                         i < route.busNumbers.length;
                      //                         i++)
                      //                       Row(
                      //                         children: [
                      //                           Text(
                      //                             route.busNumbers[i],
                      //                             style: const TextStyle(
                      //                                 fontSize: 16.0),
                      //                           ),
                      //                           const SizedBox(width: 8.0),
                      //                           const Icon(
                      //                             Icons.directions_bus,
                      //                             color: Colors.deepPurple,
                      //                           ),
                      // if (i <
                      //     route.busNumbers.length - 1)
                      //                             Row(
                      //                               children: [
                      //                                 const Icon(
                      //                                   Icons.arrow_forward,
                      //                                   color: Colors.deepPurple,
                      //                                 ),
                      //                                 const SizedBox(width: 8.0),
                      //                               ],
                      //                             ),
                      //                         ],
                      //                       ),
                      //                     if (route.busNumbers.length > 1)
                      //                       const SizedBox(width: 8.0),
                      //                     if (route.busNumbers.length > 1)
                      //                       const Icon(
                      //                         Icons.arrow_forward,
                      //                         color: Colors.deepPurple,
                      //                       ),
                      //                     if (route.busNumbers.length > 1)
                      //                       const SizedBox(width: 8.0),
                      //                     if (route.busNumbers.length > 1)
                      //                       const Icon(
                      //                         Icons.location_on,
                      //                         color: Colors.deepPurple,
                      //                       ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             if (route.intermediateStops.isNotEmpty ||
                      //                 route.finalStop != null)
                      //               Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   const SizedBox(height: 8.0),
                      //                   const Text(
                      //                     'Intermediate Stops:',
                      //                     style: TextStyle(fontSize: 16.0),
                      //                   ),
                      //                   if (route.intermediateStops.isNotEmpty)
                      //                     for (final stop
                      //                         in route.intermediateStops)
                      //                       Row(
                      //                         children: [
                      //                           const Icon(
                      //                             Icons.arrow_downward,
                      //                             color: Colors.deepPurple,
                      //                           ),
                      //                           Text(
                      //                             '- $stop',
                      //                             style: const TextStyle(
                      //                                 fontSize: 16.0),
                      //                           ),
                      //                         ],
                      //                       ),
                      //                   if (route.finalStop != null)
                      //                     Row(
                      //                       children: [
                      //                         const Icon(
                      //                           Icons.arrow_forward,
                      //                           color: Colors.deepPurple,
                      //                         ),
                      //                         const SizedBox(width: 8.0),
                      //                         const Icon(
                      //                           Icons.location_on,
                      //                           color: Colors.deepPurple,
                      //                         ),
                      //                       ],
                      //                     ),
                      //                 ],
                      //               ),
                      //             const SizedBox(height: 8.0),
                      //             Row(
                      //               children: [
                      //                 const Icon(
                      //                   Icons.location_on,
                      //                   color: Colors.deepPurple,
                      //                 ),
                      //                 const SizedBox(width: 8.0),
                      //                 Text(
                      //                   'Final Stop: ${route.finalStop ?? 'Unknown'}',
                      //                   style: const TextStyle(fontSize: 16.0),
                      //                 ),
                      //               ],
                      //             ),
                      //             const SizedBox(height: 8.0),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchDirections() async {
    setState(() {
      isLoading = true;
    });

    const apiKey = 'AIzaSyA2qCKPKyZxgznPCEPjE0xk56wJT-59-v4';
    final origin = Uri.encodeQueryComponent(originController.text);
    final destination = Uri.encodeQueryComponent(destinationController.text);

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&mode=transit&destination=$destination&alternatives=true&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        List<RouteDetails> extractedRoutes = [];

        for (final route in decodedData['routes']) {
          final busNumbers = <String>[];
          String? startingStop;
          String? finalStop;
          int? busDuration;
          List<String> intermediateStops = [];
          List<String> transfers = [];

          for (final leg in route['legs']) {
            for (final step in leg['steps']) {
              if (step['travel_mode'] == 'TRANSIT' &&
                  step['transit_details'] != null &&
                  step['transit_details']['line'] != null &&
                  step['transit_details']['line']['vehicle'] != null &&
                  step['transit_details']['line']['vehicle']['type'] == 'BUS' &&
                  step['transit_details']['line']['short_name'] != null) {
                final busNumber = step['transit_details']['line']['short_name'];
                busNumbers.add(busNumber);

                final currentStop =
                    step['transit_details']['departure_stop']['name'];
                if (startingStop == null) {
                  startingStop = currentStop;
                } else if (currentStop != startingStop) {
                  intermediateStops.add(currentStop);

                  final transferBusNumber =
                      step['transit_details']['line']['short_name'];
                  transfers.add(
                      'Transfer at $currentStop (Take bus $transferBusNumber)');
                }

                final nextStop =
                    step['transit_details']['arrival_stop']['name'];
                if (nextStop != currentStop) {
                  final nextBusNumber =
                      step['transit_details']['line']['short_name'];
                  transfers.add('Take bus $nextBusNumber from $currentStop');
                }

                finalStop = nextStop;
              }
            }
            busDuration = leg['duration']['value'];
            print('Bus Duration: $busDuration');
          }

          extractedRoutes.add(
            RouteDetails(
              busNumbers: List.from(busNumbers),
              startingStop: startingStop,
              finalStop: finalStop,
              busDuration: formatDuration(busDuration),
              intermediateStops: intermediateStops,
              transfers: transfers,
            ),
          );
        }

        setState(() {
          busRoutes = extractedRoutes;
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDuration(int? duration) {
    if (duration == null) {
      return '';
    }

    final minutes = (duration / 60).round();
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }
}
