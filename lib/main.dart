import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:offline_maps_app/src/db_provider/db_provider.dart';
import 'package:offline_maps_app/src/map.dart';
 
void main() async {
  runApp(MyApp());

} 
 
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  bool locationisEnable = false;

  @override
  void initState() { 
    super.initState();
    _handlePermission();
  } 


  Future<bool> _handlePermission() async {
    
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      
      setState(() {
        locationisEnable = false;
      });
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        locationisEnable = false;
      });
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        setState(() {
          locationisEnable = false;
        });
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      setState(() {
        locationisEnable = false;
      });
      return false;
    }
    if(permission == LocationPermission.always){
      setState(() {
        locationisEnable = true;
      });
      return true;
    }else{
      setState(() {
        locationisEnable = true;
      });
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    DBProvider.db.database;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GeoPoints Map',
      home: locationisEnable == true 
        ? NearbyAirportsPage() 
        : Scaffold(
          body: Center(
            child: Text('Debes Aceptar los permisos de localizacion')
          ),
        )
    );
  }
}


class GridItem extends StatefulWidget {
  final Key key;
  final Widget item;
  final ValueChanged<bool> isSelected;

  GridItem({required this.item, required this.isSelected, required this.key});

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
        child: Icon(Icons.pin_drop,
            color: isSelected ? Colors.red : Colors.black));
  }
}
