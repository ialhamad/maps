import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class PolylineUtil {
  static List<LatLng> decode(String str, [CodeOptions options]) {
    if (options == null) {
      options = CodeOptions();
    }
    final List<LatLng> coordinates = <LatLng>[];
    int index = 0,
        lat = 0,
        lng = 0,
        shift = 0,
        result = 0,
        byte,
        latitudeChange,
        longitudeChange;

    // Coordinates have variable length when encoded, so just keep
    // track of whether we've hit the end of the string. In each
    // loop iteration, a single coordinate is decoded.
    while (index < str.length) {
      // Reset shift, result, and byte
      byte = null;
      shift = 0;
      result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= ((byte & 0x1f) << shift);
        shift += 5;
      } while (byte >= 0x20);

      latitudeChange = calcDiff(result);

      shift = 0;
      result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= ((byte & 0x1f) << shift);
        shift += 5;
      } while (byte >= 0x20);

      longitudeChange = calcDiff(result);

      lat += latitudeChange;
      lng += longitudeChange;

      coordinates.add(LatLng(lat / options.factor, lng / options.factor));
    }

    return coordinates;
  }

  static int calcDiff(int result) {
    bool isZero = (result & 1) == 0;
    int val = (result >> 1);
    if (isZero) {
      return val;
    } else {
      return -val - 1;
    }
  }
}

class CodeOptions {
  CodeOptions([this.precision = 5, this.factor]) {
    if (factor == null) {
      factor = pow(10, precision);
    }
  }
  num precision;
  num factor;
}
