import 'dart:convert';
import 'dart:io';
import 'package:last_plan/src/core/project.dart';
import 'package:path_provider/path_provider.dart';
import 'package:json_annotation/json_annotation.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<String> get _claimMyPath async {
  final localPath = await _localPath;
  var file = Directory('$localPath/Paradigm_DDL/');
  try {
    bool exists = await file.exists();
    if (!exists) {
      await file.create();
    }
  } catch (e) {
    print(e);
  }

  return file.path;
}

Future<File> get _saveFile async {
  final filePath = await _claimMyPath;
  return File('${filePath}data.json');
}

Future<File> writeAppMessage(AppMessage? message) async {
  final file = await _saveFile;

  // Write the file
  return file.writeAsString(jsonEncode(message?.toJson()));
}

Future<AppMessage?> readAppMessage() async {
  try {
    final file = await _saveFile;

    // Read the file
    final contents = await file.readAsString();

    if (contents.isEmpty) {
      return AppMessage(
        projects: [],
        routines: [],
        todayBudgetUsed: 0,
        totalBudget: 0,
        totalBudgetLeft: 0,
      );
    } else {
      return AppMessage.fromJson(jsonDecode(contents));
    }
  } catch (e) {
    // If encountering an error, return 0
    return AppMessage(
      projects: [],
      routines: [],
      todayBudgetUsed: 0,
      totalBudget: 0,
      totalBudgetLeft: 0,
    );
  }
}

@JsonSerializable()
class AppMessage {
  List<Project> projects;
  List<Task> routines;
  double todayBudgetUsed;
  double totalBudget;
  double totalBudgetLeft;

  AppMessage({
    required this.projects,
    required this.routines,
    required this.todayBudgetUsed,
    required this.totalBudget,
    required this.totalBudgetLeft,
  });

  AppMessage.fromJson(Map<String, dynamic> json)
      : projects = <Project>[],
        routines = <Task>[],
        todayBudgetUsed = json['TodayBudgetUsed'] as double,
        totalBudget = json['TotalBudget'],
        totalBudgetLeft = json['TotalBudgetLeft'] {
    for (var p in json['Projects']) {
      projects.add(Project.fromJson(p));
    }
    for (var r in json['Routines']) {
      routines.add(Task.fromJson(r));
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'TodayBudgetUsed': todayBudgetUsed,
      'TotalBudget': totalBudget,
      'TotalBudgetLeft': totalBudgetLeft,
      'Projects': <Map<String, dynamic>>[],
      'Routines': <Map<String, dynamic>>[],
    };

    for (var p in projects) {
      json['Projects'].add(p.toJson());
    }
    for (var r in routines) {
      json['Routines'].add(r.toJson());
    }

    return json;
  }
}

Future<File> writeEmptyMessage() async {
  final file = await _saveFile;

  // Write the file
  return file.writeAsString(jsonEncode(AppMessage(
    projects: [],
    routines: [],
    todayBudgetUsed: 0,
    totalBudget: 0,
    totalBudgetLeft: 0,
  ).toJson()));
}

Future<File> writeExampleMessage() async {
  final file = await _saveFile;

  return file.writeAsString(
      '{"TodayBudgetUsed":0.0,"TotalBudget":1145.14,"TotalBudgetLeft":1145.14,"Projects":[{"Name":"Assignment D - USTC Programming Class","Description":"","StartDate":{"Year":2023,"Month":12,"Day":10},"Subtasks":[{"Name":"UI Design","Description":"","Budget":10.0,"BudgetLeft":0.0,"Duration":3,"DurationLeft":0,"isPassed":true},{"Name":"Implementation","Description":"","Budget":10.0,"BudgetLeft":0.0,"Duration":5,"DurationLeft":0,"isPassed":false}]},{"Name":"CET-4 Preparation","Description":"","StartDate":{"Year":2023,"Month":11,"Day":10},"Subtasks":[{"Name":"Word Recitation","Description":"","Budget":0.0,"BudgetLeft":0.0,"Duration":30,"DurationLeft":0,"isPassed":true},{"Name":"Self Testing","Description":"","Budget":0.0,"BudgetLeft":0.0,"Duration":7,"DurationLeft":0,"isPassed":true},{"Name":"Soliciting for God\'s Goodness","Description":"","Budget":0.0,"BudgetLeft":0.0,"Duration":1,"DurationLeft":0,"isPassed":true}]}],"Routines":[{"Name":"8348 Americano","Description":"","Budget":12.0,"BudgetLeft":0.0,"Duration":1,"DurationLeft":0,"isPassed":false}]}');
}
