// ignore_for_file: unnecessary_this
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef ValuePresenter = dynamic Function(dynamic value, dynamic parameter, Type type);

/// ### Hlavní třída propojování hodnot proměnných a Widgetů
///
/// - [DataBinder] zpravidla vytváří ViewModel pro propojení událostí s Widgety
/// - Obsahuje seznam proměnných [_values]
///
class DataBinder
{
  /// - Pokud je true [DataBinder] automaticky vytvoří proměnnou na kterou se Widget ptá.
  /// - Využitelné pro ladění layoutu ve chvíli kdy není ještě hotový view model.
  bool autoCreateValue;

  /// Nadřízený [DataBinder]
  /// - Pokud není proměnná nalezena prohledá se tento nadřízený [DataBinder]
  /// - Slouží k hiearchickému propojení DataBinderu
  ///   - Například Binder na úrovni aplikace obsahuje proměnné sdílené mezi stránkami aplikace.
  ///   - A vnořený binder vyvořený view modelem obsahuje proměnné vztahující se k Widgetu stránky.
  DataBinder? parent;

  /// - Seznam proměnných
  final _values = <String, ValueState>{};

  /// Konstruktor
  /// - Vytvoří [DataBinder].
  ///
  /// Argumenty
  /// - [autoCreateValue] - pokud je true [DataBinder] automaticky vytvoří proměnnou na kterou se Widget ptá.
  ///   Využitelné pro ladění layoutu ve chvíli kdy není ještě hotový view model.
  DataBinder({this.autoCreateValue = false});

  /// Interní čtení proměnné
  /// - Pokud nenalezne proměnnou ve [_values], prohledá [parent] binder.
  ValueState? _getValueInternal(String name)
  {
    return _values[name] ?? parent?._getValueInternal(name);
  }

  /// Vrací proměnnou podle jejího jména.
  /// - Pokud proměnná neexistuje vyvolá vyjímku.
  ValueState operator [](String name) => _getValueInternal(name)!;

  /// Vrací proměnnou podle jejího jména.
  /// - Pokud proměnná neexistuje a je povoleno [autoCreateValue], vytvoří ji.
  /// - Pokud je [autoCreateValue] zakázáno a proměnná neexistuje vyvolá vyjímku.
  ///
  /// Argumenty
  /// - [name] - název proměnné
  /// - [defaultValue] - implicitní hodnota proměnné, použije se pokud proměnná neexistuje a vytváří se.
  ///
  ValueState getValue(String name, {dynamic defaultValue})
  {
    if (!this.autoCreateValue)
    {
      return _getValueInternal(name)!;
    }
    else
    {
      return _getValueInternal(name) ?? addValue(name, defaultValue);
    }
  }

  /// Přidává novou proměnnou do seznamu.
  /// - Pokud proměnná existuje nahradí ji.
  ///
  /// Argumenty
  /// - [name] - název proměnné.
  /// - [value] - hodnota proměnné
  /// - [presenter] - funkce provadějící konverzi hodnoty proměnné do formátu požadovaného widgetem.
  /// - [onInitialized] - událost vyvolaná ve chvíli kdy widget nastaví stav proměnné (setState) a nastavuje.
  /// - [onValueChanged] - událost vyvolaná ve chvíli kdy se hodnota proměnné mění.
  /// - [onEvent] - událost kterou vyvolává zejména widget voláním doEvent (například tlačítko po tom co je stisknuto).
  /// - [tag] - pomocná data. Může využívat jak Widget tak i View model.
  ValueState addValue
  (
    String name, dynamic value,
    {ValuePresenter? presenter,
      ValueStateInitializedEvent? onInitialized,
      ValueChangedEvent? onValueChanged,
      ValueStateEvent? onEvent,
      dynamic tag}
  )
  {
    final result = ValueState(name, value,
      presenter: presenter, onValueChanged: onValueChanged, onInitialized: onInitialized, onEvent: onEvent, tag: tag);
    _values[name] = result;
    return result;
  }

  /// Čtení hodnoty proměnné
  /// - Volá [ValueState.read]
  /// - Určena pro Widget. Pokud má hodnota nastavený presenter, volá ho pro konverzi.
  /// - Čte interpretovanou hodnotu proměnné
  /// - Pokud není proměnná nalezena, prohledá se i [parent] [DataBinder]
  /// - Pokud není proměnná nalezena, vrátí vyjímku
  ///
  /// Argumenty
  /// - name - název proměnné.
  T read<T>(String name)
  {
    return _getValueInternal(name)!.read<T>();
  }

  /// Vytvoří [DataBinderWidget]
  /// - [DataBinderWidget] je [InheritedWidget], slouží ve stromu widgetů k nalezení [DataBinder].
  /// - Používá se zpravidla v build stránky jako root widget.
  ///
  /// Argumenty
  /// - [key] - widget klíč.
  /// - [context] - Kontext vytváření widgetů.
  /// - [builder] - Builder vytvářející vložené widgety.
  Widget build({Key? key, required BuildContext context, required WidgetBuilder builder})
  {
    final ihnerited = context.dependOnInheritedWidgetOfExactType<DataBinderWidget>();
    if (ihnerited != null)
    {
      parent = ihnerited.binder;
    }

    return DataBinderWidget(key: key, binder: this, child: Builder(builder: builder));
  }

  /// Vyhledá [DataBinderWidget] a vrací k němu přiřazený [DataBinder]
  static DataBinder of(BuildContext context)
  {
    final ihnerited = context.dependOnInheritedWidgetOfExactType<DataBinderWidget>();

    return ihnerited!.binder;
  }

  /// Odešle notifikaci změny do všech proměnných
  forceNotifyAll()
  {
    for (final entry in this._values.entries)
    {
      entry.value.forceValueNotify();
    }
    parent?.forceNotifyAll();
  }

  /// Čtení proměnné
  ///
  /// Speciální forma určená pro buildery widgetů. Viz třeba [buildText].
  ///
  /// - Pokud je zadán název proměnné [sourceValueName] čtehodnotu z této proeměnné. Pro čtení použije doplňkový parametr [keyParameter].
  /// - Pokud není zadáno [sourceValueName], použije dvojici [propertySource] a [keyParameter].
  ///   - [propertySource]  je v builderech hlavní proměnná ve které se čtou data.
  /// - Pokud není proměnná zadána použije se defaultValue.
  ///
  /// Více viz příklad:
  /// ~~~
  /// Widget buildMyText
  /// (
  ///    BuildContext context,
  ///    {required String bindValue,   // Hlavni proměnná ze které se čte text
  ///    dynamic bindValueParam,
  ///    //////////////
  ///    TextStyle? style,             // Styl - zadaný přímo odkazem na TextStyle
  ///    String? styleValue,           // Název proměnné ze které se čte Style
  ///    dynamic styleParam,           // Parametr používaný pro čtení hodnoty
  ///    //////////////
  /// )
  /// {
  ///   final binder = DataBinder.of(context); // Získání odkazu na binder

  ///   return binder.getValue(bindValue, defaultValue: '').buildWidget
  ///   (
  ///     context, //
  ///     builder: (context, value, child)
  ///     {
  ///       return Text
  ///       (
  ///         value.readString(bindValueParam), // Čtení hodnoty proměnné
  ///         key: value.setKey(key),
  ///         // - styl může být zadán přímo - style: myStyle
  ///         // - nebo se může číst z proměnné bindValue - styleParam: 'myStyle'
  ///         //   (odpovídá čtení value.read('myStyle'))
  ///         // - číst z jiné proměnné styleValue: 'myStyleValue', styleParam : 'myHighlinedSyle'
  ///         //   (POZOR!!! v tomto případě se po změně proměnné myStyle widget automaticky neobnoví)
  ///         style: binder.readOrDefault
  ///         (
  ///           defaultValue: style, sourceValueName: styleValue, propertySource: value, keyParameter: styleParam
  ///         ),
  ///       );
  ///     }
  ///   );
  /// }
  /// ~~~
  T readOrDefault<T>
  (
    {required T defaultValue, String? sourceValueName, ValueState? propertySource, dynamic keyParameter}
  )
  {
    if (sourceValueName == null)
    {
      if (keyParameter == null || propertySource == null)
      {
        return defaultValue;
      }
      else
      {
        //return propertySource.getProperty(keyParameter) ?? defaultValue; ~~smazat properties
        return propertySource.read<T>(keyParameter) ?? defaultValue;
      }
    }
    else
    {
      return _getValueInternal(sourceValueName)?.read<T>(keyParameter) ?? defaultValue;
    }
  }
}

/// Třída rozšiřující InheritedWidget
/// - Provádí vazbu na DataBinder a umožňuje ho vyhledat ve stromu widgetů
class DataBinderWidget extends InheritedWidget
{
  final DataBinder binder;
  const DataBinderWidget({super.key, required super.child, required this.binder});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget)
  {
    return true;
  }
}

/// Třída uchovávající stav proměnné a zajišťující obousměrnou vazbu mezi widgetem a view modelem
/// - Rozšiřuje vlastnosti  [ValueListenable]
/// - Proměnné se identifikují názvem (text)
/// - Při změně předává notifikace do widgetu a pomocí události [onValueChanged] do view modelu.
/// -
class ValueState extends ChangeNotifier implements ValueListenable<dynamic>
{
  /// Název proměnné
  /// - Slouží k identifikaci proměnné v rámci [DataBinder]
  String name;

  /// Prezentace proměnné
  /// - Slouží ke konverzi hodnoty proměnné při četní pomocí funkcí [read] a [readString]
  /// - Používá se zejména při zobrazení stavu proměnné
  ValuePresenter? presenter;

  /// Stav proměnné
  /// - Používá se pro přenos stavu o Widgetu do modelu
  /// - Nastavuje se při vytváření widgetu kdy je již přístupný BuildContext, aby widget přenesl stav
  ///   do modelu.
  /// TODO Ještě domyslet funkce v běhu programu (vytváří se pouze jednou a pak se jen spravuje. Je to správně??)
  dynamic state;

  final ValueStateInitializedEvent? onInitialized;
  final ValueStateEvent? onEvent;
  final ValueChangedEvent? onValueChanged;
  //Map<dynamic, dynamic>? _properties; ~~smazat properties
  dynamic tag;

  static final runtimeTypeDouble = (0.0).runtimeType;
  static final runtimeTypeInt = (0).runtimeType;
  static final runtimeTypeBool = (false).runtimeType;
  static final runtimeTypeString = ('').runtimeType;

  ///
  /// Konstruktor
  ///
  /// Argumenty
  /// - [name] - název proměnné.
  /// - [value] - hodnota proměnné
  /// - [presenter] - funkce provadějící konverzi hodnoty proměnné do formátu požadovaného widgetem.
  /// - [onInitialized] - událost vyvolaná ve chvíli kdy widget nastaví stav proměnné (setState) a nastavuje.
  /// - [onValueChanged] - událost vyvolaná ve chvíli kdy se hodnota proměnné mění.
  /// - [onEvent] - událost kterou vyvolává zejména widget voláním doEvent (například tlačítko po tom co je stisknuto).
  /// - [tag] - pomocná data. Může využívat jak Widget tak i View model.
  ValueState
  (
    this.name,
    this._value,
    {
      this.presenter,
      this.onInitialized,
      this.onEvent,
      this.onValueChanged,
      this.tag,
      Key? key,
    }
    //Map<dynamic, dynamic>? properties} ~~smazat properties
  )
  //: _properties = properties, ~~smazat properties
  : _key = key;

  T read<T>([dynamic parameter]) => (presenter == null) ? _value as T : presenter!(_value, parameter, T) as T;

  String readString([dynamic parameter]) =>
  (presenter == null) ? _value.toString() : (presenter!(_value, parameter, String)).toString();

  dynamic _value;
  @override
  dynamic get value => _value;

  set value(dynamic newValue)
  {
    if (_value != newValue)
    {
      _value = newValue;
      forceValueNotify();
    }
  }

  Key? _key;
  Key? get key => _key;

  GlobalKey? get globalKey => (_key != null && _key is GlobalKey) ? _key as GlobalKey : null;

  Key? setKey(Key? key)
  {
    if (key != _key)
    {
      _key = key;
    }

    return _key;
  }

  T initializeState<T>({required BuildContext context, required ValueStateInitializer initializer})
  {
    if (this.state == null)
    {
      final st = initializer(context, this);
      this.state = st ?? false;
      this.onInitialized?.call(context, this, st);
    }

    return this.state as T;
  }

  forceValue(dynamic newValue)
  {
    _value = newValue;
    forceValueNotify();
  }

  var _nestedNotification = false;
  var _delayedNotification = false;

  forceValueNotify()
  {
    if (_nestedNotification)
    {
      _delayedNotification = true;
    }
    else
    {
      try
      {
        _nestedNotification = true;

        do
        {
          _delayedNotification = false;

          onValueChanged?.call(this);
          notifyListeners();
        }
        while (_delayedNotification);
      }
      finally
      {
        _nestedNotification = false;
      }
    }
  }

  addValueListener(ValueStateEvent listener, {BuildContext? context, dynamic event, dynamic parameter})
  {
    this.addListener(() => listener.call(this, context, event, parameter));
  }

  doEvent({BuildContext? context, dynamic event, dynamic parameter})
  {
    this.onEvent?.call(this, context, event, parameter);
  }

  Widget buildWidget(BuildContext context, {required ValueStateWidgetBuilder builder, Widget? child})
  {
    return ValueStateBuilder
    (
      valueState: this,
      builder: builder,
      child: child,
    );
  }

/* ~~smazat properties
  dynamic getProperty(dynamic key) => this._properties?[key];

  void setProperty(dynamic key, dynamic value, [bool forceNotify = false])
  {
    this._properties ??= <dynamic, dynamic>{};
    final old = this._properties![key];

    if (forceNotify || old != value)
    {
      this._properties![key] = value;
      this.forceValueNotify();
    }
  }
*/

  static ValueState of(BuildContext context, String name, {dynamic defaultValue})
  {
    final ihnerited = context.dependOnInheritedWidgetOfExactType<DataBinderWidget>();

    return ihnerited!.binder.getValue(name, defaultValue: defaultValue);
  }

  static T readOf<T>(BuildContext context, String name, {dynamic defaultValue})
  {
    final value = ValueState.of(context, name, defaultValue: defaultValue);

    return value.read<T>() ?? defaultValue;
  }
}

typedef ValueStateWidgetBuilder = Widget Function(BuildContext context, ValueState value, Widget? child);
typedef ValueStateInitializer = dynamic Function(BuildContext context, ValueState value);
typedef ValueStateInitializedEvent = void Function(BuildContext context, ValueState value, dynamic state);
typedef ValueStateEvent = void Function(ValueState value, BuildContext? context, dynamic event, dynamic parameter);
typedef ValueChangedEvent = void Function(ValueState value);

////////////////////////////////////////////////////////////////////////////////////////////////

class ValueStateBuilder extends StatefulWidget
{
  final ValueState valueState;
  final ValueStateWidgetBuilder builder;
  final Widget? child;

  const ValueStateBuilder({super.key, required this.valueState, required this.builder, this.child});

  @override
  State<ValueStateBuilder> createState() => _ValueStateBuilderState();
}

class _ValueStateBuilderState extends State<ValueStateBuilder>
{
  @override
  void initState()
  {
    super.initState();
    widget.valueState.addListener(_valueChanged);
  }

  @override
  Widget build(BuildContext context)
  {
    return widget.builder(context, widget.valueState, widget.child);
  }

  @override
  void didUpdateWidget(ValueStateBuilder oldWidget)
  {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.valueState != widget.valueState)
    {
      oldWidget.valueState.removeListener(_valueChanged);
      widget.valueState.addListener(_valueChanged);
    }
  }

  @override
  void dispose()
  {
    widget.valueState.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged()
  {
    setState(() {});
  }
}

enum StdValueProperty
{
  enabled(0x0001),
  visible(0x0002),
  length(0x0003),
  slected(0x0004),
  checked(0x0005),
  /////
  onClicked(0x1000),
  onSelect(0x1001),
  onComplete(0x1002),
  onSubmited(0x1003),
  onTap(0x1004),
  onPressed(0x1005),
  onLongPress(0x1006),
  onHover(0x1007),
  onFocusChanged(0x1008),
  onChanged(0x1009),
  onChangeStart(0x100A),
  onChangeEnd(0x100B),
  onCanceled(0x100C),
  onEnd(0x100D),
  onSizeChanged(0x100E),
  ////
  ;

  final int value;
  const StdValueProperty(this.value);
}