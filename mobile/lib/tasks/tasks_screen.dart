import 'package:mobile_son/data/data.dart';
import 'package:mobile_son/data_manager.dart';
import 'package:mobile_son/ui_view/task_widget.dart';
import 'package:mobile_son/app_theme.dart';
import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  late Future<TasksData> tasksDataFuture;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    tasksDataFuture = DataManager.getTasksData(onlyIndividualTasks: true);

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
  }

  void addAllListData(TasksData data) {
    const int count = 8;

    listViews.clear();

    for (int i = 0; i < data.tasks.length; i++) {
      listViews.add(
        TaskWidget(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve:
                  const Interval(
                      (1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
          data: data.tasks[i],
          onUpdate: _reloadTaskData,
        ),
      );
    }
    if (listViews.length == 0)
    {
      listViews.add(SizedBox.shrink());
    }
  }

  void _reloadTaskData() {
    setState(() {
      tasksDataFuture = DataManager.getTasksData(onlyIndividualTasks: true);
    });
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TasksData>(
        future: tasksDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AppTheme.circularProgressIndicator;
          } else if (snapshot.hasError) {
            return Padding(padding: const EdgeInsets.only(top: 50),
                child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            TasksData tasksData = snapshot.data!;
            addAllListData(tasksData);
            return Container(
              color: AppTheme.background,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: <Widget>[
                    getMainListViewUI(),
                    getAppBarUI(),
                    SizedBox(
                      height: MediaQuery
                          .of(context)
                          .padding
                          .bottom,
                    )
                  ],
                ),
              ),
            );
          }
          else {
            return Padding(padding: EdgeInsets.all(50), child: Text('No data available'),);
          }
        }
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery
                      .of(context)
                      .padding
                      .top +
                  24,
              bottom: 62 + MediaQuery
                  .of(context)
                  .padding
                  .bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: AppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery
                            .of(context)
                            .padding
                            .top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'My Tasks',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: AppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              iconSize: 36,
                              onPressed: () {
                                _showAddTaskDialog(context);
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) async {
    TextEditingController taskNameController = TextEditingController();
    TextEditingController taskDescriptionController = TextEditingController();
    DateTime? selectedDeadline;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _selectDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDeadline ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2025),
              );
              if (picked != null && picked != selectedDeadline) {
                setState(() {
                  selectedDeadline = picked;
                });
              }
            }

            return AlertDialog(
              title: Text("Add Task"),
              content: SingleChildScrollView(  // SingleChildScrollView ekleyerek içeriği kaydırılabilir yapabilirsiniz.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: taskNameController,
                      decoration: InputDecoration(
                        labelText: "Task Name:",
                      ),
                    ),
                    TextField(
                      controller: taskDescriptionController,
                      decoration: InputDecoration(
                        labelText: "Task Description:",
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedDeadline == null
                            ? "No Deadline Selected"
                            : "Deadline: ${selectedDeadline!.toLocal().toString().split(" ")[0]}"),
                        TextButton(
                          onPressed: _selectDate,
                          child: Text('Select Deadline'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Add"),
                  onPressed: () async{
                    bool success = await DataManager.createTask(
                      TaskCreateRequest(
                        title: taskNameController.text,
                        description: taskDescriptionController.text,
                        deadline: selectedDeadline != null ? selectedDeadline!.toIso8601String() : null,
                      ),
                      groupId: null
                    );
                    Navigator.of(context).pop();
                    if (success)
                    {
                      _reloadTaskData();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class GeneralTasksView extends StatefulWidget {
  final String titleTxt;
  bool isOpen;
  final AnimationController? animationController;
  final Animation<double>? animation;
  TasksData data;
  bool drawGroup = false;

  GeneralTasksView({
    Key? key,
    this.titleTxt = "",
    this.isOpen = false,
    this.animationController,
    this.animation,
    required this.data,
    this.drawGroup = false,
  }) : super(key: key);

  @override
  _GeneralTasksViewState createState() => _GeneralTasksViewState();
}

class _GeneralTasksViewState extends State<GeneralTasksView> {
  List<UpcomingTaskWidget> taskWidgetList = <UpcomingTaskWidget>[];

  @override
  void initState() {
    addTaskWidgets();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 16),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 135, 140, 197),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(8.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                widget.titleTxt,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: AppTheme.nearlyBlack,
                                ),
                              ),
                            ),
                            InkWell(
                              highlightColor: Colors.transparent,
                              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                              onTap: () {
                                setState(() {
                                  widget.isOpen = !widget.isOpen;
                                });
                              },
                              child: Icon(
                                widget.isOpen ? Icons.arrow_drop_up_sharp : Icons.arrow_drop_down_sharp,
                                color: AppTheme.darkText,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    widget.isOpen ?
                      ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 10),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: taskWidgetList.length,
                        itemBuilder: (context, index) {
                          return taskWidgetList[index];
                        },
                      )
                    : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void addTaskWidgets()
  {
    int count = 9;
    taskWidgetList.clear();

    for(int i = 0; i < widget.data.tasks.length; i++)
    {
      taskWidgetList.add(
        UpcomingTaskWidget(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: widget.animationController!,
              curve:
              Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
          data: widget.data.tasks[i],
          drawGroup: true,
        ),
      );
    }
  }
}
