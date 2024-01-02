import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/ui/page_today.dart';
import 'src/ui/page_budget.dart';
import 'src/ui/page_project.dart';
import 'src/core/project.dart';

import 'src/core/doc.dart';

void main() {
  runApp(const MyApp());
}

GlobalKey<_MyHomePageState> keyHomepage = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Paradigm: DDL',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: MyHomePage(
          title: 'Paradigm: DDL',
          key: keyHomepage,
        ),
      ),
    );
  }
}

typedef TypeEasySubtask = ({
  Task subtask,
  String projectName,
});

typedef TypeEasyBudgetSpent = ({
  double budgetSpent,
  String taskName,
});

typedef TypePageTodayRecentTasks = ({
  List<Task> routines,
  List<TypeEasySubtask> projectSubtasks
});

class MyAppState extends ChangeNotifier {
  bool inited = false;

  void init() async {
    inited = true;
    final message = await readAppMessage();
    print(jsonEncode(message?.toJson()));
    if (message != null) {
      projects = message.projects;
      routines = message.routines;
      totalBudget = message.totalBudget;
      totalBudgetLeft = message.totalBudgetLeft;
      todayBudgetUsed = message.todayBudgetUsed;
    }
    keyHomepage.currentState?.refresh();
    refresh();
  }

  List<Project> projects =
      []; /* = <Project>[
    Project(
      name: 'Assignment D - USTC Programming Class',
      subtasks: [
        Task(
          name: 'UI Design',
          duration: 3,
          budget: 10,
          budgetLeft: 0,
          passed: true,
        ),
        Task(
          name: 'Implementation',
          duration: 7,
          budget: 10,
          budgetLeft: 0,
          passed: false,
        ),
      ],
      startDate: DateTime(2023, 12, 10),
    ),
    Project(
      name: 'CET-4 Preparation',
      subtasks: [
        Task(
          name: 'Word Recitation',
          duration: 30,
          passed: true,
          budget: 0,
          budgetLeft: 0,
        ),
        Task(
          name: 'Self Testing',
          duration: 7,
          passed: false,
          budgetLeft: 0,
          budget: 0,
        ),
        Task(
          name: 'Soliciting for God\'s Goodness',
          duration: 1,
          budget: 0,
          budgetLeft: 0,
          passed: false,
        ),
      ],
      startDate: DateTime(2023, 11, 10),
    )
  ];*/

  double todayBudgetUsed = 0/*= 0*/;
  double totalBudget = 0 /* = 1145.14*/;
  double totalBudgetLeft = 0 /* = 1145.14*/;

  Queue<TypeEasyBudgetSpent> recentBudgetSpent = Queue<TypeEasyBudgetSpent>();

  late List<Task> routines =
      [] /* = <Task>[
    Task(
      name: '8348 Americano',
      duration: 1,
      budget: 12,
    ),
  ]*/
      ;

  void removeProject(Project project) {
    projects.remove(project);
    refresh();
  }

  void removeRoutine(Task task) {
    routines.remove(task);
    refresh();
  }

  void addRoutine(String text, String text2) {
    routines.add(Task(name: text, duration: 1, budget: double.parse(text2)));
    refresh();
  }

  void addExpense(String text, String text2) {
    double budgetSpent = double.parse(text2);
    if (budgetSpent >= 0.01) {
      recentBudgetSpent.addFirst((
        budgetSpent: budgetSpent,
        taskName: text,
      ));
      if (recentBudgetSpent.length > 5) {
        recentBudgetSpent.removeLast();
      }
    }
    refresh();
  }

  void addCheckpointToProject(Project project, Task task) {
    project.subtasks.add(task);
    refresh();
  }

  void refresh() {
    writeAppMessage(
      AppMessage(
        projects: projects,
        routines: routines,
        todayBudgetUsed: todayBudgetUsed,
        totalBudget: totalBudget,
        totalBudgetLeft: totalBudgetLeft,
      ),
    );
    notifyListeners();
  }

  void addEmptyProject(String text) {
    projects.add(
      Project(
        name: text,
        subtasks: <Task>[],
        startDate: DateTime.now(),
      ),
    );
    refresh();
  }

  void removeCheckpoint(Project project, Task task) {
    project.subtasks.remove(task);
    refresh();
  }

  void completeCheckpoint(Project project, Task task) {
    task.passed = true;
    refresh();
  }

  TypePageTodayRecentTasks getTodayTasks() {
    TypePageTodayRecentTasks tasksToday = (
      routines: <Task>[],
      projectSubtasks: <TypeEasySubtask>[],
    );
    for (var t in routines) {
      if (!t.passed) {
        tasksToday.routines.add(t);
      }
    }
    for (var p in projects) {
      for (var t in p.subtasks) {
        if (!t.passed) {
          tasksToday.projectSubtasks.add((
            projectName: p.name,
            subtask: t,
          ));
          break;
        }
      }
    }

    return tasksToday;
  }

  get todayAllTasks {
    TypePageTodayRecentTasks tasksToday = (
      routines: <Task>[],
      projectSubtasks: <TypeEasySubtask>[],
    );
    for (var t in routines) {
      tasksToday.routines.add(t);
    }
    for (var p in projects) {
      for (var t in p.subtasks) {
        if (!t.passed) {
          tasksToday.projectSubtasks.add((
            projectName: p.name,
            subtask: t,
          ));
          break;
        }
      }
    }

    return tasksToday;
  }

  void payBudget(double budgetSpent) {
    todayBudgetUsed += budgetSpent;
    totalBudgetLeft -= budgetSpent;
  }

  void commitTodayEvent(Task task, double budgetSpent) {
    payBudget(budgetSpent);
    task.budgetLeft -= budgetSpent;
    task.passed = true;
    addExpense(task.name, budgetSpent.toString());

    refresh();
  }

  get todayBudget {
    final todayTasks = todayAllTasks;
    double budget = 0;
    for (var r in todayTasks.routines) {
      budget += r.budget;
    }
    for (var t in todayTasks.projectSubtasks) {
      if (t.subtask.durationLeft > 0) {
        budget += t.subtask.budgetLeft / t.subtask.durationLeft;
      }
    }
    return budget;
  }

  void addToBudget(double budget) {
    totalBudget += budget;
    totalBudgetLeft += budget;
    refresh();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIdx = 1;

  void refresh() {
    changePage(1);
  }

  void changePage(int idx) {
    setState(() {
      currentPageIdx = idx;
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Widget page;
    if (Provider.of<MyAppState>(listen: false, context).inited == false) {
      page = const PageLoading();
    } else {
      switch (currentPageIdx) {
        case 0:
          page = const ProjectPage();
          break;
        case 1:
          page = const TodayPage();
          break;
        case 2:
          page = const BudgetPage();
          break;
        default:
          throw UnimplementedError('Fuck you');
      }
    }

    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Container(child: page)),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.access_time_outlined), label: "Tasks"),
          NavigationDestination(icon: Icon(Icons.today), label: "Today"),
          NavigationDestination(
            icon: Icon(Icons.money_off_rounded),
            label: "Budget",
          ),
        ],
        selectedIndex: currentPageIdx,
        indicatorColor: theme.highlightColor,
        backgroundColor: theme.colorScheme.background,
        onDestinationSelected: changePage,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PageLoading extends StatelessWidget {
  const PageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<MyAppState>(context, listen: false).init();
    return const Scaffold(
      body: Center(child: Text('Loading...')),
    );
  }
}
