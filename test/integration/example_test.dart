// test/calculator_test.dart

import 'package:flutter_test/flutter_test.dart';

// テスト対象のCalculatorクラス
class Calculator {
  int add(int a, int b) {
    return a + b;
  }

  int subtract(int a, int b) {
    return a - b;
  }
}

void main() {
  group('Calculator', () {
    test('adds two numbers', () {
      final calculator = Calculator();
      expect(calculator.add(2, 3), 5);
    });

    test('subtracts two numbers', () {
      final calculator = Calculator();
      expect(calculator.subtract(5, 2), 3);
    });
  });
}
