import 'dart:io';

import 'package:dice/widgets/counter_field.dart';
import 'package:dice_tower/dice_tower.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  final String _title = 'Dice Tower Demo';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData.light().copyWith(primaryColor: Colors.blue),
      darkTheme: ThemeData.dark().copyWith(primaryColor: Colors.deepPurple),
      home: MyHomePage(title: _title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final List<Widget> _list = <Widget>[];
  final TextEditingController _chatInputController = TextEditingController();
  final TextEditingController _diceStringController = TextEditingController();
  final TextEditingController _diceCountController = TextEditingController();
  final TextEditingController _modifierController = TextEditingController();
  DndDice? _selectedDie;
  ValueNotifier<bool> isFabOpen = ValueNotifier(false);
  bool _showBottomSheet = false;

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (isFabOpen.value) {
            isFabOpen.value = false;
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: _appBar,
          body: _body,
          floatingActionButton: _fab,
          bottomNavigationBar: _bottomNav,
          bottomSheet:
              _bottomSheet, // This trailing comma makes auto-formatting nicer for build methods.
        ),
      );

  get _appBar => Platform.isIOS
      ? CupertinoNavigationBar(
          middle: Text(widget.title),
        )
      : AppBar(
          title: Text(widget.title),
        );

  get _body => ListView.builder(
      itemCount: _list.length, itemBuilder: (context, index) => _list[index]);

  get _fab => _showBottomSheet
      ? null
      : SpeedDial(
          openCloseDial: isFabOpen,
          icon: Icons.expand,
          children: [
            SpeedDialChild(
                label: 'DnD 5e',
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: const Icon(Icons.casino),
                onTap: () => setState(() => _showBottomSheet = true)),
            SpeedDialChild(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                child: const Icon(Icons.refresh),
                onTap: () => setState(() => _list.clear())),
          ],
        );

  get _bottomNav => _showBottomSheet
      ? null
      : BottomAppBar(
          elevation: 8,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: TextField(
                      controller: _chatInputController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          border: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(24.0)),
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  width: 1.0,
                                  style: BorderStyle.solid)),
                          suffixIcon: IconButton(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            icon: const Icon(Icons.cancel),
                            color: Colors.red,
                            onPressed: () =>
                                setState(() => _chatInputController.text = ""),
                          )),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _chatInputController.text.isNotEmpty
                    ? setState(() => {
                          if (_chatInputController.text.isNotEmpty)
                            {
                              _list.add(Text(_chatInputController.text)),
                              _chatInputController.text = ""
                            }
                        })
                    : null,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        );

  get _bottomSheet {
    return _showBottomSheet
        ? BottomSheet(
            animationController: BottomSheet.createAnimationController(this),
            elevation: 24,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) => _dnD5eSheet,
            onClosing: () {},
          )
        : null;
  }

  get _dnD5eSheet => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0))),
        width: double.infinity,
        height: 350,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: TextField(
                        readOnly: true,
                        controller: _diceStringController,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(24.0)),
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 1.0,
                                    style: BorderStyle.solid)),
                            suffixIcon: IconButton(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              icon: const Icon(Icons.cancel),
                              color: Colors.red,
                              onPressed: () => setState(
                                  () => _diceStringController.text = ""),
                            )),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _showBottomSheet = false),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  tooltip: 'close bottomsheet',
                ),
              ],
            ),
            const Divider(),
            Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Text('Dice')]),
            Row(
              children: [
                Expanded(
                  child: NumericInput(
                    textEditingController: _diceCountController,
                    style: Style.roundStacked,
                    initialValue: 1,
                    isNegativeValid: false,
                    canDecrement: true,
                    canReset: true,
                    dividerColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _setDiceText(DndDice.d4),
                          child: const Text('d4'),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () => _setDiceText(DndDice.d6),
                          child: const Text('d6'),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () => _setDiceText(DndDice.d8),
                          child: const Text('d8'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _setDiceText(DndDice.d10),
                          child: const Text('d10'),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () => _setDiceText(DndDice.d12),
                          child: const Text('d12'),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () => _setDiceText(DndDice.d20),
                          child: const Text('d20'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _setDiceText(DndDice.d100),
                          child: const Text('d100'),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            const Divider(),
            Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Text('Modifiers')],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: NumericInput(
                    textEditingController: _modifierController,
                    style: Style.roundInline,
                    initialValue: 0,
                    isNegativeValid: true,
                    canDecrement: true,
                    canReset: false,
                    dividerColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      var result = _rollTheDice();
                      if (result != null) {
                        setState(() => {
                              if (_diceStringController.text.isNotEmpty)
                                {
                                  _list.add(result),
                                  _modifierController.text = "",
                                  _diceCountController.text = "",
                                  _diceStringController.text = "",
                                  _selectedDie = null,
                                }
                            });
                      }
                    },
                    child: const Text('Roll!')),
              ],
            )
          ],
        ),
      );

  _setDiceText(DndDice dieType) {
    var txt = "";
    if (_diceCountController.text.isNotEmpty) {
      var count = int.tryParse(_diceCountController.text);
      if (count != null && count != 0) {
        txt = _diceCountController.text + ' ' + _getDieString(dieType);
      }
    } else {
      txt = _getDieString(dieType);
    }
    if (_modifierController.text.isNotEmpty) {
      var mod = int.tryParse(_modifierController.text);
      if (mod != null && mod > 0) {
        txt += ' +${_modifierController.text}';
      }
      if (mod != null && mod < 0) {
        txt += ' ${_modifierController.text}';
      }
    }
    setState(() => _diceStringController.text = txt);
  }

  String _getDieString(DndDice dieType) {
    _selectedDie = dieType;
    switch (dieType) {
      case DndDice.d4:
        return "d4";
      case DndDice.d6:
        return "d6";
      case DndDice.d8:
        return "d8";
      case DndDice.d10:
        return "d10";
      case DndDice.d12:
        return "d12";
      case DndDice.d20:
        return "d20";
      case DndDice.d100:
        return "d100";
    }
  }

  SizedBox _getD4result(int pips) {
    assert(pips > 0 && pips < 5);
    switch (pips) {
      case 1:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d4one.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 2:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d4two.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 3:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d4three.png'),
                color: Theme.of(context).colorScheme.onSurface));
      default:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d4four.png'),
                color: Theme.of(context).colorScheme.onSurface));
    }
  }

  SizedBox _getD6result(int pips) {
    assert(pips > 0 && pips < 7);
    switch (pips) {
      case 1:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d6one.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 2:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d6two.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 3:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d6three.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 4:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d6four.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 5:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d6five.png'),
                color: Theme.of(context).colorScheme.onSurface));
      default:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d6six.png'),
                color: Theme.of(context).colorScheme.onSurface));
    }
  }

  SizedBox _getD8result(int pips) {
    assert(pips > 0 && pips < 9);
    switch (pips) {
      case 1:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d8one.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 2:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d8two.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 3:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d8three.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 4:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d8four.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 5:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d8five.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 6:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d8six.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 7:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d8seven.png'),
                color: Theme.of(context).colorScheme.onSurface));
      default:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d8eight.png'),
                color: Theme.of(context).colorScheme.onSurface));
    }
  }

  SizedBox _getD10result(int pips) {
    assert(pips > 0 && pips < 11);
    switch (pips) {
      case 1:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d10one.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 2:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d10two.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 3:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d10three.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 4:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d10four.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 5:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d10five.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 6:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d10six.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 7:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d10seven.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 8:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d10eight.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 9:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d10nine.png'),
                color: Theme.of(context).colorScheme.onSurface));
      default:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d10ten.png'),
                color: Theme.of(context).colorScheme.onSurface));
    }
  }

  SizedBox _getD12result(int pips) {
    assert(pips > 0 && pips < 13);
    switch (pips) {
      case 1:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12one.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 2:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12two.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 3:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12three.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 4:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12four.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 5:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12five.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 6:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12six.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 7:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12seven.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 8:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12eight.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 9:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12nine.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 10:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12ten.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 11:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12eleven.png'),
                color: Theme.of(context).colorScheme.onSurface));
      default:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12twelve.png'),
                color: Theme.of(context).colorScheme.onSurface));
    }
  }

  SizedBox _getD20result(int pips) {
    assert(pips > 0 && pips < 21);
    switch (pips) {
      case 1:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20one.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 2:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20two.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 3:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20three.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 4:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20four.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 5:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20five.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 6:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20six.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 7:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20seven.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 8:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20eight.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 9:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20nine.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 10:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20ten.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 11:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20eleven.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 12:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d12twelve.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 13:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20thirteen.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 14:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20fourteen.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 15:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20fifteen.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 16:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20sixteen.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 17:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20seventeen.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 18:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20eighteen.png'),
                color: Theme.of(context).colorScheme.onSurface));
      case 19:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20nineteen.png'),
                color: Theme.of(context).colorScheme.onSurface));
      default:
        return SizedBox(
            height: 48,
            width: 48,
            child: Image(
                image: const AssetImage('assets/icons/d20twenty.png'),
                color: Theme.of(context).colorScheme.onSurface));
    }
  }

  Widget? _rollTheDice({bool? advantage}) {
    if (_selectedDie == null) return null;
    int modifier = int.tryParse(_modifierController.text) ?? 0;
    int numberOfDice = int.tryParse(_diceCountController.text) ?? 1;
    List<Dice> dicePool = [];
    Dice? die;
    RollResult rollResult;
    switch (_selectedDie) {
      case DndDice.d4:
        die = Dice(6, modifier: modifier, numberOfDice: numberOfDice);
        break;
      case DndDice.d6:
        die = Dice(6, modifier: modifier, numberOfDice: numberOfDice);
        break;
      case DndDice.d8:
        die = Dice(8, modifier: modifier, numberOfDice: numberOfDice);
        break;
      case DndDice.d10:
        die = Dice(10, modifier: modifier, numberOfDice: numberOfDice);
        break;
      case DndDice.d12:
        die = Dice(12, modifier: modifier, numberOfDice: numberOfDice);
        break;
      case DndDice.d20:
        die = Dice(20, modifier: modifier, numberOfDice: numberOfDice);
        break;
      case DndDice.d100:
        die = Dice(100, modifier: modifier, numberOfDice: numberOfDice);
        break;
      default:
        break;
    }
    if (die != null) {
      if (advantage != null) {
        if (advantage) {
          dicePool.add(die);
          dicePool.add(die);
        } else {
          dicePool.add(die);
          dicePool.add(die);
        }
      } else {
        dicePool.add(die);
      }
    }
    rollResult = Dnd5eRuleSet().roll(dicePool);
    if (_selectedDie == DndDice.d4 ||
        _selectedDie == DndDice.d6 ||
        _selectedDie == DndDice.d8 ||
        _selectedDie == DndDice.d10 ||
        _selectedDie == DndDice.d12 ||
        _selectedDie == DndDice.d20) {
      String mod = '';
      if (modifier < 0) {
        mod = '$modifier';
      } else if (modifier > 0) {
        mod = '+$modifier';
      }

      var parts = <Widget>[];
      parts.add(Text(
        'Sum: ${rollResult.result} / Detail: ',
        style: const TextStyle(
          fontSize: 20,
        ),
      ));
      for (var i = 0; i < rollResult.rolls.length; i++) {
        if (i > 0) parts.add(const SizedBox(width: 4));
        if (_selectedDie == DndDice.d4) {
          parts.add(_getD4result(rollResult.rolls[i]));
        }
        if (_selectedDie == DndDice.d6) {
          parts.add(_getD6result(rollResult.rolls[i]));
        }
        if (_selectedDie == DndDice.d8) {
          parts.add(_getD8result(rollResult.rolls[i]));
        }
        if (_selectedDie == DndDice.d10) {
          parts.add(_getD10result(rollResult.rolls[i]));
        }
        if (_selectedDie == DndDice.d12) {
          parts.add(_getD12result(rollResult.rolls[i]));
        }
        if (_selectedDie == DndDice.d20) {
          parts.add(_getD20result(rollResult.rolls[i]));
        }
      }
      parts.add(const SizedBox(width: 4));
      parts.add(Text(
        mod,
        style: const TextStyle(
          fontSize: 20,
        ),
      ));
      return Row(
        children: parts,
      );
    }
    var resultString =
        'Sum: ${Dnd5eRuleSet().prettyPrintResult(rollResult)} / Detail: ${Dnd5eRuleSet().prettyPrintResultDetails(rollResult)}';
    return Text(
      resultString,
      style: const TextStyle(
        fontSize: 20,
      ),
    );
  }
}

enum DndDice { d4, d6, d8, d10, d12, d20, d100 }
