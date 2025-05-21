import 'package:interprete/lexer.dart';
import 'package:interprete/parser.dart';


void main() {
  final input = 'if (x == 1) { y = 2; } else { if (x == 2) { y = 3; } }';

  final lexer = Lexer(input);
  final parser = Parser(lexer);
  final program = parser.parseProgram();

  if (parser.errors.isNotEmpty) {
    print("Errores de parsing:");
    for (final error in parser.errors) {
      print(error);
    }
    return;
  }

  print("AST generado:");
  print(program.toString());
}