import 'dart:io';

import 'tokens.dart';

import 'lexer.dart';

void startRepl() {
  print("Welcome to toro ayuda Monkey REPL");
  print("Type 'exit' to exit");

  while (true) {
    try {
      stdout.write(">> ");
      String? source = stdin.readLineSync();

      if (source == null) continue;

      if (source.trim().toLowerCase() == "exit") {
        break;
      }


      Lexer lexer = Lexer(source);
      Token token;

      do {
        token = lexer.nextToken();
        print(token);
      } while (token.type != TokenType.EOF);
    } catch (e) {
      print("Runtime Error: $e");
    }
  }

}
