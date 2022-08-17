// ignore_for_file: non_constant_identifier_names

typedef CalcNumber = double;

class CalcOperator
{
  final CalcOpType type;
  final CalcOp operation;
  final int priority;
  final String name;
  final bool endExpression;
  final CalcFunction function;

  const CalcOperator(this.operation, this.type,
    {this.name = '', this.priority = 100, this.endExpression = false, this.function = _noopCalc});

  static CalcOperator get noop => const CalcOperator(CalcOp.noop, CalcOpType.global);

  static CalcNumber _noopCalc(CalcNumber x, CalcNumber y) => x;
}

typedef CalcFunction = CalcNumber Function(CalcNumber x, CalcNumber y);

enum CalcOpType { digit, twoOp, singleOp, singleFunction, edit, global }

enum CalcOp
{
  $0(0),
  $1(1),
  $2(2),
  $3(3),
  $4(4),
  $5(5),
  $6(6),
  $7(7),
  $8(8),
  $9(9),
  dot(10),
  clearAll(100),
  clearLast(101),
  delete(102),
  memoryRead(200),
  memoryAdd(201),
  memorySubtract(202),
  equal(1000),
  add(1001),
  subtract(1002),
  multiply(1003),
  divide(1004),

  noop(10000);

  final int value;

  const CalcOp(this.value);

  int get toInteger => value;

  static final $0_value = CalcOp.$0.value;
  static final $9_value = CalcOp.$9.value;

  static bool isDigit(CalcOp op)
  {
    final opVal = op.toInteger;
    return opVal >= CalcOp.$0_value && opVal <= CalcOp.$9_value;
  }
}