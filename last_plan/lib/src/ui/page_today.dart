import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:last_plan/main.dart';
import 'package:last_plan/src/ui/basic_widgets.dart';
import 'package:provider/provider.dart';

import '../core/project.dart';
import '../core/doc.dart';

// ignore: library_private_types_in_public_api
GlobalKey<_ViewTodayRoutineState> keyViewTodayRoutineState = GlobalKey();
// ignore: library_private_types_in_public_api
GlobalKey<_ViewTodayRecentProjectState> keyViewTodayRecentProjectState =
    GlobalKey();

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppState>(context, listen: false);
    if (!provider.inited) {
      provider.init();
    }
    return Scaffold(
      body: Center(
          child: ListView(
        children: const [
          PageCaption(caption: "Today"),
          CardTodayRoutine(),
          SizedBox(height: 20),
          CardTodayRecentProjects(),
          SizedBox(height: 20),
        ],
      )),
    );
  }
}

class CardTodayRecentProjects extends StatelessWidget {
  const CardTodayRecentProjects({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BoxedCard(
      caption: "Checkpoints in Recent Projects",
      widthFactor: .8,
      child: ViewTodayRecentProject(
        key: keyViewTodayRecentProjectState,
      ),
    );
  }
}

class ViewTodayRoutine extends StatefulWidget {
  const ViewTodayRoutine({
    super.key,
  });

  @override
  State<ViewTodayRoutine> createState() => _ViewTodayRoutineState();
}

class _ViewTodayRoutineState extends State<ViewTodayRoutine> {
  bool refresher = false;
  @override
  Widget build(BuildContext context) {
    final todayTasks =
        Provider.of<MyAppState>(context, listen: false).getTodayTasks();
    return Column(children: [
      for (var t in todayTasks.routines)
        Card(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.background,
            child: ListTile(
              leading: const Icon(
                Icons.coffee,
                color: Colors.brown,
              ),
              title: Text(t.name),
              trailing: ButtonTodayCommitRoutine(
                task: t,
              ),
            ),
          ),
        ),
    ]);
  }

  void refresh() {
    setState(() {
      refresher = !refresher;
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }
}

class ButtonTodayCommitRoutine extends StatelessWidget {
  const ButtonTodayCommitRoutine({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    TextEditingController c1 = TextEditingController();
    return ElevatedButton(
      onPressed: () async {
        bool? result = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    const Text(
                      'Enter the budget you have spent today on this event.',
                    ),
                    Expanded(
                      child: TextField(
                        controller: c1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Enter your budget spent here.',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: const Text('Commit The Event'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (c1.text.isNotEmpty) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        if (result == true) {
          // ignore: use_build_context_synchronously
          Provider.of<MyAppState>(context, listen: false).commitTodayEvent(
            task,
            double.parse(c1.text),
          );
          keyViewTodayRoutineState.currentState?.refresh();
        }
      },
      child: const Text('Commit'),
    );
  }
}

class CardTodayRoutine extends StatelessWidget {
  const CardTodayRoutine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BoxedCard(
      caption: "Routine",
      widthFactor: .8,
      child: ViewTodayRoutine(
        key: keyViewTodayRoutineState,
      ),
    );
  }
}

class ViewTodayRecentProject extends StatefulWidget {
  const ViewTodayRecentProject({
    super.key,
  });

  @override
  State<ViewTodayRecentProject> createState() => _ViewTodayRecentProjectState();
}

class _ViewTodayRecentProjectState extends State<ViewTodayRecentProject> {
  bool refresher = false;
  @override
  Widget build(BuildContext context) {
    final todayTasks =
        Provider.of<MyAppState>(context, listen: false).getTodayTasks();

    return Column(children: [
      for (var t in todayTasks.projectSubtasks)
        Card(
          child: ColoredBox(
            color: Theme.of(context).colorScheme.background,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.access_time,
                    color: Colors.blue,
                  ),
                  title: Text('${t.projectName} - ${t.subtask.name}'),
                  trailing: ButtonTodayFinishRecentProject(
                    task: t.subtask,
                  ),
                ),
              ],
            ),
          ),
        ),
    ]);
  }

  void refresh() {
    setState(() {
      refresher = !refresher;
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }
}

class ButtonTodayFinishRecentProject extends StatelessWidget {
  const ButtonTodayFinishRecentProject({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    TextEditingController c1 = TextEditingController();
    return ElevatedButton(
      onPressed: () async {
        bool? result = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    const Text(
                      'Enter the budget you have spent today on this event.',
                    ),
                    Expanded(
                      child: TextField(
                        controller: c1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Enter your budget spent here.',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: const Text('Complete the Checkpoint'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (c1.text.isNotEmpty) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        if (result == true) {
          // ignore: use_build_context_synchronously
          Provider.of<MyAppState>(context, listen: false).commitTodayEvent(
            task,
            double.parse(c1.text),
          );
          keyViewTodayRecentProjectState.currentState?.refresh();
        }
      },
      child: const Text('Complete'),
    );
  }
}
// Widgets

/*
class CardTodayOverview extends StatelessWidget {
  const CardTodayOverview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium;
    final todayBudgetUsed =
        Provider.of<MyAppState>(listen: false, context).todayBudgetUsed;
    final todayBudgetTotal =
        Provider.of<MyAppState>(listen: false, context).todayBudget;

    return BoxedCard(
      caption: 'Today Overview',
      widthFactor: .8,
      child: Row(
        children: [],
      ),
    );
  }
}

*/