import 'dart:async';
import 'dart:math';

import 'package:circulahealth/components/chat.dart';
import 'package:circulahealth/components/community.dart';
import 'package:circulahealth/components/donor.dart';
import 'package:circulahealth/components/settings.dart';
import 'package:circulahealth/components/loading_component.dart';
import 'package:circulahealth/providers/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class BottomIcon {
  final IconData icon;
  final String title;

  BottomIcon({
    required this.icon,
    required this.title,
  });
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  Set<Circle> _circles = {};

  double? currentZoomLevel;

  static const CameraPosition _kLake = CameraPosition(
    bearing: 0,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 0,
    zoom: 16.151926040649414,
  );

  final List<String> bloodTypes = ["A", "B", "O+", "O-", "AB+", "AB-"];
  final List<BottomIcon> bottomIcons = [
    BottomIcon(
      icon: Icons.bloodtype,
      title: "Donor",
    ),
    BottomIcon(
      icon: Icons.people,
      title: "Community",
    ),
    BottomIcon(
      icon: Icons.find_in_page,
      title: "Find",
    ),
    BottomIcon(
      icon: Icons.help,
      title: "AI Help",
    ),
    BottomIcon(
      icon: Icons.settings,
      title: "Settings",
    ),
  ];
  String currentBloodType = "";
  String pageState = "";
  double currentLatitude = -6.2;
  double currentLongitude = 106.816666;
  LatLng theDestination = const LatLng(-6.200000, 106.816666);
  bool isLoading = false;

  Future<void> setZoomLevel() async {
    if (_controller != null) {
      double position = await _controller!.getZoomLevel();
      setState(() {
        currentZoomLevel = position;
      });
    }
  }

  final Set<Marker> _markers = {};

  Set<Polyline> _polylines = {};

  LatLngBounds _createBounds(LatLng pos1, LatLng pos2) {
    final southWest = LatLng(
      min(pos1.latitude, pos2.latitude),
      min(pos1.longitude, pos2.longitude),
    );

    final northEast = LatLng(
      max(pos1.latitude, pos2.latitude),
      max(pos1.longitude, pos2.longitude),
    );

    return LatLngBounds(southwest: southWest, northeast: northEast);
  }

  Future<void> _fitBounds(LatLng userLocation, LatLng destination) async {
    final bounds = _createBounds(userLocation, destination);
    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 40);

    // Ensure the map is fully initialized
    await Future.delayed(const Duration(milliseconds: 300));
    _controller?.animateCamera(cameraUpdate);
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Future<List<LatLng>> getRoutePoints(LatLng origin, LatLng destination) async {
    const apiKey = 'AIzaSyBR84O9wqhKn8_8GHELgHdkqOckmeNGy40';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey&mode=driving';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0]['overview_polyline']['points'];

      return _decodePolyline(route);
    } else {
      throw Exception('Failed to get directions');
    }
  }

  void _drawRoute(List<LatLng> polylinePoints) {
    final polyline = Polyline(
      polylineId: const PolylineId("route"),
      color: Colors.blue,
      width: 5,
      points: polylinePoints,
    );

    setState(() {
      _polylines.clear();
      _polylines.add(polyline);
    });
  }

  Future<LatLng?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId("user_location"),
          center: LatLng(position.latitude, position.longitude),
          radius: 20, // meters
          fillColor: Colors.blue.withOpacity(0.4),
          strokeColor: Colors.blue,
          strokeWidth: 1,
        ),
      };
    });

    return LatLng(position.latitude, position.longitude);
  }

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _pages = <Widget>[
    Donor(),
    Community(),
    const Center(child: Text('AI Help Page')),
    ChatApp(),
    Settings(),
  ];

  void _setDestinationMarker(LatLng position) {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'destination');
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: position,
          infoWindow: const InfoWindow(title: "Destination"),
        ),
      );
    });
  }

  void _showRouteToDestination() async {
    try {
      setState(() {
        isLoading = true;
      });
      LatLng? currentLocation = await _getCurrentLocation();
      if (currentLocation != null) {
        final routePoints =
            await getRoutePoints(currentLocation, theDestination);
        _setDestinationMarker(theDestination);
        _drawRoute(routePoints);

        await _fitBounds(currentLocation, theDestination);
        setState(() {
          setZoomLevel();
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, mainProvider, child) {
        return mainProvider.selectedIndex == 2
            ? Scaffold(
                backgroundColor: Colors.white,
                body: Stack(
                  children: [
                    Positioned.fill(
                      bottom: 0,
                      top: 0,
                      left: 0,
                      right: 0,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        tiltGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        buildingsEnabled: false,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(-6.200000, 106.816666),
                          zoom: 14.4746,
                        ),
                        circles: _circles,
                        onMapCreated: (GoogleMapController controller) async {
                          setState(() {
                            _controller = controller;
                            _showRouteToDestination();
                          });
                        },
                        markers: _markers,
                        polylines: _polylines,
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                  color: const Color(0xFFDFDFDF),
                                  width: 2.0,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.center,
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Find',
                                  // prefixIcon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onSubmitted: (value) {
                                  print(value);
                                },
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                pageState != ""
                                    ? Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 24,
                                          horizontal: 16,
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Find $pageState",
                                                  style: const TextStyle(
                                                    color: Color(
                                                      0xFFF87848,
                                                    ),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      pageState = "";
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.black,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 20,
                                              ),
                                              height: 33,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: bloodTypes.length,
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        currentBloodType =
                                                            bloodTypes[index];
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 72,
                                                      height: 33,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xFFEFEFEF),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          98,
                                                        ),
                                                        color:
                                                            currentBloodType ==
                                                                    bloodTypes[
                                                                        index]
                                                                ? const Color(
                                                                    0xFFF87848)
                                                                : Colors.white,
                                                      ),
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        bloodTypes[index],
                                                        style: TextStyle(
                                                          color:
                                                              currentBloodType ==
                                                                      bloodTypes[
                                                                          index]
                                                                  ? Colors.white
                                                                  : const Color(
                                                                      0xFFB1B1B1,
                                                                    ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 20,
                                              ),
                                              width: double.infinity,
                                              height: 300,
                                              child: ListView.builder(
                                                scrollDirection: Axis.vertical,
                                                itemCount: 50,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        isLoading = true;
                                                        theDestination = LatLng(
                                                            theDestination
                                                                    .latitude -
                                                                0.05,
                                                            theDestination
                                                                    .longitude -
                                                                0.05);
                                                        _showRouteToDestination();
                                                        pageState = "";
                                                      });
                                                    },
                                                    child: const Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 25.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              bottom: 8.0,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Darah AB+",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "6 km",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        Color(
                                                                      0xFFF87848,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Text(
                                                            "Rumah Sakit Hermina, Cibuyut",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Color(
                                                                0xFFB0B0B0,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  pageState = "blood";
                                                });
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.only(
                                                  bottom: 20,
                                                  right: 7.5,
                                                ),
                                                // padding: const EdgeInsets.all(16.0),
                                                height: 162,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFF8E65,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(17),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(16.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Find blood",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: SvgPicture.asset(
                                                        'assets/images/blood-bg.svg',
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  pageState = "donor";
                                                });
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 20,
                                                  left: 7.5,
                                                ),
                                                height: 162,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFAB92FF,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(17),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(16.0),
                                                      child: Text(
                                                        "Find donor",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: SvgPicture.asset(
                                                        'assets/images/donor-bg.svg',
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        for (int i = 0;
                                            i < bottomIcons.length;
                                            i++) ...[
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  mainProvider
                                                      .setSelectedIndex(i);
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    bottomIcons[i].icon,
                                                    size: 24,
                                                    color: mainProvider
                                                                .currentBottomTitle ==
                                                            bottomIcons[i].title
                                                        ? const Color(
                                                            0xFF216FFF)
                                                        : const Color(
                                                            0xFFBFBFBF),
                                                  ),
                                                  Text(
                                                    bottomIcons[i].title,
                                                    style: TextStyle(
                                                      color: mainProvider
                                                                  .currentBottomTitle ==
                                                              bottomIcons[i]
                                                                  .title
                                                          ? const Color(
                                                              0xFF216FFF)
                                                          : const Color(
                                                              0xFFBFBFBF),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ]
                                      ]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isLoading) const LoadingComponent(),
                  ],
                ),
              )
            : DefaultTabController(
                length: 2,
                child: SafeArea(
                  child: Stack(
                    children: [
                      Scaffold(
                        appBar: mainProvider.showAppBar
                            ? PreferredSize(
                                preferredSize:
                                    const Size.fromHeight(kToolbarHeight),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      // Shadow
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey,
                                          width: 1), // Bottom border
                                    ),
                                  ),
                                  child: AppBar(
                                    backgroundColor: Colors.white,
                                    elevation:
                                        0, // Remove default shadow since we're using BoxShadow
                                    leading: IconButton(
                                      icon: const Icon(Icons.arrow_back,
                                          color: Colors.black),
                                      onPressed: () {
                                        mainProvider.setShowAppBar(false);
                                        mainProvider.setDonorPageState(
                                            DonorPageState.profile);
                                      },
                                    ),
                                    title: Text(mainProvider.appBarTitle,
                                        style: const TextStyle(
                                            color: Colors.black)),
                                    centerTitle: true,
                                  ),
                                ),
                              )
                            : null,
                        body: _pages[mainProvider.selectedIndex],
                        bottomNavigationBar: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, -1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: BottomNavigationBar(
                            currentIndex: mainProvider.selectedIndex,
                            onTap: (int index) {
                              setState(() {
                                mainProvider.setSelectedIndex(index);
                                mainProvider.setCurrentBottomTitle(
                                    bottomIcons[index].title);
                              });
                            },
                            selectedItemColor: const Color(0xFF216FFF),
                            unselectedItemColor: const Color(0xFFBFBFBF),
                            type: BottomNavigationBarType.fixed,
                            items: [
                              for (int i = 0; i < bottomIcons.length; i++) ...[
                                BottomNavigationBarItem(
                                  icon: Icon(bottomIcons[i].icon),
                                  label: bottomIcons[i].title,
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                      if (mainProvider.isLoading) const LoadingComponent()
                    ],
                  ),
                ),
              );
      },
    );
  }
}
