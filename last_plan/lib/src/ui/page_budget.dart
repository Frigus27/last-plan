import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:last_plan/main.dart';
import 'package:last_plan/src/ui/basic_widgets.dart';
import 'package:provider/provider.dart';

final GlobalKey<_CardBudgetOverviewState> keyCardBudgetOverviewState =
    GlobalKey();

final GlobalKey<_ViewBudgetSpentHistoryState> keyViewBudgetSpentHistoryState =
    GlobalKey();

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ListView(children: [
        PageCaption(caption: 'Budget'),
        CardBudgetOverview(
          key: keyCardBudgetOverviewState,
        ),
        SizedBox(height: 20),
        CardBudgetSpentHistory(),
      ]),
    ));
  }
}

class CardBudgetOverview extends StatefulWidget {
  CardBudgetOverview({super.key});

  @override
  State<CardBudgetOverview> createState() => _CardBudgetOverviewState();
}

class _CardBudgetOverviewState extends State<CardBudgetOverview> {
  bool refresher = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {
      refresher = !refresher;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppState>(context, listen: false);
    final todayBudget = provider.todayBudget;
    final todayBudgetUsed = provider.todayBudgetUsed;
    final totalBudget = provider.totalBudget;
    final totalBudgetLeft = provider.totalBudgetLeft;

    return BoxedCard(
      caption: "Currency Overview",
      actions: [
        ButtonBudgetAddExpense(),
        SizedBox(
          width: 20,
        ),
        ButtonBudgetAddBudget(),
      ],
      child: Column(
        children: [
          Row(
            children: [
              TileBudgetCurrencyView(
                  caption: 'Total Budget',
                  content: totalBudget.toStringAsFixed(2)),
              TileBudgetCurrencyView(
                  caption: 'Today Budget',
                  content: todayBudget.toStringAsFixed(2)),
            ],
          ),
          Row(
            children: [
              TileBudgetCurrencyView(
                  caption: 'Total Remain',
                  content: (totalBudgetLeft + 0.005).toStringAsFixed(2)),
              TileBudgetCurrencyView(
                  caption: 'Today Remain',
                  content: (todayBudget - todayBudgetUsed + 0.005)
                      .toStringAsFixed(2)),
            ],
          ),
        ],
      ),
    );
  }
}

class ButtonBudgetAddExpense extends StatelessWidget {
  const ButtonBudgetAddExpense({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        functionCreateNewTask(context);
      },
      child: Text("Add Expense"),
    );
  }

  void functionCreateNewTask(BuildContext context) async {
    TextEditingController c1 = TextEditingController();
    TextEditingController c2 = TextEditingController();
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add new Expense'),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: c1,
                    decoration: InputDecoration(
                      hintText: 'Enter new expense here.',
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: c2,
                    decoration: InputDecoration(
                      hintText: 'Enter budget here.',
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (c1.text.isNotEmpty & c2.text.isNotEmpty) {
                  Provider.of<MyAppState>(context, listen: false)
                      .addExpense(c1.text, c2.text);
                  Provider.of<MyAppState>(context, listen: false)
                      .payBudget(double.parse(c2.text));
                  keyCardBudgetOverviewState.currentState?.refresh();
                  keyViewBudgetSpentHistoryState.currentState?.refresh();
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class ButtonBudgetAddBudget extends StatelessWidget {
  const ButtonBudgetAddBudget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController c1 = TextEditingController();
    return ElevatedButton(
      onPressed: () async {
        double? budget = await showDialog<double>(
          context: context,
          builder: (context) {
            return AlertDialog(
              actions: [
                TextButton(
                  onPressed: () {
                    if (c1.text.isNotEmpty) {
                      Navigator.of(context).pop(double.parse(c1.text));
                    }
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(-1.0);
                  },
                  child: const Text('Cancel'),
                ),
              ],
              title: Text('Add budgets'),
              content: TextField(
                controller: c1,
                decoration: InputDecoration(
                  hintText: 'Enter your extra budget.',
                ),
              ),
            );
          },
        );
        if (budget != null) {
          if (budget > 0) {
            Provider.of<MyAppState>(context, listen: false).addToBudget(budget);
            keyCardBudgetOverviewState.currentState?.refresh();
          }
        }
      },
      child: Text("Add Budget"),
    );
  }
}

class TileBudgetCurrencyView extends StatelessWidget {
  const TileBudgetCurrencyView(
      {super.key, required this.caption, required this.content});

  final String caption;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styleTitle = theme.textTheme.titleMedium?.copyWith();
    final styleDisplay = theme.textTheme.bodyLarge?.copyWith();
    return Expanded(
      child: BoxedCard(
        widthFactor: .9,
        padding: 8,
        caption: caption,
        style: styleTitle,
        align: Alignment.topCenter,
        captionAlign: TextAlign.center,
        child: Text(style: styleDisplay, content),
      ),
    );
  }
}

class CardBudgetSpentHistory extends StatelessWidget {
  const CardBudgetSpentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return BoxedCard(
      caption: "Recent Spent History",
      child: ViewBudgetSpentHistory(
        key: keyViewBudgetSpentHistoryState,
      ),
    );
  }
}

class ViewBudgetSpentHistory extends StatefulWidget {
  const ViewBudgetSpentHistory({super.key});

  @override
  State<ViewBudgetSpentHistory> createState() => _ViewBudgetSpentHistoryState();
}

class _ViewBudgetSpentHistoryState extends State<ViewBudgetSpentHistory> {
  bool refresher = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {
      refresher = !refresher;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentSpent =
        Provider.of<MyAppState>(listen: false, context).recentBudgetSpent;
    return Column(
      children: [
        for (var r in recentSpent)
          Card(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.background,
              child: ListTile(
                leading: Icon(
                  Icons.task_outlined,
                ),
                title: Text('${r.taskName}: ${r.budgetSpent}'),
                trailing: Icon(Icons.more_vert),
              ),
            ),
          ),
      ],
    );
  }
}
