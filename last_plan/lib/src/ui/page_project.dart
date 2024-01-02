import 'package:flutter/services.dart';
import 'package:last_plan/main.dart';
import 'package:last_plan/src/core/project.dart';
import 'package:flutter/material.dart';
import 'package:last_plan/src/ui/basic_widgets.dart';
import 'package:last_plan/src/ui/page_view_task.dart';
import 'project_widgets.dart';
import 'package:provider/provider.dart';

// ignore: constant_identifier_names
enum SelectedTaskType { Routine, Project, Cancel }

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
        body: Center(
            child: ListView(
          children: [
            const PageCaption(
              caption: 'Tasks',
            ),
            const SectionCaptionText(text: 'Routines'),
            for (var r in appState.routines)
              CardProjectRoutineView(
                routine: r,
              ),
            const SectionCaptionText(text: 'Projects'),
            for (var p in appState.projects)
              CardProjectEachProject(
                project: p,
              ),
          ],
        )),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            functionCreateNewTask(context);
          },
          label: const Text('New Task'),
          icon: const Icon(Icons.add),
        ));
  }

  void functionCreateNewTask(BuildContext context) async {
    SelectedTaskType? idx = await showDialog<SelectedTaskType>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Task'),
          content: const Text('What kind of task do you want to create?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(SelectedTaskType.Routine);
              },
              child: const Text('Routine'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(SelectedTaskType.Project);
              },
              child: const Text('Project'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(SelectedTaskType.Cancel);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (idx == SelectedTaskType.Routine) {
      TextEditingController c1 = TextEditingController();
      TextEditingController c2 = TextEditingController();
      await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create Routine'),
            content: SizedBox(
              height: 150,
              child: Column(
                children: [
                  const Text('Enter the name and the budget of the routine.'),
                  Expanded(
                    child: TextField(
                      controller: c1,
                      decoration: InputDecoration(
                        hintText: 'Enter name here.',
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
                child: Text('Go!'),
                onPressed: () {
                  if (c1.text.isNotEmpty & c2.text.isNotEmpty) {
                    Provider.of<MyAppState>(context, listen: false)
                        .addRoutine(c1.text, c2.text);
                    Navigator.of(context).pop(true);
                  }
                },
              ),
            ],
          );
        },
      );
    } else if (idx == SelectedTaskType.Project) {
      TextEditingController c1 = TextEditingController();
      await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create Empty Project'),
            content: SizedBox(
              height: 120,
              child: Column(
                children: [
                  Text('Enter the name of the project.'),
                  TextField(
                    controller: c1,
                    decoration: InputDecoration(
                      hintText: 'Enter name here.',
                    ),
                  ),
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
                child: Text('Go!'),
                onPressed: () {
                  Provider.of<MyAppState>(context, listen: false)
                      .addEmptyProject(c1.text);
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class CardProjectEachProject extends StatelessWidget {
  const CardProjectEachProject({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BoxedCard(
        caption: project.name,
        widthFactor: .9,
        style: theme.textTheme.bodyLarge?.copyWith(),
        useDivideLine: true,
        child: ViewProjectEachProject(
          project: project,
        ),
        actions: [
          ButtonProjectViewDetails(project: project),
          const SizedBox(
            width: 8,
          ),
          ButtonProjectRemoveProject(theme: theme, project: project),
        ]);
  }
}

class ButtonProjectRemoveProject extends StatelessWidget {
  const ButtonProjectRemoveProject({
    super.key,
    required this.theme,
    required this.project,
  });

  final ThemeData theme;
  final Project project;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(
          theme.colorScheme.error,
        ),
      ),
      onPressed: () async {
        bool? doRemove = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Warning"),
              content: Text("Do you really want to remove the term?"),
              actions: <Widget>[
                TextButton(
                  child: Text("Yes"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        );
        if (doRemove != false) {
          Provider.of<MyAppState>(context, listen: false)
              .removeProject(project);
        }
      },
      child: const Text('Remove'),
    );
  }
}

class ButtonProjectViewDetails extends StatelessWidget {
  const ButtonProjectViewDetails({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(createRouteToPageViewTask(project));
      },
      child: const Text('Details'),
    );
  }
}

class ViewProjectEachProject extends StatelessWidget {
  const ViewProjectEachProject({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ViewProjectOverview(
          project: project,
        ),
      ],
    );
  }
}

class CardProjectRoutineView extends StatelessWidget {
  final Task routine;

  const CardProjectRoutineView({
    super.key,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recRoutine = getStateOfRoutine(routine);
    return BoxedCard(
      widthFactor: .9,
      caption: routine.name,
      child: Row(
        children: [
          Expanded(
            child: Text('Budget: ', style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            child: Text('${routine.budget} ', style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            child: Text('Current State: ', style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  '${recRoutine.tip} ',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: recRoutine.color,
                  ),
                ),
                recRoutine.icon,
              ],
            ),
          ),
        ],
      ),
      actions: [ButtonProjectRemoveRoutine(theme: theme, task: routine)],
    );
  }
}

class ButtonProjectRemoveRoutine extends StatelessWidget {
  const ButtonProjectRemoveRoutine({
    super.key,
    required this.theme,
    required this.task,
  });

  final ThemeData theme;
  final Task task;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(
          theme.colorScheme.error,
        ),
      ),
      onPressed: () async {
        bool? doRemove = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Warning"),
              content: Text("Do you really want to remove the routine?"),
              actions: <Widget>[
                TextButton(
                  child: Text("Yes"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        );
        if (doRemove != false) {
          Provider.of<MyAppState>(context, listen: false).removeRoutine(task);
        }
      },
      child: const Text('Remove'),
    );
  }
}
