import 'package:flutter/material.dart';
import 'package:last_plan/src/core/project.dart';
import 'package:last_plan/src/ui/page_view_task.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'basic_widgets.dart';

class ViewProjectOverview extends StatelessWidget {
  const ViewProjectOverview({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Row(
        children: [
          Expanded(child: CardProjectStateView(project: project)),
          Expanded(child: CardProjectProgressView(project: project))
        ],
      ),
    );
  }
}

class CardProjectProgressView extends StatelessWidget {
  const CardProjectProgressView({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BoxedCard(
        caption: 'Progress',
        widthFactor: 1,
        style: theme.textTheme.titleLarge?.copyWith(),
        captionAlign: TextAlign.center,
        align: Alignment.topCenter,
        child: Row(
          children: [
            Expanded(
              child: CardProjectProgressWorkView(
                project: project,
              ),
            ),
            Expanded(
              child: CardProjectProgressDaysView(
                project: project,
              ),
            ),
          ],
        ));
  }
}

class CardProjectProgressDaysView extends StatelessWidget {
  const CardProjectProgressDaysView({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BoxedCard(
      caption: 'Days',
      widthFactor: 1,
      style: theme.textTheme.titleMedium?.copyWith(),
      captionAlign: TextAlign.center,
      align: Alignment.topCenter,
      child: Column(
        children: [
          CircularProgressIndicator(value: project.durationPercentage),
          const SizedBox(height: 8),
          Text('${project.durationLeft} days left')
        ],
      ),
    );
  }
}

class CardProjectProgressWorkView extends StatelessWidget {
  const CardProjectProgressWorkView({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    final percentage = project.progressPercentage;
    final theme = Theme.of(context);
    return BoxedCard(
      caption: 'Work',
      widthFactor: .95,
      style: theme.textTheme.titleMedium?.copyWith(),
      captionAlign: TextAlign.center,
      align: Alignment.topCenter,
      child: Column(
        children: [
          CircularProgressIndicator(value: percentage),
          const SizedBox(height: 8),
          Text('${(100 * percentage).truncate()}%')
        ],
      ),
    );
  }
}

typedef RecordOfState = ({String tip, Color color, Icon icon});

RecordOfState getStateOfProject(Project project) {
  String s;
  Color c;
  Icon icon;

  if (project.passedCount == project.subtaskCount) {
    s = 'Complete';
    c = Colors.green;
    icon = Icon(
      Icons.star,
      color: c,
    );
  } else if (project.taskState == TaskState.inControl) {
    s = 'In Control';
    c = Colors.green;
    icon = Icon(
      Icons.thumb_up,
      color: c,
    );
  } else if (project.taskState == TaskState.beCautious) {
    s = 'Be Cautious';
    c = Colors.orange;
    icon = Icon(
      Icons.info,
      color: c,
    );
  } else {
    s = 'Hurry Up';
    c = Colors.red;
    icon = Icon(
      Icons.warning,
      color: c,
    );
  }

  return (tip: s, color: c, icon: icon);
}

// I don't know how to use templates here
RecordOfState getStateOfTask(Task project) {
  String s;
  Color c;
  Icon icon;

  if (project.taskState == TaskState.complete) {
    s = 'Complete';
    c = Colors.green;
    icon = Icon(
      Icons.star,
      color: c,
    );
  } else if (project.taskState == TaskState.inControl) {
    s = 'In Control';
    c = Colors.green;
    icon = Icon(
      Icons.thumb_up,
      color: c,
    );
  } else if (project.taskState == TaskState.beCautious) {
    s = 'Be Cautious';
    c = Colors.orange;
    icon = Icon(
      Icons.info,
      color: c,
    );
  } else {
    s = 'Hurry Up';
    c = Colors.red;
    icon = Icon(
      Icons.warning,
      color: c,
    );
  }

  return (tip: s, color: c, icon: icon);
}

RecordOfState getStateOfRoutine(Task routine) {
  String s;
  Color c;
  Icon icon;

  if (routine.taskState == TaskState.complete) {
    s = 'Complete';
    c = Colors.green;
    icon = Icon(
      Icons.star,
      color: c,
    );
  } else {
    s = 'Not Done';
    c = Colors.red;
    icon = Icon(
      Icons.circle_notifications,
      color: c,
    );
  }

  return (tip: s, color: c, icon: icon);
}

class CardProjectStateView extends StatelessWidget {
  const CardProjectStateView({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recOfProjectState = getStateOfProject(project);
    return BoxedCard(
      caption: 'State',
      widthFactor: 1,
      style: theme.textTheme.titleLarge?.copyWith(),
      captionAlign: TextAlign.center,
      align: Alignment.topCenter,
      child: Column(children: [
        Row(
          children: [
            Expanded(
              child: Text('Current State: ', style: theme.textTheme.bodyLarge),
            ),
            Expanded(
              child: Row(
                children: [
                  Text(
                    recOfProjectState.tip,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: recOfProjectState.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  recOfProjectState.icon,
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child:
                  Text('Passed Checkpoint: ', style: theme.textTheme.bodyLarge),
            ),
            Expanded(
              child: Text(
                '${project.passedCount}/${project.subtaskCount}',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (project.passedPercentage),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child:
                  Text('Remaining Budget: ', style: theme.textTheme.bodyLarge),
            ),
            Expanded(
              child: Text('${project.budgetLeft}/${project.budget} ',
                  style: theme.textTheme.bodyLarge),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: project.budgetPercentage,
        ),
      ]),
    );
  }
}

class CardProjectCheckpointView extends StatelessWidget {
  const CardProjectCheckpointView({
    required this.subtask,
    required this.project,
    super.key,
  });

  final Task subtask;
  final Project project;

  @override
  Widget build(BuildContext context) {
    final recOfTask = getStateOfTask(subtask);
    final theme = Theme.of(context);
    return BoxedCard(
        widthFactor: .9,
        caption: subtask.name,
        actions: [
          if (!subtask.passed)
            ButtonProjectViewCompleteCheckpoint(
              theme: theme,
              task: subtask,
              project: project,
            ),
          ButtonProjectViewRemoveCheckpoint(
            theme: theme,
            task: subtask,
            project: project,
          ),
        ],
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Current State: ',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        recOfTask.tip,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: recOfTask.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      recOfTask.icon,
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Remaining Days: ',
                      style: theme.textTheme.bodyLarge),
                ),
                Expanded(
                  child: Text('${subtask.durationLeft}/${subtask.duration} ',
                      style: theme.textTheme.bodyLarge),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: subtask.durationPercentage,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Remaining Budget: ',
                      style: theme.textTheme.bodyLarge),
                ),
                Expanded(
                  child: Text('${subtask.budgetLeft}/${subtask.budget} ',
                      style: theme.textTheme.bodyLarge),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: subtask.budgetPercentage,
            ),
          ],
        ));
  }
}

class ButtonProjectViewRemoveCheckpoint extends StatelessWidget {
  const ButtonProjectViewRemoveCheckpoint({
    super.key,
    required this.theme,
    required this.task,
    required this.project,
  });

  final ThemeData theme;
  final Task task;
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
              content: Text("Do you really want to remove the checkpoint?"),
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
              .removeCheckpoint(project, task);
          keyPageViewTaskState.currentState?.refresh();
        }
      },
      child: const Text('Remove'),
    );
  }
}

class ButtonProjectViewCompleteCheckpoint extends StatelessWidget {
  const ButtonProjectViewCompleteCheckpoint({
    super.key,
    required this.theme,
    required this.task,
    required this.project,
  });

  final ThemeData theme;
  final Task task;
  final Project project;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(),
      onPressed: () async {
        bool? doRemove = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Warning"),
              content:
                  Text("Do you really want to mark the checkpoint complete?"),
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
              .completeCheckpoint(project, task);
          keyPageViewTaskState.currentState?.refresh();
        }
      },
      child: const Text('Complete'),
    );
  }
}
