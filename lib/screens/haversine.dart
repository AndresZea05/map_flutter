import 'dart:math'; // Importa 'dart:math' para usar funciones matemáticas

// Función para calcular la distancia entre dos puntos utilizando la fórmula de Haversine
double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371; // Radio de la Tierra en kilómetros

  // Convertir coordenadas de grados a radianes
  final lat1Rad = _degreesToRadians(lat1);
  final lon1Rad = _degreesToRadians(lon1);
  final lat2Rad = _degreesToRadians(lat2);
  final lon2Rad = _degreesToRadians(lon2);

  // Calcular diferencia de latitud y longitud
  final dLat = lat2Rad - lat1Rad;
  final dLon = lon2Rad - lon1Rad;

  // Calcular distancia utilizando la fórmula de Haversine
  final a = pow(sin(dLat / 2), 2) +
      cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distance = earthRadius * c;

  return distance;
}

// Función para convertir grados a radianes
double _degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}