import 'package:data_binder/data_binder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'calc_operator.dart';
import 'dart:math' as math;

Widget buildDecimalKeyboard(BuildContext context)
{
  final eventValue = ValueState.of(context, 'keyEvent');
  return Builder
  (
    builder: (context)
    {
      const keys =
      [
        CalcOperator(CalcOp.clearAll, CalcOpType.edit, name: 'C'),
        CalcOperator(CalcOp.memoryAdd, CalcOpType.edit, name: 'M+'),
        CalcOperator(CalcOp.memorySubtract, CalcOpType.edit, name: 'M-'),
        CalcOperator(CalcOp.memoryRead, CalcOpType.edit, name: 'MRC'),
        /////////////
        CalcOperator(CalcOp.squreRoot, CalcOpType.singleFunction, name: '√', function: _sqr),
        CalcOperator(CalcOp.powerTwo, CalcOpType.singleFunction, name: 'x²', function: _powerTwo),
        CalcOperator(CalcOp.leftBrace, CalcOpType.global, name: '(', priority: 5),
        CalcOperator(CalcOp.rightBrace, CalcOpType.global, name: ')', priority: 5),
        /////////////
        CalcOperator(CalcOp.$7, CalcOpType.digit, name: '7'),
        CalcOperator(CalcOp.$8, CalcOpType.digit, name: '8'),
        CalcOperator(CalcOp.$9, CalcOpType.digit, name: '9'),
        CalcOperator(CalcOp.divide, CalcOpType.twoOp, name: '/', priority: 200, function: _div),
        /////////////
        CalcOperator(CalcOp.$4, CalcOpType.digit, name: '4'),
        CalcOperator(CalcOp.$5, CalcOpType.digit, name: '5'),
        CalcOperator(CalcOp.$6, CalcOpType.digit, name: '6'),
        CalcOperator(CalcOp.multiply, CalcOpType.twoOp, name: '*', priority: 200, function: _mul),
        /////////////
        CalcOperator(CalcOp.$1, CalcOpType.digit, name: '1'),
        CalcOperator(CalcOp.$2, CalcOpType.digit, name: '2'),
        CalcOperator(CalcOp.$3, CalcOpType.digit, name: '3'),
        CalcOperator(CalcOp.subtract, CalcOpType.twoOp, name: '-', function: _sub),
        /////////////
        CalcOperator(CalcOp.$0, CalcOpType.digit, name: '0'),
        CalcOperator(CalcOp.dot, CalcOpType.digit, name: '.'),
        CalcOperator(CalcOp.equal, CalcOpType.singleOp, name: '=', priority: 0, endExpression: true),
        CalcOperator(CalcOp.add, CalcOpType.twoOp, name: '+', function: _add),
        /////////////
      ];

      final media = MediaQuery.of(context);
      final sz = Size(media.size.width, media.size.width);

      final children = <Widget>[];
      for (final key in keys)
      {
        children.add
        (
          ElevatedButton
          (
            onPressed: () => eventValue.doEvent(context: context, event: StdValueProperty.onClicked, parameter: key),
            child: Text(key.name)
          )
        );
      }
      return SizedBox.fromSize
      (
        size: sz,
        child: Container
        (
          color: Colors.amber,
          child: GridView.count
          (
            crossAxisCount: 4,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 6.1 / 4.0,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            children: children,
          ),
        )
      );
    },
  );
}

class _calcKey
{
  final String text;

  const _calcKey(this.text);
}

CalcNumber _sqr(CalcNumber x, CalcNumber y) => math.sqrt(x);
CalcNumber _powerTwo(CalcNumber x, CalcNumber y) => x * x;
CalcNumber _add(CalcNumber x, CalcNumber y) => x + y;
CalcNumber _sub(CalcNumber x, CalcNumber y) => x - y;
CalcNumber _mul(CalcNumber x, CalcNumber y) => x * y;
CalcNumber _div(CalcNumber x, CalcNumber y) => x / y;