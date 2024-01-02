import 'dart:core';

enum TaskState { inControl, beCautious, hurryUp, complete }

class Task {
  Task({
    required this.name,
    this.description = '',
    required this.duration,
    this.durationLeft = 0,
    required this.budget,
    this.budgetLeft = 0,
    this.passed = false,
  });

  final String name;
  final String description;
  final int duration;
  final double budget;
  int durationLeft;
  double budgetLeft;
  bool passed;

  get durationPercentage {
    if (duration == 0)
      return 1.0;
    else
      return durationLeft / duration;
  }

  get budgetPercentage {
    if (budget == 0)
      return 1.0;
    else
      return budgetLeft / budget;
  }

  get taskState {
    if (passed) {
      return TaskState.complete;
    } else if (durationPercentage > .8) {
      return TaskState.inControl;
    } else if (durationPercentage > .4) {
      return TaskState.beCautious;
    } else {
      return TaskState.hurryUp;
    }
  }

  Task.fromJson(Map<String, dynamic> json)
      : budget = json['Budget'] as double,
        budgetLeft = json['BudgetLeft'] as double,
        duration = json['Duration'] as int,
        durationLeft = json['DurationLeft'] as int,
        description = json['Description'] as String,
        name = json['Name'] as String,
        passed = json['isPassed'] as bool;

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Description': description,
        'Budget': budget,
        'BudgetLeft': budgetLeft,
        'Duration': duration,
        'DurationLeft': durationLeft,
        'isPassed': passed,
      };
}

class Project {
  String name;
  String description;
  List<Task> subtasks;
  DateTime startDate;

  Project({
    required this.name,
    required this.subtasks,
    this.description = '',
    required this.startDate,
  }) {
    _setDurationLeft();
  }

  Project.fromJson(Map<String, dynamic> json)
      : name = json['Name'] as String,
        description = json['Description'] as String,
        startDate = DateTime(
          json['StartDate']['Year'] as int,
          json['StartDate']['Month'] as int,
          json['StartDate']['Day'] as int,
        ),
        subtasks = <Task>[] {
    for (var s in json['Subtasks']) {
      subtasks.add(Task.fromJson(s));
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'Name': name,
      'Description': description,
      'StartDate': {
        'Year': startDate.year,
        'Month': startDate.month,
        'Day': startDate.day,
      },
      'Subtasks': <Map<String, dynamic>>[]
    };

    for (var s in subtasks) {
      json['Subtasks'].add(s.toJson());
    }

    return json;
  }

  void _setDurationLeft() {
    int dist = DateTime.now().difference(startDate).inDays;

    for (var s in subtasks) {
      if (s.duration > dist) {
        s.durationLeft = s.duration - dist;
        dist = 0;
      } else {
        s.durationLeft = 0;
        dist -= s.duration;
      }
    }
  }

  get duration {
    int sum = 0;
    for (var s in subtasks) {
      sum += s.duration;
    }
    return sum;
  }

  get budget {
    double sum = 0;
    for (var s in subtasks) {
      sum += s.budget;
    }
    return sum;
  }

  get durationLeft {
    int sum = 0;
    for (var s in subtasks) {
      sum += s.durationLeft;
    }
    return sum;
  }

  get budgetLeft {
    double sum = 0;
    for (var s in subtasks) {
      sum += s.budgetLeft;
    }
    return sum;
  }

  get durationPercentage {
    if (duration == 0)
      return 1.0;
    else
      return durationLeft / duration;
  }

  get budgetPercentage {
    if (budget == 0)
      return 1.0;
    else
      return budgetLeft / budget;
  }

  get progressPercentage {
    int total = 0, passedTotal = 0;
    for (var s in subtasks) {
      if (s.passed) {
        passedTotal += s.duration;
      }
      total += s.duration;
    }
    if (total == 0) {
      return 1.0;
    } else {
      return passedTotal / total;
    }
  }

  get passedPercentage {
    if (subtaskCount == 0) {
      return 1.0;
    } else {
      return passedCount / subtaskCount;
    }
  }

  get taskState {
    if (passedCount == subtaskCount) {
      return TaskState.complete;
    } else if (progressPercentage > .8) {
      return TaskState.inControl;
    } else if (progressPercentage > .4) {
      return TaskState.beCautious;
    } else {
      return TaskState.hurryUp;
    }
  }

  get passedCount {
    int sum = 0;
    for (var s in subtasks) {
      if (s.passed) {
        sum++;
      }
    }
    return sum;
  }

  get subtaskCount {
    return subtasks.length;
  }

  Task get currentCheckpoint {
    for (var s in subtasks) {
      if (!s.passed) {
        return s;
      }
    }
    return subtasks.last;
  }
}
