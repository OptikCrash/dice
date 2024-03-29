import 'dart:io';

import 'package:dice/extensions/numbers.dart';
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

  get _body => SingleChildScrollView(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: _list.length,
            itemBuilder: (context, index) => _list[index]),
      );

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
    _selectedDie = dieType;
    var txt = "";
    if (_diceCountController.text.isNotEmpty) {
      var count = int.tryParse(_diceCountController.text);
      if (count != null && count != 0) {
        txt = _diceCountController.text + ' ' + dieToString(dieType);
      }
    } else {
      txt = dieToString(dieType);
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

  Widget? _rollTheDice({bool? advantage}) {
    if (_selectedDie == null) return null;
    int modifier = int.tryParse(_modifierController.text) ?? 0;
    int numberOfDice = int.tryParse(_diceCountController.text) ?? 1;
    List<Dice> dicePool = [];
    Dice? die;
    RollResult rollResult;
    switch (_selectedDie) {
      case DndDice.d4:
        die = Dice(4, modifier: modifier, numberOfDice: numberOfDice);
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
    if (_selectedDie != null) {
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
        if (_selectedDie == DndDice.d100) {
          if (rollResult.rolls[i] == 100) {
            parts.add(_getDieIcon(DndDice.d10, 10));
            parts.add(_getDieIcon(DndDice.d100, 10));
          } else if (rollResult.rolls[i] > 10) {
            Iterable<int> digits = digitsOf(rollResult.rolls[i]);
            parts.add(_getDieIcon(DndDice.d100, digits.first));
            parts.add(_getDieIcon(DndDice.d10, digits.last));
          } else if (rollResult.rolls[i] == 10) {
            parts.add(_getDieIcon(DndDice.d100, 10));
            parts.add(_getDieIcon(DndDice.d10, 10));
          } else {
            parts.add(_getDieIcon(DndDice.d100, 10));
            parts.add(_getDieIcon(DndDice.d10, rollResult.rolls[i]));
          }
        } else {
          parts.add(_getDieIcon(_selectedDie!, rollResult.rolls[i]));
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

  SizedBox _getDieIcon(DndDice dieType, int rawRollResult) => SizedBox(
      height: 48,
      width: 48,
      child: Image(
          image: AssetImage(
              'assets/icons/${dieToString(dieType)}${rawRollResult.toWord()}.png'),
          color: Theme.of(context).colorScheme.onSurface));
}

enum DndDice { d4, d6, d8, d10, d12, d20, d100 }

String dieToString(DndDice dieType) {
  switch (dieType) {
    case DndDice.d4:
      return 'd4';
    case DndDice.d6:
      return 'd6';
    case DndDice.d8:
      return 'd8';
    case DndDice.d10:
      return 'd10';
    case DndDice.d12:
      return 'd12';
    case DndDice.d20:
      return 'd20';
    case DndDice.d100:
      return 'd100';
    default:
      return 'the die type is not compatible';
  }
}
