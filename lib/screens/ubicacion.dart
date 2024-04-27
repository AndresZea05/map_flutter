import 'package:latlong2/latlong.dart'; // Importar latlng2 para LatLng

class Ubicacion {
  final String nombre;
  final LatLng latLng;

  Ubicacion({required this.nombre, required this.latLng});
}