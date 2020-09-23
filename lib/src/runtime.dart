class RuntimeConfigration {
  factory RuntimeConfigration() =>_getInstance();
  
  RuntimeConfigration._internal() {}

  static RuntimeConfigration _instance;
  static RuntimeConfigration _getInstance() {
    if (_instance == null) {
      _instance = new RuntimeConfigration._internal();
    }
    return _instance;
  }
}