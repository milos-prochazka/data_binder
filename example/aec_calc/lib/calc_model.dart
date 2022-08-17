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
  double yReg = 0;
  CalcOperator operation = CalcOperator.noop;

  CalcModel()
  {
    display = binder.addValue('display', 0, presenter: displayText);
    binder.addValue('keyEvent', null, onEvent: keyDown);
  }

  keyDown(ValueState value, BuildContext? context, event, parameter)
  {
    final key = (parameter as CalcOperator);

    switch (key.type)
    {
      case CalcOpType.digit:
      if (!entryMode)
      {
        entryMode = true;
        textEntry = key.name;
      }
      else
      {
        if (key.operation == CalcOp.dot)
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
            textEntry = key.name;
          }
          else
          {
            textEntry += key.name;
          }
        }
      }
      break;

      case CalcOpType.twoOp:
      doOp(key);
      break;

      case CalcOpType.singleOp:
      // TODO: Handle this case.
      break;
      case CalcOpType.singleFunction:
      // TODO: Handle this case.
      break;
      case CalcOpType.edit:
      // TODO: Handle this case.
      break;
      case CalcOpType.global:
      // TODO: Handle this case.
      break;
    }

    display.forceValueNotify();
  }

  doOp(CalcOperator op)
  {
    if (operation.operation != CalcOp.noop)
    {
      final xReg = double.parse(textEntry);

      switch (operation?.operation)
      {
        case CalcOp.add:
        yReg += xReg;
        textEntry = yReg.toString();
        break;

        case CalcOp.subtract:
        yReg -= xReg;
        break;

        case CalcOp.multiply:
        yReg *= xReg;
        break;

        case CalcOp.divide:
        yReg /= xReg;
        break;

        default:
        break;
      }

      textEntry = yReg.toString();
      operation = CalcOperator.noop;
      entryMode = false;
    }
    else
    {
      operation = op;
      yReg = double.parse(textEntry);
      entryMode = false;
    }
  }

  displayText(value, parameter, Type type)
  {
    return textEntry;
  }
}