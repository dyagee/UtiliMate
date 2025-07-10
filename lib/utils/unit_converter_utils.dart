// ignore_for_file: avoid_print

enum UnitCategory { length, weight, temperature, volume, area, time, speed }

// Base units for conversion (all conversions go to/from this base)
// For Temperature, Celsius is the base for linear conversions, but Kelvin is used for absolute conversions.
// Here, we'll use a common reference point for each category.
// Length: Meter (m)
// Weight: Kilogram (kg)
// Temperature: Celsius (°C) for relative, Kelvin (K) for absolute conversions
// Volume: Liter (L)
// Area: Square Meter (m²)
// Time: Second (s)
// Speed: Meters per Second (m/s)

class UnitConverter {
  // Conversion factors to and from a base unit for each category.
  // Format: {Unit: factor_to_base_unit}
  // Example: 1 km = 1000 m, so factor for km is 1000.
  // 1 cm = 0.01 m, so factor for cm is 0.01.
  static final Map<UnitCategory, Map<String, double>> _conversionFactors = {
    UnitCategory.length: {
      'm': 1.0,
      'km': 1000.0,
      'cm': 0.01,
      'mm': 0.001,
      'µm': 0.000001,
      'nm': 0.000000001,
      'mi': 1609.34,
      'yd': 0.9144,
      'ft': 0.3048,
      'in': 0.0254,
      'nmi': 1852.0,
    },
    UnitCategory.weight: {
      'kg': 1.0,
      'g': 0.001,
      'mg': 0.000001,
      'µg': 0.000000001,
      't': 1000.0, // Metric Ton
      'lb': 0.453592,
      'oz': 0.0283495,
      'st': 6.35029, // Stone
    },
    UnitCategory.volume: {
      'L': 1.0,
      'ml': 0.001,
      'cl': 0.01,
      'm³': 1000.0,
      'cm³': 0.001,
      'us_gal': 3.78541, // US Gallon
      'us_qt': 0.946353, // US Quart
      'us_pt': 0.473176, // US Pint
      'us_fl_oz': 0.0295735, // US Fluid Ounce
    },
    UnitCategory.area: {
      'm²': 1.0,
      'km²': 1000000.0,
      'cm²': 0.0001,
      'mm²': 0.000001,
      'ac': 4046.86, // Acre
      'ha': 10000.0, // Hectare
      'mi²': 2589988.11, // Square Mile
      'yd²': 0.836127, // Square Yard
      'ft²': 0.092903, // Square Foot
      'in²': 0.00064516, // Square Inch
    },
    UnitCategory.time: {
      's': 1.0,
      'ms': 0.001,
      'min': 60.0,
      'hr': 3600.0,
      'day': 86400.0,
      'wk': 604800.0,
      'month': 2629746.0, // Average Gregorian month
      'yr': 31556952.0, // Average Gregorian year
    },
    UnitCategory.speed: {
      'm/s': 1.0,
      'km/h': 1000.0 / 3600.0, // 1 km/h = 0.277778 m/s
      'mph': 1609.34 / 3600.0, // 1 mph = 0.44704 m/s
      'kn': 1852.0 / 3600.0, // 1 knot = 0.514444 m/s
      'ft/s': 0.3048, // 1 ft/s = 0.3048 m/s
    },
  };

  // Temperature conversions are special (not linear factor based)
  static double _convertTemperature(
    double value,
    String fromUnit,
    String toUnit,
  ) {
    // Convert to Celsius first
    double celsiusValue;
    if (fromUnit == 'C') {
      celsiusValue = value;
    } else if (fromUnit == 'F') {
      celsiusValue = (value - 32) * 5 / 9;
    } else if (fromUnit == 'K') {
      celsiusValue = value - 273.15;
    } else {
      throw ArgumentError('Unsupported temperature unit: $fromUnit');
    }

    // Convert from Celsius to target unit
    if (toUnit == 'C') {
      return celsiusValue;
    } else if (toUnit == 'F') {
      return (celsiusValue * 9 / 5) + 32;
    } else if (toUnit == 'K') {
      return celsiusValue + 273.15;
    } else {
      throw ArgumentError('Unsupported temperature unit: $toUnit');
    }
  }

  /// Performs unit conversion.
  /// Returns the converted value as a double, or null if conversion is not possible.
  static double? convert(
    double value,
    String fromUnit,
    String toUnit,
    UnitCategory category,
  ) {
    if (fromUnit == toUnit) {
      return value;
    }

    if (category == UnitCategory.temperature) {
      try {
        return _convertTemperature(value, fromUnit, toUnit);
      } catch (e) {
        print('Temperature conversion error: $e');
        return null;
      }
    }

    final factors = _conversionFactors[category];
    if (factors == null) {
      print('Unsupported unit category: $category');
      return null;
    }

    final fromFactor = factors[fromUnit];
    final toFactor = factors[toUnit];

    if (fromFactor == null || toFactor == null) {
      print('Unsupported unit for category $category: $fromUnit or $toUnit');
      return null;
    }

    // Convert from 'fromUnit' to base unit, then from base unit to 'toUnit'
    return (value * fromFactor) / toFactor;
  }

  /// Returns a list of unit names for a given category.
  static List<String> getUnitsForCategory(UnitCategory category) {
    if (category == UnitCategory.temperature) {
      return ['C', 'F', 'K'];
    }
    return _conversionFactors[category]?.keys.toList() ?? [];
  }

  /// Provides a user-friendly name for a unit category.
  static String getCategoryName(UnitCategory category) {
    switch (category) {
      case UnitCategory.length:
        return 'Length';
      case UnitCategory.weight:
        return 'Weight/Mass';
      case UnitCategory.temperature:
        return 'Temperature';
      case UnitCategory.volume:
        return 'Volume';
      case UnitCategory.area:
        return 'Area';
      case UnitCategory.time:
        return 'Time';
      case UnitCategory.speed:
        return 'Speed';
    }
  }
}
