// ignore_for_file: unnecessary_this, avoid_print, unused_local_variable, prefer_const_constructors
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:data_binder/data_binder.dart';

void main()
{
  runApp(const MyApp());
}

class MyApp extends StatefulWidget
{
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
{
  final appBinder = DataBinder(autoCreateValue: true);

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp
    (
      home: appBinder.build(context: context, builder: (context) => MyHomePage(context: context, title: 'title')),
    );
  }

  @override
  void initState()
  {
    super.initState();
    appBinder.addValue('check', false);
    final checkbox = appBinder.addValue
    (
      'check', false, onEvent: (value, context, event, parameter)
      {
        value.value = !(value.value as bool? ?? false);
      }, onInitialized: (context, value, state)
      {
        print('onInitialized');
      }
    );
  }
}

class MyHomePage extends StatefulWidget
{
  final String title;
  MyHomePage({Key? key, required BuildContext context, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  TextStyle? style1, style2;
  final binder = DataBinder(autoCreateValue: true);
  bool? isChecked = null;
  bool _lights = false;

  _MyHomePageState()
  {
    final cnt = binder.addValue
    (
      'counter', 1,
      tag: 'qAqA',
      presenter: (v, param, type)
      {
        final strType = type.toString();
        final value = v as int;
        if (type == ValueState.runtimeTypeDouble)
        {
          return 0.1 * value.toDouble();
        }
        else if (type == ValueState.runtimeTypeBool)
        {
          return (value & 1) == 1;
        }
        else if (strType == 'TextStyle?')
        {
          return (value & 1) == 1 ? style1 : style2;
        }
        else
        {
          return '[$value]';
        }
      },
      //onValueChanged: (value) => value.setProperty('style', (value.value & 1) == 1 ? style1 : style2)
    );

    cnt.addValueListener
    (
      (value, context, event, parameter)
      {
        print('${value.value} ${value.tag} $event $parameter');
      }, event: 'EVENT', parameter: 2.33
    );
    //cnt.addValueListener((value,event,param) => value.setProperty('style', (value.value & 1) == 1 ? style1 : style2));

    binder.addValue
    (
      'style', style1, presenter: (value, param, type)
      {
        return (cnt.value & 1) == 1 ? style1 : style2;
      }
    );

    final editor = binder.addValue
    (
      'editor', 'INIT text',
      //onInitialized: (context, value, state) => (state as TextEditingController).text = 'QaQaQa',
      onValueChanged: (value)
      {
        if (value.state != null)
        {
          final te = value.state as TextEditingController;
          print('Text changed ${te.text}');
        }
      }
    );

    final editor1 = binder.addValue
    (
      'editor1', 'INIT 1 text',
      //onInitialized: (context, value, state) => (state as TextEditingController).text = 'QaQaQa',
      onValueChanged: (value)
      {
        if (value.state != null)
        {
          final te = (value.state as TextFieldControllers).editingController!;
          print('Text changed ${te.text}');
        }
      },
      onEvent: (value, context, event, parameter) => print('Event $event $parameter')
    );

    binder.addValue
    (
      'slider',
      0.5,
      onValueChanged: (value) => print("slider: ${value.value}"),
    );

    /*final checkbox = binder.addValue<bool?>
    (
      'check', false, onEvent: (value, event, parameter)
      {
        value.value = !(value.value as bool? ?? false);
      }
    );*/

    final radio =
    binder.addValue('radio', RadioValues.second, onValueChanged: (value) => print(value.value.toString()));

    binder.addValue('drop_down', 'Free');

    binder.addValue
    (
      'switch',
      true,
      onValueChanged: (value) => print("switch changed: ${value.value}"),
    );

    final button = binder.addValue('button', false, onEvent: <bool>(value, context, event, parameter) => cnt.value++);

    binder.addValue('button1', false,
      onEvent: (value, context, event, parameter) => print("button1 ${value.name} $event $parameter"));

    binder.addValue
    (
      'action_sheet_click', false, onEvent: (value, context, event, parameter)
      {
        print("action_sheet_click");
        Navigator.pop(context!);
      }
    );

    binder.addValue('sosol', 12.56);
  }

  checkEvent(ValueState value, dynamic event, dynamic parameter)
  {
    value.value = !(value.value as bool? ?? false);
  }

  @override
  void initState()
  {
    super.initState();
  }

  @override
  void didChangeDependencies()
  {
    super.didChangeDependencies();

    style1 = Theme.of(context).textTheme.displayMedium!.copyWith(color: Colors.red, fontWeight: FontWeight.bold);
    style2 = Theme.of(context).textTheme.displayMedium!.copyWith(color: Colors.green);
    binder.forceNotifyAll();

    var v = ValueState.readOf<double>(context, 'sosol', defaultValue: 2.34);
  }

  final Widget goodJob = const Text('Good job!');
  @override
  Widget build(BuildContext context)
  {
    return CheckboxTheme
    (
      data: getCheckboxTheme(context),
      child: binder.build
      (
        context: context,
        builder: (BuildContext context) => Scaffold
        (
          appBar: AppBar(title: Text(widget.title)),
          body: Scrollbar
          (
            thumbVisibility: true,
            child: SingleChildScrollView
            (
              child: Center
              (
                child: Column
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>
                  [
                    const Text('You have pushed the button this many times:'),
                    //_counter.buildWidget
                    /*Checkbox
                  (
                    value: isChecked,
                    tristate: true,
                    //overlayColor: MaterialStateProperty.resolveWith(getOverlayColor),
                    onChanged: (value)
                    {
                      setState
                      (
                        ()
                        {
                          isChecked = !(isChecked ?? false);
                        }
                      );
                    },
                  ),*/
                    buildCheckBox
                    (
                      context,
                      bindValue: 'check',
                      setValueAfterOnChanged:
                      false
                    ), // fillColor: MaterialStateProperty.resolveWith(getColor),),
                    DataBinder.of(context)['counter'].buildWidget
                    (
                      context,
                      builder: <String>(context, value, child)
                      {
                        final style = binder['style'].read<TextStyle?>();
                        return Text(value.readString('aaa'), style: style);
                      }
                    ),
                    buildText(context, bindValue: 'counter', styleParam: 'style'),
                    binder.getValue('editor').buildWidget
                    (
                      context, builder: (context, value, child)
                      {
                        return TextField
                        (
                          controller: value.initializeState
                          (
                            context: context,
                            initializer: (context, value)
                            {
                              final result = TextEditingController(text: value.readString());
                              result.addListener
                              (
                                ()
                                {
                                  value.value = result.text;
                                }
                              );
                              return result;
                            }
                          ),
                          /*inputFormatters:
                      [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\-?\d{0,2}')),
                        //FilteringTextInputFormatter.deny(RegExp('[abFeG]')),
                      ],*/
                          enabled: true,
                        );
                      }
                    ),
                    buildTextField(context, bindValue: 'editor1'),
                    Padding
                    (
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: buildCupertinoTextFieldBorderless(context, bindValue: 'editor1')
                    ),
                    buildRadio(context, 'radio'),
                    buildElevatedButtonIcon
                    (
                      context,
                      bindValue: 'button1',
                      label: const Text('BUTTON1', style: TextStyle(fontSize: 20.0, color: Colors.white)),
                      icon: Text('icon')
                    ),
                    buildDropdownButton
                    (
                      context,
                      bindValue: 'drop_down',
                      items: <String>['One', 'Two', 'Free', 'Four']
                      .map<DropdownMenuItem<String>>
                      (
                        (String value)
                        {
                          return DropdownMenuItem<String>
                          (
                            value: value,
                            child: Text(value),
                          );
                        }
                      ).toList()
                    ),
                    buildSlider
                    (
                      context,
                      bindValue: 'slider',
                      labelBuilder: (sliderValue) => sliderValue.toStringAsFixed(3),
                      divisions: 10,
                      min: 0,
                      max: 100
                    ),
                    buildCupertinoSlider(context, bindValue: 'slider', min: 0, max: 100),
                    buildSwitch(context, bindValue: 'switch'),
                    buildCupertinoSwitch(context, bindValue: 'switch'),
                    buildCupertinoButtonFilled(context,
                      bindValue: 'button2', child: Text('Cupertino Tlacitko'), enabled: false),
                    CupertinoButton.filled
                    (
                      child: Text('Cupertino ActionSheet'),
                      onPressed: () => _showActionSheet(context),
                    ),
                    Padding
                    (
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: buildCircularProgressIndicatorAdaptive(context, bindValue: 'counter')
                    ),
                    Padding
                    (
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                      child: buildLinearProgressIndicator(context, bindValue: 'counter'),
                    ),
                    buildVisibility
                    (
                      context,
                      bindValue: 'counter',
                      builder: (context, value, child) => const Text("VISIBLE!"),
                      maintainState: true,
                      maintainAnimation: true,
                      maintainSize: true
                    )
                  ],
                ),
              )
            )
          ),
          floatingActionButton: FloatingActionButton
          (
            child: const Icon(Icons.plus_one),
            /*onPressed: ()
            {
              //var v = binder['counter'];
              //v.value++;

              DataBinder.of(context).getValue('button').doEvent();
            },*/
            onPressed: () => ValueState.of(context, 'button')
            .doEvent(context: context, event: StdValueProperty.onPressed, parameter: 'AAA'),
          ),
        )
      )
    );
  }

  void _showActionSheet(BuildContext context)
  {
    showCupertinoModalPopup<void>
    (
      context: context,
      builder: (popupContext)
      {
        return buildCupertinoActionSheet
        (
          context,
          bindValue: 'action-event',
          title: const Text('Title'),
          message: const Text('Message'),
          actions: <CupertinoActionSheetAction>
          [
            CupertinoActionSheetAction
            (
              /// This parameter indicates the action would be a default
              /// defualt behavior, turns the action's text to bold text.
              isDefaultAction: true,
              onPressed: ()
              {
                Navigator.pop(popupContext);
              },
              child: const Text('Default Action'),
            ),
            CupertinoActionSheetAction
            (
              onPressed: ()
              {
                Navigator.pop(popupContext);
              },
              child: const Text('Action'),
            ),
            CupertinoActionSheetAction
            (
              /// This parameter indicates the action would perform
              /// a destructive action such as delete or exit and turns
              /// the action's text color to red.
              isDestructiveAction: true,
              onPressed: ()
              {
                Navigator.pop(popupContext);
              },
              child: const Text('Destructive Action'),
            ),
            buildCupertinoActionSheetAction
            (
              context,
              popupContext: popupContext, //
              bindValue: 'action_sheet_click', //
              child: const Text('Bind action')
            )
          ],
        );
      }
    );
  }

  Widget buildRadio(BuildContext context, String bindValue)
  {
    return buildBasicRadioColumn<RadioValues>
    (
      context,
      bindValue: bindValue,
      checkedValues: [RadioValues.first, RadioValues.second, RadioValues.three],
      titleTexts: ['prvni', 'druhy', 'treti'],
      titleWidgets: [const Text('prvni widget')]
    );
    /*return Column(children:
    <Widget>[
      /////////////////////
      ListTile(
        title: Text('prvni'),
        enabled: false,
        leading: EventBinderBuilder.buildRadio<RadioValues>(context,bindValue: bindValue,checkedValue: RadioValues.first, enabled: false),
      ),
      ////////////////////
      ListTile(
        title: Text('druhy'),
        leading: EventBinderBuilder.buildRadio<RadioValues>(context,bindValue: bindValue,checkedValue: RadioValues.second
        ),
      ),
      ////////////////////
      EventBinderBuilder.buildRadioListTile<RadioValues>(context,bindValue: bindValue,  title: Text('treti'), checkedValue: RadioValues.three),
    ],);*/
  }

  CheckboxThemeData getCheckboxTheme(BuildContext context)
  {
    Color fillColor(Set<MaterialState> states)
    {
      const Set<MaterialState> interactiveStates = <MaterialState>
      {
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.contains(MaterialState.disabled))
      {
        return Colors.grey;
      }
      else if (states.any(interactiveStates.contains))
      {
        return Colors.lightBlue;
      }
      else
      {
        return Colors.red;
      }
    }

    Color overlayColor(Set<MaterialState> states)
    {
      if (states.contains(MaterialState.disabled))
      {
        return Colors.transparent;
      }
      else
      {
        return Colors.blue.withAlpha(20);
      }
    }

    Color checkColor(Set<MaterialState> states)
    {
      return Colors.transparent;
    }

    final result = CheckboxTheme.of(context).copyWith
    (
      fillColor: MaterialStateColor.resolveWith(fillColor),
      overlayColor: MaterialStateColor.resolveWith(overlayColor)
    );

    return result;
  }
}

enum RadioValues { first, second, three }
///////////////////////////////////////////////////////////////////////////////////////