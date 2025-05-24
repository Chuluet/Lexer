import 'dart:io';

import 'package:interprete/parser.dart';
import 'package:interprete/lexer.dart';
import 'package:interprete/evaluator.dart';

void main() {
  try {
    final source = File('Lexer/ejemplo.chuleta').readAsStringSync();

    final lexer = Lexer(source);
    final parser = Parser(lexer);
    final program = parser.parseProgram();

    if (parser.errors.isNotEmpty) {
      print('Errores de parseo:');
      for (final err in parser.errors) {
        print('  ✖ $err');
      }
    } else {
      evalNode(program); // Evalúa el programa y muestra resultados si corresponde
    }
  } on FileSystemException catch (e) {
    print('Error al leer el archivo: ${e.message}');
  } catch (e) {
    print('Error durante la ejecución: $e');
  }
}
