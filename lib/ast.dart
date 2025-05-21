import 'tokens.dart';
abstract class Node {
  String tokenLiteral();
}

abstract class Statement extends Node {}

abstract class Expression extends Node {}

class Program extends Node {
  List<Statement> statements = [];

  @override
  String tokenLiteral() {
    if (statements.isNotEmpty) {
      return statements[0].tokenLiteral();
    }
    return "";
  }

  @override
  String toString() {
    return statements.map((stmt) => stmt.toString()).join("\n");
  }
}

// ========== STATEMENTS ==========

class LetStatement extends Statement {
  final Token token; // token 'var', 'final' o 'const'
  final Identifier name;
  final Expression value;

  LetStatement(this.token, this.name, this.value);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() => '${tokenLiteral()} ${name.toString()} = ${value.toString()};';
}

class ExpressionStatement extends Statement {
  final Token token;
  final Expression expression;

  ExpressionStatement(this.token, this.expression);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() => expression.toString();
}

// ========== EXPRESSIONS ==========

class Identifier extends Expression {
  final Token token; // token IDENT
  final String value;

  Identifier(this.token, this.value);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() => value;
}

class IntegerLiteral extends Expression {
  final Token token; // token INT
  final int value;

  IntegerLiteral(this.token, this.value);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() => value.toString();
}

class PrefixExpression extends Expression {
  final Token token; // token BANG o MINUS
  final String operator;
  final Expression right;

  PrefixExpression(this.token, this.operator, this.right);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() => '($operator${right.toString()})';
}

class InfixExpression extends Expression {
  final Token token; // operador
  final Expression left;
  final String operator;
  final Expression right;

  InfixExpression(this.token, this.left, this.operator, this.right);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() => '(${left.toString()} $operator ${right.toString()})';
}

class IfExpression extends Expression {
  final Token token; // token IF
  final Expression condition;
  final BlockStatement consequence;
  final Expression? alternative;


  IfExpression(this.token, this.condition, this.consequence, [this.alternative]);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() {
    var out = 'if ${condition.toString()} ${consequence.toString()}';
    if (alternative != null) {
      out += ' else ${alternative.toString()}';
    }
    return out;
  }
}

class BlockStatement extends Expression {
  final Token token; // token LBRACE
  final List<Statement> statements = [];

  BlockStatement(this.token);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() => '{ ${statements.map((s) => s.toString()).join(' ')} }';
}

class WhileStatement extends Statement {
  final Token token; // token WHILE
  final Expression condition;
  final BlockStatement body;

  WhileStatement(this.token, this.condition, this.body);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() => 'while (${condition.toString()}) ${body.toString()}';
}

class ForStatement extends Statement {
  final Token token; // token FOR
  final Statement? init;
  final Expression? condition;
  final Statement? post;
  final BlockStatement body;

  ForStatement(this.token, this.init, this.condition, this.post, this.body);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() =>
      'for (${init?.toString() ?? ''}; ${condition?.toString() ?? ''}; ${post?.toString() ?? ''}) ${body.toString()}';
}

class AssignStatement extends Statement {
  final Token token; // token ASSIGN '='
  final Identifier name;
  final Expression value;

  AssignStatement(this.token, this.name, this.value);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() => '${name.toString()} = ${value.toString()};';
}

class FunctionLiteral extends Expression {
  final Token token; // token FUNCTION, VAR, etc.
  final List<Identifier> parameters;
  final BlockStatement body;

  FunctionLiteral(this.token, this.parameters, this.body);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() {
    final params = parameters.map((p) => p.toString()).join(', ');
    return '${tokenLiteral()}($params) ${body.toString()}';
  }
}

class CallExpression extends Expression {
  final Token token; // token LPAREN '('
  final Expression function;
  final List<Expression> arguments;

  CallExpression(this.token, this.function, this.arguments);

  @override
  String tokenLiteral() => token.literal;

  @override
  String toString() {
    final args = arguments.map((a) => a.toString()).join(', ');
    return '${function.toString()}($args)';

  }
}
