enum TokenType {
  ASSIGN,       // =
  BANG,         // !
  COMMA,        // ,
  EOF,          // fin de archivo
  EQ,           // ==
  IF,           // if
  ELSE,         // else
  NOT_EQ,       // !=
  FOR,          // for
  WHILE,        // while
  IDENT,        // nombre de variable o función
  ILLEGAL,      // algo que no entendemos
  INT,          // número entero
  DOUBLE,       // número decimal                                               ESTO NO JALA
  BOOL,         // tipo bool
  STRING,       // tipo String
  VAR,          // var
  FINAL,        // final
  CONST,        // const
  TRUE,         // true
  FALSE,        // false
  RETURN,       // return
  BREAK,        // break
  CONTINUE,     // continue
  LBRACE,       // {
  RBRACE,       // }
  LPAREN,       // (
  RPAREN,       // )
  PLUS,         // +
  MINUS,        // -
  ASTERISK,     // *
  SLASH,        // /
  GT,            // >
  LT,
  LE,           // <=
  GE,           // >=
  SEMICOLON,    // ;
  COLON,
  FUNCTION,         // :
}

class Token {
  final TokenType type;
  final String literal;

  Token(this.type, this.literal);

  @override
  String toString() {
    return 'Token($type, $literal)';
  }
}

TokenType lookupTokenType(String literal) {
  const keywords = {
    'var': TokenType.VAR,
    'final': TokenType.FINAL,
    'const': TokenType.CONST,
    'int': TokenType.INT,
    'double': TokenType.DOUBLE,
    'bool': TokenType.BOOL,
    'String': TokenType.STRING,
    'true': TokenType.TRUE,
    'false': TokenType.FALSE,
    'if': TokenType.IF,
    'else': TokenType.ELSE,
    'for': TokenType.FOR,
    'while': TokenType.WHILE,
    'return': TokenType.RETURN,
    'yamete': TokenType.BREAK,
    'continue': TokenType.CONTINUE,
    'function': TokenType.FUNCTION,
  };



  return keywords[literal] ?? TokenType.IDENT;
}
