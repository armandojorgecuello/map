import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geojson/geojson.dart';
import 'package:latlong2/latlong.dart';
import 'package:geopoint/geopoint.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:offline_maps_app/src/db_provider/db_provider.dart';

class _NearbyAirportsPageState extends State<NearbyAirportsPage> {
  final mapController = MapController();
  final markers = <Marker>[];
  var geopointData = <GeoJsonPoint>[];
  final geo = GeoJson();
  late StreamSubscription<GeoJsonPoint> sub;
  final markersSelected = <GeoJsonPoint>[];
  final dataIsLoaded = Completer<Null>();
  String status = "Loading data ...";

  @override
  void initState() {
    super.initState();
    loadAirports().then((_) {
      dataIsLoaded.complete();
      mapController.move(LatLng(geopointData.first.geoPoint.latitude, geopointData.first.geoPoint.longitude ), 16);
      searchNearbyAirports(LatLng(geopointData.first.geoPoint.latitude, geopointData.first.geoPoint.longitude ));
      setState(() => status = "Tap on map to search for airports");
    });
    sub = geo.processedPoints.listen((point) {
      geopointData.isNotEmpty ? print(geopointData.first.geoPoint.longitude) : print("Esta vacia");
      // listen for the geofenced airports
      var rng = new Random();
      setState(() => markers.add(Marker(
        key: Key(rng.nextInt(geopointData.length).toString()),
        point: point.geoPoint.toLatLng()!,
        builder: (BuildContext context) => GridItem(
          item: Icon(Icons.location_on),
          isSelected: (bool value) {
            setState(() {
              if (value) {
                markersSelected.add(point);
              } else {
                markersSelected.remove(point);
              }
            });
          }, 
          )
        )));
    });
  }

  Future<void> searchNearbyAirports(LatLng point) async {
    // draw tapped point
    setState(() => markers.add(Marker(
        point: point,
        builder: (BuildContext context) => Icon(
              Icons.location_on,
              color: Colors.red,
            ))));
    await dataIsLoaded.future;
    // geofence in radius
    final geoJsonPoint = GeoJsonPoint(
        geoPoint:
            GeoPoint(latitude: point.latitude, longitude: point.longitude));
    await geo.geofenceDistance(
        point: geoJsonPoint, points: geopointData, distance: 15);
  }

  Future<void> loadAirports() async {
    final data = await rootBundle.loadString('assets/markers.geojson');
    await geo.parse(data, disableStream: true, verbose: true);
    geopointData = geo.points;
  }

  saveData() {
    final textController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ingresa aqui tu información'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                  child: Text('Guardar'),
                  textColor: Colors.blue,
                  elevation: 5,
                  onPressed: () async  {
                    /// Add user to the table
                    await DBProvider.db.newCommitRaw(textController.text, DateTime.now().microsecond);
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                        msg: "Tu información ha sido guardada exitosamente",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 14.0
                    );
                    geopointData.clear();
                  }),
              MaterialButton(
                  child: Text('Cancelar'),
                  textColor: Colors.blue,
                  elevation: 5,
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
                center: LatLng(51.0, 0),
                zoom: 4.0,
                onTap: searchNearbyAirports),
            layers: [
              TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              MarkerLayerOptions(markers: markers)
            ],
          ),
          Positioned(
            child: markersSelected.isNotEmpty
                ? TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                    onPressed: () {
                      saveData();
                    },
                    child: Text(
                      'Toca aqui para ingresar información',
                      style: TextStyle(color: Colors.white),
                    ))
                : Container(),
            left: 15.0,
            bottom: 20.0,
          )
        ],
      )),
    );
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}

class NearbyAirportsPage extends StatefulWidget {
  @override
  _NearbyAirportsPageState createState() => _NearbyAirportsPageState();
}


class GridItem extends StatefulWidget {
  final Widget item;
  final ValueChanged<bool> isSelected;

  GridItem({required this.item, required this.isSelected, });

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Icon(
        Icons.pin_drop,color:
      isSelected ? 
        Colors.red :
        Colors.black
      )
    );
  }
}
