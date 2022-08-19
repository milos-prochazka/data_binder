// ignore_for_file: avoid_init_to_null

import 'package:data_binder/data_binder.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'calc_operator.dart';

class CalcModel
{
  final binder = DataBinder(autoCreateValue: true);
  _EntryMode entryMode = _EntryMode.wait;
  String textEntry = '0.';
  late ValueState display;
  final opStack = <CalcOperator>[];
  final valueStack = <double>[];

  CalcModel()
  {
    display = binder.addValue('display', 0, presenter: displayText);
    binder.addValue('keyEvent', null, onEvent: keyDown);
  }

  keyDown(ValueState value, BuildContext? context, event, parameter)
  {
    final op = (parameter as CalcOperator);
    print('KEY DOWN: ${op.name} *************************************************************');

    switch (op.type)
    {
      case CalcOpType.digit:
      if (entryMode != _EntryMode.edit)
      {
        if (entryMode == _EntryMode.number && valueStack.isNotEmpty)
        {
          valueStack.removeLast();
        }
        entryMode = _EntryMode.edit;
        textEntry = op.name;
      }
      else
      {
        if (op.operation == CalcOp.dot)
        {
          if (!textEntry.contains("."))
          {
            textEntry += '.';
          }
        }
        else
        {
          if (textEntry == '0')
          {
            textEntry = op.name;
          }
          else
          {
            textEntry += op.name;
          }
        }
      }
      break;

      case CalcOpType.twoOp:
      doOp(op);
      break;

      case CalcOpType.singleOp:
      case CalcOpType.singleFunction:
      singleOp(op);
      break;

      case CalcOpType.edit:
      doEdit(op);
      break;

      case CalcOpType.global:
      doGlobal(op);
      break;
    }

    display.forceValueNotify();
    print(toString());
  }

  doOp(CalcOperator op)
  {
    _storeEntry();

    bool show = false;
    while (opStack.isNotEmpty && op.priority <= opStack.last.priority && calcStackTop())
    {
      show = true;
    }

    _removeRedundantOperator();
    opStack.add(op);
    entryMode = _EntryMode.operator;

    if (show && valueStack.isNotEmpty)
    {
      textEntry = valueStack.last.toString();
    }
  }

  singleOp(CalcOperator op)
  {
    _storeEntry();

    if (valueStack.isNotEmpty)
    {
      final tReg = op.function(valueStack.last, 0);
      valueStack.last = tReg;
      textEntry = tReg.toString();
      entryMode = _EntryMode.number;
    }
  }

  doEdit(CalcOperator op)
  {
    switch (op.operation)
    {
      case CalcOp.clearAll:
      {
        textEntry = '0.';
        entryMode = _EntryMode.wait;
        valueStack.clear();
        opStack.clear();
      }
      break;

      default:
      break;
    }
  }

  doGlobal(CalcOperator op)
  {
    switch (op.operation)
    {
      case CalcOp.leftBrace:
      {
        _storeEntry(() => opStack.add(CalcOperator(CalcOp.multiply, CalcOpType.twoOp, name: '*', function: _mul)));
        opStack.add(op);
        textEntry = '0.';
        entryMode = _EntryMode.wait;
      }
      break;

      case CalcOp.rightBrace:
      {
        while (opStack.isNotEmpty)
        {
          final lastOp = opStack.last;

          _removeRedundantOperator();
          print(toString());

          _storeEntry();
          print(toString());

          if (!calcStackTop() || lastOp.operation == CalcOp.leftBrace)
          {
            print(toString());
            break;
          }
        }

        if (valueStack.isNotEmpty)
        {
          textEntry = valueStack.last.toString();
        }
      }
      break;

      case CalcOp.equal:
      {
        _removeRedundantOperator();
        print(toString());

        _storeEntry();
        print(toString());

        while (calcStackTop())
        {
          print(toString());
        }

        if (valueStack.isNotEmpty)
        {
          textEntry = valueStack.last.toString();
        }
      }
      break;

      default:
      break;
    }
  }

  CalcNumber _mul(CalcNumber x, CalcNumber y) => x * y;

  bool calcStackTop()
  {
    var result = false;

    if (opStack.isNotEmpty)
    {
      final op = opStack.last;
      switch (op.type)
      {
        case CalcOpType.singleOp:
        case CalcOpType.singleFunction:
        {
          if (valueStack.isNotEmpty)
          {
            result = true;

            opStack.removeLast();

            var xReg = valueStack.last;
            xReg = op.function(xReg, 0);
            valueStack.last = xReg;
          }
        }
        break;

        case CalcOpType.twoOp:
        {
          if (valueStack.length >= 2)
          {
            result = true;

            opStack.removeLast();
            final yReg = valueStack.removeLast();
            var xReg = valueStack.removeLast();

            xReg = op.function(xReg, yReg);

            valueStack.add(xReg);
          }
        }
        break;

        default:
        {
          opStack.removeLast();
          result = true;
        }
        break;
      }
    }

    return result;
  }

  displayText(value, parameter, Type type)
  {
    return textEntry;
  }

  bool _storeEntry([_EntryFunction? entryFunction])
  {
    var result = false;

    if (entryMode == _EntryMode.edit)
    {
      final xReg = double.parse(textEntry);
      valueStack.add(xReg);
      entryMode = _EntryMode.wait;
      entryFunction?.call();
      result = true;
    }

    return result;
  }

  _removeRedundantOperator()
  {
    if (entryMode == _EntryMode.operator && opStack.isNotEmpty)
    {
      opStack.removeLast();
      entryMode = _EntryMode.wait;
    }
  }

  @override
  String toString()
  {
    final builder = StringBuffer();

    builder.writeln('"$textEntry" $entryMode');

    for (final value in valueStack)
    {
      builder.write(value.toString());
      builder.write(',');
    }
    builder.writeln();

    for (final value in opStack)
    {
      builder.write('"${value.name}",');
    }

    return builder.toString();
  }
}

typedef _EntryFunction = Function();

enum _EntryMode { wait, edit, number, operator }