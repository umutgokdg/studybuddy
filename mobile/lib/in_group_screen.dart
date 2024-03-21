import 'package:mobile_son/settings_screen.dart';
import 'package:mobile_son/tasks/tasks_screen.dart';
import 'package:mobile_son/ui_view/task_widget.dart';
import 'package:mobile_son/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:mobile_son/data/data.dart';
import 'package:mobile_son/data_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/data.dart';

class InGroupScreen extends StatefulWidget {
  InGroupScreen({Key? key, this.animationController, required this.groupId, required this.onScreenChange}) : super(key: key);

  final String groupId;
  final Function(int) onScreenChange;

  final AnimationController? animationController;
  @override
  _InGroupScreen createState() => _InGroupScreen();
}

class _InGroupScreen extends State<InGroupScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  late Future<Group> groupDataFuture;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    groupDataFuture = DataManager.getInGroupData(widget.groupId);

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

  void addAllListData(Group data) {
    const int count = 8;

    listViews.clear();

    listViews.add(
      GroupTasksView(
        titleTxt: 'Tasks',
        data: data.tasksData,
        drawGroup: false,
        isOpen: true,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            const Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        groupId: widget.groupId,
        onUpdate: _reloadGroupData,
      ),
    );

    listViews.add(
      SpecificView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            const Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        task_name: 'Uploaded Files',
        icon: Icons.file_copy,
        isAnnouncement: false,
        data: data.resourcesData,
        groupId: widget.groupId,
        onUpdate: _reloadGroupData,
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  void _reloadGroupData() {
    setState(() {
      groupDataFuture = DataManager.getInGroupData(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Group>(
      future: groupDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppTheme.circularProgressIndicator;
        } else if (snapshot.hasError) {
          return Padding(padding: const EdgeInsets.only(top:50), child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          Group groupData = snapshot.data!;
          addAllListData(groupData);
          return Container(
            color: AppTheme.background,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: <Widget>[
                  getMainListViewUI(),
                  getAppBarUI(groupData),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              ),
            ),
          );
        }
        else {
          return const Text('No data available');
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
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
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

  Widget getAppBarUI(Group data) {
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
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  data.name,
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
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SettingsScreen(animationController: widget.animationController, groupId: widget.groupId, onScreenChange: widget.onScreenChange,)),
                                            );
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.settings,
                                              color: AppTheme.grey,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
}

class LittleTitleView extends StatelessWidget {
  final String titleTxt;
  final bool isOpen;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const LittleTitleView(
      {Key? key,
        this.titleTxt = "",
        this.isOpen = false,
        this.animationController,
        this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.nearlyBlue.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(8.0)),

                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 32, right: 24),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        // bold text
                        child: Text(
                          titleTxt,
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
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                height: 38,
                                width: 26,

                                child: Icon(
                                  isOpen ? Icons.arrow_drop_up_sharp :
                                  Icons.arrow_drop_down_sharp,
                                  color: AppTheme.darkText,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpecificView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String task_name;
  final IconData icon;
  bool isAnnouncement = false;
  ResourcesData data;
  final String groupId;
  final Function onUpdate;

  SpecificView({
    Key? key,
    this.animationController,
    this.animation,
    required this.task_name,
    required this.icon,
    required this.isAnnouncement,
    required this.data,
    required this.groupId,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _SpecificViewState createState() => _SpecificViewState();
}

class _SpecificViewState extends State<SpecificView> {
  bool isOpen = true;
  List<RowElement> rowElementList = <RowElement>[];

  @override
  void initState() {
    addRowElements();

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
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 10, bottom: 10),
              child: Column(
                children: <Widget>[
                                  Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16, right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                isOpen = !isOpen;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        bottom: 20,
                                      ),
                                      child: Text(
                                        widget.task_name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: AppTheme.nearlyDarkBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 3, bottom: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.nearlyWhite,
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: AppTheme.nearlyBlack
                                                .withOpacity(0.4),
                                            offset: const Offset(8.0, 8.0),
                                            blurRadius: 8.0),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            showFilesDialog(context);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.add,
                                              color: AppTheme.darkText,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                  isOpen
                      ? Padding(
                          padding: const EdgeInsets.only(top: 0, bottom: 5),
                          child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(top: 10),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: rowElementList.length,
                              itemBuilder: (context, index) {
                                return rowElementList[index];
                              },
                            )
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showFilesDialog(BuildContext context) {
    // Controllers for text fields
    TextEditingController titleController = TextEditingController();
    TextEditingController linkController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Files Dialog"),
          content: SingleChildScrollView( // Use SingleChildScrollView for better layout
            child: Column(
              mainAxisSize: MainAxisSize.min, // Use minimum space
              children: <Widget>[
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Title:",
                  ),
                ),
                TextFormField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: "Link:",
                  ),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description:",
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () async {
                
                await DataManager.createResource(
                  ResourceCreateRequest(
                    title: titleController.text,
                    description: descriptionController.text,
                    link: linkController.text,
                  ),
                  widget.groupId
                );

                Navigator.of(context).pop();

                widget.onUpdate();
              },
            ),
          ],
        );
      },
    );
  }

  void addRowElements()
  {
    int count = 9;
    rowElementList.clear();

    for(int i = 0; i < widget.data.resources.length; i++)
    {
      rowElementList.add(
          RowElement(
            data: widget.data.resources[i],
            animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                parent: widget.animationController!,
                curve:
                Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
            animationController: widget.animationController,
            groupId: widget.groupId,
            onUpdate: widget.onUpdate,
          )
      );
    }
  }
}

class RowElement extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final Resource data;
  final String groupId;
  final Function onUpdate;

  const RowElement({
    Key? key,
    this.animationController,
    this.animation,
    required this.data,
    required this.groupId,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _RowElement createState() => _RowElement();
}

class _RowElement extends State<RowElement> {
  final textLimit = 27;

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
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 0, bottom: 8),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Burada 'AppTheme.white' yerine 'Colors.white' kullandım.
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(8.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final url = Uri.parse(widget.data.link);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  print("Can't open URL: $url");
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, bottom: 0,),
                                    child: Text(
                                      widget.data.title,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 10, right: 10),
                                    child: Divider(
                                      color: Color.fromARGB(135, 103, 100, 100),
                                      thickness: 2.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 14, bottom: 8,),
                                    child: Text(
                                      widget.data.link,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 62, 91, 223),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.grey),
                            onPressed: () async{
                              bool success = await DataManager.deleteResource(widget.groupId, widget.data.resourceId);
                              if (success)
                              {
                                widget.onUpdate();
                              }
                            },
                            iconSize: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class GroupTasksView extends StatefulWidget {
  final String titleTxt;
  bool isOpen;
  final AnimationController? animationController;
  final Animation<double>? animation;
  TasksData data;
  bool drawGroup = false;
  final String groupId;
  final Function onUpdate;

  GroupTasksView({
    Key? key,
    this.titleTxt = "",
    this.isOpen = false,
    this.animationController,
    this.animation,
    required this.data,
    this.drawGroup = false,
    required this.groupId,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _GroupTasksViewState createState() => _GroupTasksViewState();
}

class _GroupTasksViewState extends State<GroupTasksView> {
  List<TaskWidget> taskWidgetList = <TaskWidget>[];

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
                0.0, 50 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 12),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 135, 140, 197),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32, right: 8), 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.titleTxt,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.w600,
                                fontSize: 22, 
                                letterSpacing: 0.5,
                                color: AppTheme.nearlyBlack,
                              ),
                            ),
                          ),
                          InkWell(
                            highlightColor: Colors.transparent,
                            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                            onTap: () { _showAddTaskDialog(context); },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.add,
                                color: AppTheme.darkText,
                                size: 36, 
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
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                widget.isOpen ? Icons.arrow_drop_up_sharp : Icons.arrow_drop_down_sharp,
                                color: AppTheme.darkText,
                                size: 36, 
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  widget.isOpen ?
                  ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 16),
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
        );
      },
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
                      groupId: widget.groupId,
                    );
                    Navigator.of(context).pop();
                    if (success)
                    {
                      widget.onUpdate();
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

  void addTaskWidgets()
  {
    int count = 9;
    taskWidgetList.clear();

    for(int i = 0; i < widget.data.tasks.length; i++)
    {
      taskWidgetList.add(
        TaskWidget(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: widget.animationController!,
              curve:
              Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
          data: widget.data.tasks[i],
          drawGroup: widget.drawGroup,
          onUpdate: widget.onUpdate,
        ),
      );
    }
  }
}
