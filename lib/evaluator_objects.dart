abstract class Object {
  String type();
  String inspect();
}

class Integer extends Object {
  final int value;

  Integer(this.value);

  @override
  String type() => "INTEGER";

  @override
  String inspect() => value.toString();
}

class Boolean extends Object {
  final bool value;

  Boolean(this.value);

  @override
  String type() => "BOOLEAN";

  @override
  String inspect() => value ? "true" : "false";
}

class FunctionObject extends Object {
  final List<dynamic> parameters; // Lista de identificadores
  final dynamic body;             // Representa el cuerpo (AST BlockStatement)
  final dynamic env;              // Entorno donde se definió la función

  FunctionObject(this.parameters, this.body, this.env);

  @override
  String type() => "FUNCTION";

  @override
  String inspect() {
    final params = parameters.map((p) => p.toString()).join(", ");
    return "function($params) { ${body.toString()} }";
  }
}

// Constantes globales
final Boolean TRUE = Boolean(true);
final Boolean FALSE = Boolean(false);
