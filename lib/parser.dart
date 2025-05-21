import 'package:interprete/tokens.dart';


import 'ast.dart';
import 'lexer.dart';

final Map<TokenType, int> precedences = {
  TokenType.EQ: 2,
  TokenType.NOT_EQ: 2,
  TokenType.LT: 2,
  TokenType.GT: 2,
  TokenType.LE: 2,
  TokenType.GE: 2,
  TokenType.PLUS: 3,
  TokenType.MINUS: 3,
  TokenType.SLASH: 4,
  TokenType.ASTERISK: 4,
  TokenType.LPAREN: 5,
};

class Parser {
  final Lexer lexer;
  Token? currentToken;
  Token? peekToken;
  final List<String> errors = [];

  Parser(this.lexer) {
    _advance();
    _advance();
  }

  void _advance() {
    currentToken = peekToken;
    peekToken = lexer.nextToken();
  }

  Program parseProgram() {
    final program = Program();
    while (currentToken?.type != TokenType.EOF) {
      final stmt = parseStatement();
      if (stmt != null) {
        program.statements.add(stmt);
      }
      _advance();
    }
    return program;
  }

  Statement? parseStatement() {
    if (currentToken?.type == TokenType.VAR) {
      return _parseLetStatement();
    } else if (currentToken?.type == TokenType.WHILE) {
      return _parseWhileStatement();
    } else if (currentToken?.type == TokenType.FOR) {
      return _parseForStatement();
    } else if (currentToken?.type == TokenType.IDENT &&
        peekToken?.type == TokenType.ASSIGN) {
      return _parseAssignStatement();
    } else {
      return parseExpressionStatement();
    }
  }

  ExpressionStatement parseExpressionStatement() {
    final token = currentToken!;
    final expr = parseExpression(0);
    if (peekToken?.type == TokenType.SEMICOLON) {
      _advance();
    }
    return ExpressionStatement(token, expr!);
  }

  Expression? parseExpression(int precedence) {
    final prefixFn = _prefixParseFns()[currentToken?.type];
    if (prefixFn == null) {
      errors.add('No prefix parse function for ${currentToken?.type}');
      return null;
    }
    var leftExpr = prefixFn();

    while (peekToken?.type != TokenType.SEMICOLON &&
        precedence < _peekPrecedence()) {
      final infixFn = _infixParseFns()[peekToken?.type];
      if (infixFn == null) {
        return leftExpr;
      }
      _advance();
      leftExpr = infixFn(leftExpr!);
    }
    return leftExpr;
  }

  Map<TokenType?, Expression? Function()> _prefixParseFns() {
    return {
      TokenType.IDENT: _parseIdentifier,
      TokenType.INT: _parseIntegerLiteral,
      TokenType.BANG: _parsePrefixExpression,
      TokenType.MINUS: _parsePrefixExpression,
      TokenType.IF: _parseIfExpression,
      TokenType.FUNCTION: _parseFunctionLiteral,
    };
  }

  Map<TokenType?, Expression? Function(Expression)> _infixParseFns() {
    return {
      TokenType.PLUS: _parseInfixExpression,
      TokenType.MINUS: _parseInfixExpression,
      TokenType.SLASH: _parseInfixExpression,
      TokenType.ASTERISK: _parseInfixExpression,
      TokenType.EQ: _parseInfixExpression,
      TokenType.NOT_EQ: _parseInfixExpression,
      TokenType.LT: _parseInfixExpression,
      TokenType.GT: _parseInfixExpression,
      TokenType.LE: _parseInfixExpression,
      TokenType.GE: _parseInfixExpression,
      TokenType.LPAREN: _parseCallExpression,
    };
  }

  Identifier _parseIdentifier() {
    return Identifier(currentToken!, currentToken!.literal);
  }

  IntegerLiteral? _parseIntegerLiteral() {
    try {
      final value = int.parse(currentToken!.literal);
      return IntegerLiteral(currentToken!, value);
    } catch (e) {
      errors.add('Could not parse ${currentToken!.literal} as integer.');
      return null;
    }
  }

  PrefixExpression _parsePrefixExpression() {
    final token = currentToken!;
    final operator = token.literal;
    _advance();
    final right = parseExpression(5);
    return PrefixExpression(token, operator, right!);
  }

  InfixExpression _parseInfixExpression(Expression left) {
    final token = currentToken!;
    final operator = token.literal;
    final precedence = _currentPrecedence();
    _advance();
    final right = parseExpression(precedence);
    return InfixExpression(token, left, operator, right!);
  }

  int _peekPrecedence() {
    return precedences[peekToken?.type] ?? 0;
  }

  int _currentPrecedence() {
    return precedences[currentToken?.type] ?? 0;
  }

  bool _expectPeek(TokenType ttype) {
    if (peekToken?.type == ttype) {
      _advance();
      return true;
    } else {
      errors.add(
          'Expected next token to be $ttype, got ${peekToken?.type} instead.');
      return false;
    }
  }

  IfExpression? _parseIfExpression() {
    final token = currentToken!;
    if (!_expectPeek(TokenType.LPAREN)) return null;
    _advance();
    final condition = parseExpression(0);
    if (!_expectPeek(TokenType.RPAREN)) return null;
    if (!_expectPeek(TokenType.LBRACE)) return null;
    final consequence = _parseBlockStatement();

    Expression? alternative;
    if (peekToken?.type == TokenType.ELSE) {
      _advance();
      if (peekToken?.type == TokenType.IF) {
        _advance();
        alternative = _parseIfExpression();
      } else if (_expectPeek(TokenType.LBRACE)) {
        alternative = _parseBlockStatement();
      }
    }

    return IfExpression(token, condition!, consequence, alternative);
  }

  BlockStatement _parseBlockStatement() {
    final token = currentToken!;
    final block = BlockStatement(token);
    _advance();

    while (currentToken?.type != TokenType.RBRACE &&
        currentToken?.type != TokenType.EOF) {
      final stmt = parseStatement();
      if (stmt != null) {
        block.statements.add(stmt);
      }
      _advance();
    }
    return block;
  }

  LetStatement? _parseLetStatement() {
    final token = currentToken!;
    if (!_expectPeek(TokenType.IDENT)) return null;
    final name = Identifier(currentToken!, currentToken!.literal);
    if (!_expectPeek(TokenType.ASSIGN)) return null;
    _advance();
    final value = parseExpression(0);
    if (peekToken?.type == TokenType.SEMICOLON) {
      _advance();
    }
    return LetStatement(token, name, value!);
  }

  AssignStatement? _parseAssignStatement() {
    final name = Identifier(currentToken!, currentToken!.literal);
    if (!_expectPeek(TokenType.ASSIGN)) return null;
    final token = currentToken!;
    _advance();
    final value = parseExpression(0);
    if (peekToken?.type == TokenType.SEMICOLON) {
      _advance();
    }
    return AssignStatement(token, name, value!);
  }

  WhileStatement? _parseWhileStatement() {
    final token = currentToken!;
    if (!_expectPeek(TokenType.LPAREN)) return null;
    _advance();
    final condition = parseExpression(0);
    if (!_expectPeek(TokenType.RPAREN)) return null;
    if (!_expectPeek(TokenType.LBRACE)) return null;
    final body = _parseBlockStatement();
    return WhileStatement(token, condition!, body);
  }

  ForStatement? _parseForStatement() {
    final token = currentToken!;
    if (!_expectPeek(TokenType.LPAREN)) return null;

    _advance();

    Statement? init;
    if (currentToken?.type == TokenType.VAR) {
      init = _parseLetStatement();
    } else if (currentToken?.type == TokenType.IDENT &&
        peekToken?.type == TokenType.ASSIGN) {
      init = _parseAssignStatement();
    } else {
      errors.add("Expected init statement in 'for', got ${currentToken?.type}");
      return null;
    }

    if (!_expectPeek(TokenType.SEMICOLON)) return null;
    _advance();

    final condition = parseExpression(0);

    if (!_expectPeek(TokenType.SEMICOLON)) return null;
    _advance();

    Statement? post;
    if (currentToken?.type == TokenType.VAR) {
      post = _parseLetStatement();
    } else if (currentToken?.type == TokenType.IDENT &&
        peekToken?.type == TokenType.ASSIGN) {
      post = _parseAssignStatement();
    } else {
      errors.add("Expected post statement in 'for', got ${currentToken?.type}");
      return null;
    }

    if (currentToken?.type != TokenType.RPAREN) {
      if (!_expectPeek(TokenType.RPAREN)) return null;
    }

    if (!_expectPeek(TokenType.LBRACE)) return null;
    final body = _parseBlockStatement();

    return ForStatement(token, init, condition, post, body);
  }

  FunctionLiteral? _parseFunctionLiteral() {
    final token = currentToken!;

    if (!_expectPeek(TokenType.LPAREN)) {
      return null;
    }

    final parameters = _parseFunctionParameters();

    if (!_expectPeek(TokenType.LBRACE)) {
      return null;
    }

    final body = _parseBlockStatement();

    return FunctionLiteral(token, parameters, body);
  }

  List<Identifier> _parseFunctionParameters() {
    final params = <Identifier>[];

    if (peekToken?.type == TokenType.RPAREN) {
      _advance();
      return params;
    }

    _advance();

    params.add(Identifier(currentToken!, currentToken!.literal));

    while (peekToken?.type == TokenType.COMMA) {
      _advance();
      _advance();
      params.add(Identifier(currentToken!, currentToken!.literal));
    }

    if (!_expectPeek(TokenType.RPAREN)) {
      return [];
    }

    return params;
  }

  CallExpression _parseCallExpression(Expression function) {
    final token = currentToken!;
    final arguments = _parseExpressionList(TokenType.RPAREN);
    return CallExpression(token, function, arguments);
  }

  List<Expression> _parseExpressionList(TokenType endTokenType) {
    final args = <Expression>[];

    if (peekToken?.type == endTokenType) {
      _advance();
      return args;
    }

    _advance();
    final firstExpr = parseExpression(0);
    if (firstExpr != null) {
      args.add(firstExpr);
    }

    while (peekToken?.type == TokenType.COMMA) {
      _advance();
      _advance();
      final expr = parseExpression(0);
      if (expr != null) {
        args.add(expr);
      }

    }


    if (!_expectPeek(endTokenType)) {
      return [];
    }

    return args;
  }
}
