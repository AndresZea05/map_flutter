import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_flutter/screens/data.dart';
import 'package:map_flutter/screens/haversine.dart';
import 'package:map_flutter/screens/ubicacion.dart';





const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? myPosition;
  List<Ubicacion> _ubicacionesVisibles = ubicaciones; // Initialize with all locations

  

  void _selectLocations() async {
  // Mostrar un diálogo para que el usuario seleccione las ubicaciones
  final selectedLocations = await showDialog<List<Ubicacion>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Seleccionar Ubicaciones'),
        content: SingleChildScrollView(
          child: ListBody(
            children: ubicaciones.map((ubicacion) {
              return ListTile(
                title: Text(ubicacion.nombre),
                onTap: () {
                  Navigator.of(context).pop(ubicacion);
                },
              );
            }).toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      );
    },
  );

  // Si el usuario seleccionó dos ubicaciones
  if (selectedLocations != null && selectedLocations.length == 2) {
    // Calcular la distancia entre las ubicaciones seleccionadas
    final distance = haversineDistance(
      selectedLocations[0].latLng.latitude,
      selectedLocations[0].latLng.longitude,
      selectedLocations[1].latLng.latitude,
      selectedLocations[1].latLng.longitude,
    );

    // Mostrar el resultado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'La distancia entre ${selectedLocations[0].nombre} y ${selectedLocations[1].nombre} es: $distance kilómetros'),
      ),
    );
  } else {
    // Si el usuario no seleccionó dos ubicaciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor seleccione dos ubicaciones.'),
      ),
    );
  }
}

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
      print(myPosition);
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  centerTitle: true,
  title: const Text('Mapa'),
  backgroundColor: Colors.blueAccent,
  actions: [
    IconButton(
      icon: const Icon(Icons.directions),
      onPressed: () {
        _selectLocations();
      },
    ),
  ],
),
      body: Column(
  children: [
    // Mapa...
    // Botón para alternar la vista de lista...
    Expanded(
      child: myPosition == null
          ? const CircularProgressIndicator()
          : FlutterMap(
              options: MapOptions(
                center: myPosition,
                minZoom: 5,
                maxZoom: 25,
                zoom: 18,
              ),
              nonRotatedChildren: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: const {
                    'accessToken': MAPBOX_ACCESS_TOKEN,
                    'id': 'mapbox/streets-v12',
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: myPosition!,
                      builder: (context) {
                        return Container(
                          child: const Icon(
                            Icons.person_pin,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
    ),
    // Container para la lista de ubicaciones
    Container(
      height: MediaQuery.of(context).size.height * 0.5, // La mitad de la altura de la pantalla
      child: _ubicacionesVisibles.isNotEmpty
          ? ListView.builder(
              itemCount: _ubicacionesVisibles.length,
              itemBuilder: (context, index) {
                final ubicacion = _ubicacionesVisibles[index];
                return ListTile(
                  title: Text(ubicacion.nombre),
                  subtitle: Text(
                      'Lat: ${ubicacion.latLng.latitude}, Lng: ${ubicacion.latLng.longitude}'),
                );
              },
            )
          : const Center(child: Text('No hay ubicaciones para mostrar')),
    ),
  ],
),
    );
  }

  Widget buildButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _ubicacionesVisibles = _ubicacionesVisibles == ubicaciones
              ? [] // Mostrar lista vacía
              : ubicaciones; // Mostrar lista completa
        });
      },
      child: Text(_ubicacionesVisibles == ubicaciones ? 'Ocultar Lista' : 'Mostrar Lista'),
    );
  }
  
}
