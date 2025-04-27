import 'tokens.dart';

class Lexer {
  final String source;
  String character = '';
  int readPosition = 0;
  int position = 0;

  Lexer(this.source) {
    readChar();
  }

  Token nextToken() {
    skipWhitespace();

    Token token;

    if (character == '=') {
      if (_peekCharacter() == '=') {
        final ch = character;
        readChar();
        token = Token(TokenType.EQ, '$ch$character');
      } else {
        token = Token(TokenType.ASSIGN, character);
      }
    } else if (character == '!') {
      if (_peekCharacter() == '=') {
        final ch = character;
        readChar();
        token = Token(TokenType.NOT_EQ, '$ch$character');
      } else {
        token = Token(TokenType.BANG, character);
      }
    } else if (character == '<') {
      if (_peekCharacter() == '=') {
        final ch = character;
        readChar();
        token = Token(TokenType.LE, '$ch$character');
      } else {
        token = Token(TokenType.LT, character);
        token = Token(TokenType.LT, character);
      }
    } else if (character == '>') {
      if (_peekCharacter() == '=') {
        final ch = character;
        readChar();
        token = Token(TokenType.GE, '$ch$character');
      } else {
        token = Token(TokenType.GT, character);
      }
    } else if (character == '+') {
      token = Token(TokenType.PLUS, character);
    } else if (character == '-') {
      token = Token(TokenType.MINUS, character);
    } else if (character == '*') {
      token = Token(TokenType.ASTERISK, character);
    } else if (character == '/') {
      token = Token(TokenType.SLASH, character);
    } else if (character == ',') {
      token = Token(TokenType.COMMA, character);
    } else if (character == ';') {
      token = Token(TokenType.SEMICOLON, character);
    } else if (character == ':') {
      token = Token(TokenType.COLON, character);
    } else if (character == '(') {
      token = Token(TokenType.LPAREN, character);
    } else if (character == ')') {
      token = Token(TokenType.RPAREN, character);
    } else if (character == '{') {
      token = Token(TokenType.LBRACE, character);
    } else if (character == '}') {
      token = Token(TokenType.RBRACE, character);
    } else if (_isNumber(character)) {
      final number = _readNumber();
      return Token(TokenType.INT, number);
    } else if (_isLetter(character)) {
      final literal = _readLiteral();
      final tokenType = lookupTokenType(literal);
      return Token(tokenType, literal);
    } else if (character == '') {
      return Token(TokenType.EOF, '');
    } else {
      token = Token(TokenType.ILLEGAL, character);
    }

    readChar();
    return token;
  }

  void skipWhitespace() {
    while (RegExp(r'^\s$').hasMatch(character)) {
      readChar();
    }
  }

  bool _isNumber(String char) {
    return RegExp(r'^\d$').hasMatch(char);
  }

  bool _isLetter(String char) {
    return RegExp(r'^[a-zA-Z_]$').hasMatch(char);
    // Agregué "_" porque en Dart también se permiten nombres con "_"
  }

  String _readNumber() {
    final start = position;
    bool hasDot = false;
    while (_isNumber(character) || (character == '.' && !hasDot)) {
      if (character == '.') {
        hasDot = true;
      }
      readChar();
    }
    return source.substring(start, position);
  }

  String _readLiteral() {
    final start = position;
    while (_isLetter(character) || _isNumber(character)) {
      readChar();
    }
    return source.substring(start, position);
  }

  void readChar() {
    if (readPosition >= source.length) {
      character = '';
    } else {
      character = source[readPosition];
    }
    position = readPosition;
    readPosition++;
  }

  String _peekCharacter() {
    if (readPosition >= source.length) {
      return '';
    }
    return source[readPosition];
  }
}
