import 'package:cfverdict/model/verdict.dart';

class DecodedVoice {
  final Verdict verdict;
  DecodedVoice(this.verdict);

  String getCommand(String text) {
    String good = validate(text);
    if (good != "OK") return good;
    String val = "";

    for (int i = 0; i < text.length; ++i) {
      if (text[i] == '{') {
        i++;
        String cur = "";
        while (i < text.length && text[i] != '}') {
          if (text[i] != ' ') cur += text[i];
          i++;
        }
        if (cur == "index")
          val += verdict.index;
        else if (cur == "name")
          val += verdict.name;
        else if (cur == "verdict")
          val += verdict.verdict;
        else
          val += evaluate(cur);
      } else
        val += text[i];
    }
    return val;
  }

  String validate(String text) {
    int balance = 0;
    for (int i = 0; i < text.length; ++i) {
      if (text[i] == '{') {
        if (balance >= 1) return "Nested Parantheses Not Supported\n";
        balance++;
      } else if (text[i] == '}') {
        balance--;
      }
      if (balance < 0) return "Parantheses Misplaced\n";
    }

    if (balance != 0) return "Parantheses Misplaced\n";
    return "OK";
  }

  int precedence(op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  // Function to perform arithmetic operations.
  int applyOp(int a, int b, var op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        {
          if (b == 0) return 0;
          return a ~/ b;
        }
    }
    return 0;
  }

  bool isdigit(a) {
    int x = int.tryParse(a);
    if (x != null) return true;
    return false;
  }

  bool isOperator(String a) {
    return (a == "*" || a == "/" || a == "-" || a == "+");
  }

  String evaluate(String tokens) {
    int i;

    // stack to store integer values.
    List<int> values = [];

    // stack to store operators.
    List<String> ops = [];

    for (i = 0; i < tokens.length; i++) {
      if (tokens[i] == ' ')
        continue;
      else if (tokens[i] == '(') {
        ops.add(tokens[i]);
      }

      // Current token is a number, push
      // it to stack for numbers.
      else if (isdigit(tokens[i])) {
        int val = 0;

        // There may be more than one
        // digits in number.
        while (i < tokens.length && isdigit(tokens[i])) {
          val = (val * 10) + (int.parse(tokens[i]));
          i++;
        }

        values.add(val);
        i--;
      }

      // Closing brace encountered, solve
      // entire brace.
      else if (tokens[i] == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          int val2 = values.last;
          values.removeLast();

          int val1 = values.last;
          values.removeLast();

          var op = ops.last;
          ops.removeLast();

          values.add(applyOp(val1, val2, op));
        }

        // pop opening brace.
        if (ops.isNotEmpty) ops.removeLast();
      }

      // Current token is an operator.
      else if (isOperator(tokens[i])) {
        // While top of 'ops' has same or greater
        // precedence to current token, which
        // is an operator. Apply operator on top
        // of 'ops' to top two elements in values stack.
        while (
            ops.isNotEmpty && precedence(ops.last) >= precedence(tokens[i])) {
          int val2 = values.last;
          values.removeLast();

          int val1 = values.last;
          values.removeLast();

          var op = ops.last;
          ops.removeLast();

          values.add(applyOp(val1, val2, op));
        }

        // Push current token to 'ops'.
        ops.add(tokens[i]);
      } else {
        String s = "";
        while (i < tokens.length &&
            !isdigit(tokens[i]) &&
            !isOperator(tokens[i]) &&
            tokens[i] != ' ') {
          s += tokens[i];
          i++;
        }
        if (s == "passedTestCount")
          values.add(verdict.passedTestCount);
        else if (s == "timeConsumedMillis")
          values.add(verdict.timeConsumedMillis);
        else if (s == "memoryConsumedBytes")
          values.add(verdict.memoryConsumedBytes);
        else
          values.add(0);
        i--;
      }
    }
    // Entire expression has been parsed at this
    // point, apply remaining ops to remaining
    // values.
    while (ops.isNotEmpty) {
      int val2 = values.last;
      values.removeLast();

      int val1 = values.last;
      values.removeLast();

      var op = ops.last;
      ops.removeLast();

      values.add(applyOp(val1, val2, op));
    }

    // Top of 'values' contains result, return it.
    return values.last.toString();
  }
}
