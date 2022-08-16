import 'package:data_binder/data_binder.dart';
import 'package:flutter/src/widgets/framework.dart';

class CalcModel
{
  final binder = DataBinder(autoCreateValue: true);
  bool entryMode = false;
  String textEntry = '0.';
  late ValueState display;
  double yReg = 0;
  String operation = '';

  CalcModel()
  {
    display = binder.addValue('display', 0, presenter: displayText);
    binder.addValue('keyEvent', null, onEvent: keyDown);
  }

  keyDown(ValueState value, BuildContext? context, event, parameter)
  {
    String keyDown = parameter as String;

    if ("0".compareTo(keyDown) <= 0 && "9".compareTo(keyDown) >= 0)
    {
      if (!entryMode)
      {
        entryMode = true;
        textEntry = keyDown;
      }
      else
      {
        if (textEntry == '0')
        {
          textEntry = keyDown;
        }
        else
        {
          textEntry += keyDown;
        }
      }
    }
    else if ("." == keyDown)
    {
      if (!textEntry.contains("."))
      {
        textEntry += '.';
      }
    }
    else if ('+-*/'.contains(keyDown))
    {
      doOp(keyDown);
    }

    display.forceValueNotify();
  }

  doOp(String op)
  {
    if (operation.isNotEmpty)
    {
      final xReg = double.parse(textEntry);

      switch (operation)
      {
        case '+':
        yReg += xReg;
        textEntry = yReg.toString();
        break;

        case '-':
        yReg -= xReg;
        break;

        case '*':
        yReg *= xReg;
        break;

        case '/':
        yReg /= xReg;
        break;
      }

      textEntry = yReg.toString();
      operation = '';
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