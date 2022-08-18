// ignore_for_file: avoid_init_to_null

import 'package:data_binder/data_binder.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'calc_operator.dart';

class CalcModel
{
  final binder = DataBinder(autoCreateValue: true);
  bool entryMode = false;
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

    switch (op.type)
    {
      case CalcOpType.digit:
      if (!entryMode)
      {
        entryMode = true;
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
      // TODO: Handle this case.
      break;
    }

    display.forceValueNotify();
  }

  doOp(CalcOperator op)
  {
    if (entryMode)
    {
      final xReg = double.parse(textEntry);
      entryMode = false;
      valueStack.add(xReg);
    }

    bool show = false;
    while (opStack.isNotEmpty && op.priority <= opStack.last.priority && calcStackTop())
    {
      show = true;
    }

    opStack.add(op);

    if (show && valueStack.isNotEmpty)
    {
      textEntry = valueStack.last.toString();
    }
  }

  singleOp(CalcOperator op)
  {
    if (entryMode)
    {
      final xReg = double.parse(textEntry);
      entryMode = false;

      final tReg = op.function(xReg, 0);

      valueStack.add(tReg);
      textEntry = tReg.toString();
    }
    else
    {
      if (valueStack.isNotEmpty)
      {
        final tReg = op.function(valueStack.last, 0);
        valueStack.last = tReg;
        textEntry = tReg.toString();
      }
    }
  }

  doEdit(CalcOperator op)
  {
    switch (op.operation)
    {
      case CalcOp.clearAll:
      textEntry = '0.';
      entryMode = false;
      valueStack.clear();
      opStack.clear();
      break;

      default:
      break;
    }
  }

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
        break;
      }
    }

    return result;
  }

  displayText(value, parameter, Type type)
  {
    return textEntry;
  }
}