class Environment {
  final Environment? outer; // Entorno padre, puede ser null
  final Map<String, dynamic> store = {};

  Environment({this.outer});

  dynamic get(String name) {
    if (store.containsKey(name)) {
      return store[name];
    } else if (outer != null) {
      return outer!.get(name);
    }
    return null;
  }

  void set(String name, dynamic value) {
    store[name] = value;
  }
}
