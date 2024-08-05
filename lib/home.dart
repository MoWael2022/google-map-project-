import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late BitmapDescriptor customMarker;
  late Position myPosition;
  late GoogleMapController gmc;
  late StreamSubscription<Position> streamSubscription;

  // List<LatLng> myPoint =
  addCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/Contact.png");
  }

  checkServiceLocator() async {
    bool serviceLocator = await Geolocator.isLocationServiceEnabled();
    print("============================");
    print(serviceLocator);
    print("============================");

    LocationPermission per = await Geolocator.checkPermission();
    if (per == LocationPermission.denied) {
      Geolocator.requestPermission();
    }
    print("============================");
    print(per);
    print("============================");
  }

  Future<Position> getCurrentPosition() async {
    Position currentPosition =
        await Geolocator.getCurrentPosition().then((value) => value);
    myMarkers.add(Marker(
        markerId: MarkerId("1"),
        draggable: true,
        position: LatLng(currentPosition.latitude, currentPosition.longitude)));

    return currentPosition ;
  }

  @override
  void initState() {
    streamSubscription = Geolocator.getPositionStream().listen((position) {
      print(position.latitude);
      print(position.longitude);
    });
    super.initState();
    addCustomMarker();
    checkServiceLocator();
  }

  changeMarker(newLat, newLong) {
    myMarkers.add(Marker(
      markerId: const MarkerId("1"),
      position: LatLng(newLat, newLong),
    ));
  }

  Set<Circle> myCircle = {
    const Circle(
      circleId: CircleId("1"),
      radius: 4000,
      strokeColor: Colors.white12,
      center: LatLng(30.0444, 31.2357),
      fillColor: Colors.lightBlueAccent,
    ),
  };

  Set<Marker> myMarkers = {};

  Set<Polyline> myPolyline = {
    Polyline(
        polylineId: PolylineId("1"),
        points: const [
          LatLng(29.990000, 31.149000),
          LatLng(29.999000, 31.149900),
        ],
        color: Colors.blue,
        width: 3,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(10),
        ]),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
      ),
      body: Column(
        children: [
          Container(
            height: 400,
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder(
                future: getCurrentPosition(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GoogleMap(

                      //circles: myCircle,
                      initialCameraPosition: CameraPosition(
                          target: LatLng(30.04282108805554, 31.234436151124825),
                          zoom: 1),
                      onMapCreated: (googleMapController) {
                        gmc = googleMapController;
                        setState(() {
                          myMarkers.add(
                            Marker(
                              markerId: (MarkerId('cairo location')),
                              position: LatLng(snapshot.data!.latitude,
                                  snapshot.data!.longitude),
                              infoWindow: const InfoWindow(
                                title: "cairo",
                                snippet:
                                "cairo is capital of egypt om eldonia ",
                              ),

                              icon: customMarker,
                            ),
                          );
                        });
                      },
                      markers: myMarkers,
                      polylines: myPolyline,
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error"),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
          ElevatedButton(
            onPressed: () async {
              gmc.animateCamera(CameraUpdate.newCameraPosition(
                  const CameraPosition(
                      target: LatLng(31.268760127409607, 32.300572362418215),
                      zoom: 12)));
              gmc.getLatLng(ScreenCoordinate(x: 200, y: 200));
            },
            child: const Text("Go to Portsaid"),
          ),
        ],
      ),
    );
  }
}
