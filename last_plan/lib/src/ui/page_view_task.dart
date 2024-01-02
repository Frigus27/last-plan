import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:last_plan/main.dart';
import 'package:provider/provider.dart';
import 'basic_widgets.dart';
import 'project_widgets.dart';
import 'package:last_plan/src/core/project.dart';

// ignore: library_private_types_in_public_api
GlobalKey<_PageViewTaskState> keyPageViewTaskState = GlobalKey();

Route createRouteToPageViewTask(Project project) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PageViewTask(
      project: project,
      key: keyPageViewTaskState,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class PageViewTask extends StatefulWidget {
  const PageViewTask({super.key, required this.project});

  final Project project;

  @override
  State<PageViewTask> createState() => _PageViewTaskState();
}

class _PageViewTaskState extends State<PageViewTask> {
  bool refresher = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            PageCaption(caption: widget.project.name),
            BoxedCard(
              caption: 'Overview',
              widthFactor: .9,
              child: ViewProjectOverview(
                project: widget.project,
              ),
            ),
            Row(
              children: [
                const Expanded(
                  child: SectionCaptionText(text: 'Checkpoints'),
                ),
                ElevatedButton(
                    onPressed: () {
                      functionViewTasksNewCheckpoint(context);
                      Provider.of<MyAppState>(context, listen: false).refresh();
                    },
                    child: const Text('New Checkpoint')),
                const SizedBox(
                  width: 40,
                ),
              ],
            ),
            for (int i = 0; i < widget.project.subtasks.length; i++)
              CardProjectCheckpointView(
                subtask: widget.project.subtasks[i],
                project: widget.project,
              ),
            const SizedBox(
              height: 40,
            ),
          ],
        ));
  }

  functionViewTasksNewCheckpoint(BuildContext context) async {
    TextEditingController c1 = TextEditingController();
    TextEditingController c2 = TextEditingController();
    TextEditingController c3 = TextEditingController();
    late Task newTask;

    bool? isOk = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Checkpoint'),
          content: SizedBox(
            height: 250,
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: c1,
                    decoration: const InputDecoration(
                      hintText: 'Enter checkpoint name here.',
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: c2,
                    decoration: const InputDecoration(
                      hintText: 'Enter checkpoint duration here.',
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: c3,
                    decoration: const InputDecoration(
                      hintText: 'Enter checkpoint budget here.',
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (c3.text.isNotEmpty &
                    c2.text.isNotEmpty &
                    c1.text.isNotEmpty) {
                  newTask = Task(
                    name: c1.text,
                    budget: double.parse(c3.text),
                    budgetLeft: double.parse(c3.text),
                    duration: int.parse(c2.text),
                    durationLeft: int.parse(c2.text),
                  );
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (isOk == true) {
      // ignore: use_build_context_synchronously
      Provider.of<MyAppState>(context, listen: false)
          .addCheckpointToProject(widget.project, newTask);
      refresh();
    }
  }

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
}
