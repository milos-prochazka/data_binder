import 'calc_operator.dart';

class CalcDisplay 
{
  CalcNumber number = 0.0;
  String entry = '';
  bool _entryMode = true;

  CalcNumber get value 
  {
    return entryMode ? CalcNumber.parse(entry) : number;
  }

  set entryMode(bool value) 
  {
    if (value != _entryMode) 
    {
      if (!value)
      {
        number = CalcNumber.tryParse(entry) ?? number;
      }
      _entryMode = value;


    }
  }

  bool get entryMode => _entryMode;

  clear() 
  {
    entryMode = false;
    entry = '0';
    number = 0;
  }

  set value(CalcNumber value) 
  {
    number = value;
    entryMode = false;
  }

  String get mainDisplay 
  {
    return entryMode ? entry : value.toString();
  }
}