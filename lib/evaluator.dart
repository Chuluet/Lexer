import 'ast.dart';
import 'environment.dart';
import 'evaluator_objects.dart';

// Entorno global
final Environment globalEnv = Environment();

dynamic evalNode(dynamic node, [Environment? env]) {
  env ??= globalEnv;

  if (node is Program) {
    return evalProgram(node, env);
  } else if (node is ExpressionStatement) {
    return evalNode(node.expression, env);
  } else if (node is LetStatement) {
    var value = evalNode(node.value, env);
    env.set(node.name.value, value);
    return value;
  } else if (node is IntegerLiteral) {
    return Integer(node.value);
  } else if (node is PrefixExpression) {
    var right = evalNode(node.right, env);
    return evalPrefixExpression(node.operator, right);
  } else if (node is InfixExpression) {
    var left = evalNode(node.left, env);
    var right = evalNode(node.right, env);
    return evalInfixExpression(node.operator, left, right);
  } else if (node is IfExpression) {
    return evalIfExpression(node, env);
  } else if (node is BlockStatement) {
    return evalBlockStatement(node, env);
  } else if (node is Identifier) {
    return env.get(node.value);
  } else if (node is WhileStatement) {
    return evalWhileStatement(node, env);
  } else if (node is ForStatement) {
    return evalForStatement(node, env);
  } else if (node is AssignStatement) {
    var value = evalNode(node.value, env);
    env.set(node.name.value, value);
    return value;
  } else if (node is FunctionLiteral) {
    return FunctionObject(node.parameters, node.body, env);
  } else if (node is CallExpression) {
    var function = evalNode(node.function, env);
    var args = node.arguments.map((arg) => evalNode(arg, env)).toList();
    return applyFunction(function, args);
  }

  return null;
}

dynamic evalProgram(Program program, Environment env) {
  dynamic result;
  for (var stmt in program.statements) {
    result = evalNode(stmt, env);
    if (result != null) {
      print(result.inspect());
    }
  }
  return result;
}

dynamic evalPrefixExpression(String operator, dynamic right) {
  if (operator == "!") {
    return evalBangOperator(right);
  } else if (operator == "-" && right is Integer) {
    return Integer(-right.value);
  }
  return null;
}

dynamic evalBangOperator(dynamic obj) {
  if (obj == TRUE) return FALSE;
  if (obj == FALSE) return TRUE;
  if (obj is Integer && obj.value == 0) return TRUE;
  return FALSE;
}

dynamic evalInfixExpression(String operator, dynamic left, dynamic right) {
  if (left is Integer && right is Integer) {
    return evalIntegerInfix(operator, left, right);
  } else if (operator == "==") {
    return left.value == right.value ? TRUE : FALSE;
  } else if (operator == "!=") {
    return left.value != right.value ? TRUE : FALSE;
  }
  return null;
}

dynamic evalIntegerInfix(String operator, Integer left, Integer right) {
  switch (operator) {
    case "+":
      return Integer(left.value + right.value);
    case "-":
      return Integer(left.value - right.value);
    case "*":
      return Integer(left.value * right.value);
    case "/":
      return Integer(left.value ~/ right.value); // Integer division
    case "<":
      return left.value < right.value ? TRUE : FALSE;
    case ">":
      return left.value > right.value ? TRUE : FALSE;
    case "<=":
      return left.value <= right.value ? TRUE : FALSE;
    case ">=":
      return left.value >= right.value ? TRUE : FALSE;
    case "==":
      return left.value == right.value ? TRUE : FALSE;
    case "!=":
      return left.value != right.value ? TRUE : FALSE;
  }
  return null;
}

dynamic evalIfExpression(IfExpression ifExpr, Environment env) {
  var condition = evalNode(ifExpr.condition, env);
  if (isTruthy(condition)) {
    return evalNode(ifExpr.consequence, env);
  } else if (ifExpr.alternative != null) {
    return evalNode(ifExpr.alternative, env);
  }
  return null;
}

dynamic evalBlockStatement(BlockStatement block, Environment env) {
  dynamic result;
  for (var stmt in block.statements) {
    result = evalNode(stmt, env);
  }
  return result;
}

bool isTruthy(dynamic obj) {
  if (obj == null) return false;
  if (obj is Boolean) return obj.value;
  if (obj is Integer) return obj.value != 0;
  return true;
}

dynamic evalWhileStatement(WhileStatement stmt, Environment env) {
  dynamic result;
  while (isTruthy(evalNode(stmt.condition, env))) {
    result = evalNode(stmt.body, env);
  }
  return result;
}

dynamic evalForStatement(ForStatement stmt, Environment env) {
  evalNode(stmt.init, env);
  dynamic result;
  while (isTruthy(evalNode(stmt.condition, env))) {
    result = evalNode(stmt.body, env);
    evalNode(stmt.post, env);
  }
  return result;
}

dynamic applyFunction(dynamic fn, List<dynamic> args) {
  if (fn is! FunctionObject) {
    throw Exception("Cannot call non-function object: ${fn.type()}");
  }

  var extendedEnv = Environment(outer: fn.env);

  for (var i = 0; i < fn.parameters.length; i++) {
    extendedEnv.set(fn.parameters[i].value, args[i]);
  }

  return evalNode(fn.body, extendedEnv);
}
