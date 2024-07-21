class UnitShortForms {
  static Map<String, String> _unitShortForms = {
    'Millimeters (mm)': 'mm',
    'Centimeters (cm)': 'cm',
    'Meters (m)': 'm',
    'Kilometers (km)': 'km',
    'Inches (in)': 'in',
    'Feet (ft)': 'ft',
  };

  static String getShortForm(String unit) {
    return _unitShortForms[unit] ?? unit;
  }
}
