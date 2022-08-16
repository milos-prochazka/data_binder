import 'package:data_binder/data_binder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildDecimalKeyboard(BuildContext context)
{
  final eventValue = ValueState.of(context, 'keyEvent');
  return Builder
  (
    builder: (context)
    {
      const keys =
      [
        _calcKey('C'),
        _calcKey('M+'),
        _calcKey('M-'),
        _calcKey('MRC'),
        /////////////
        _calcKey('7'),
        _calcKey('8'),
        _calcKey('9'),
        _calcKey('/'),
        /////////////
        _calcKey('4'),
        _calcKey('5'),
        _calcKey('6'),
        _calcKey('*'),
        /////////////
        _calcKey('1'),
        _calcKey('2'),
        _calcKey('3'),
        _calcKey('-'),
        /////////////
        _calcKey('0'),
        _calcKey('.'),
        _calcKey('='),
        _calcKey('+'),
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
            onPressed: () =>
            eventValue.doEvent(context: context, event: StdValueProperty.onClicked, parameter: key.text),
            child: Text(key.text)
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
            childAspectRatio: 1.5,
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