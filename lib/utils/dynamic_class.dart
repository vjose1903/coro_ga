class DynamicClass {
  dynamic get(String propertyName) {
    var classMap = toMap();
    if (classMap.containsKey(propertyName)) return classMap[propertyName];

    throw ArgumentError('propery not found');
  }

  Map toMap() {
    return {};
  }
}
