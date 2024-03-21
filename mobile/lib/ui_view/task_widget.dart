import 'package:mobile_son/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:mobile_son/data/data.dart';
import 'package:mobile_son/data_manager.dart';
import 'package:intl/intl.dart';

class TaskWidget extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final bool drawGroup;
  final Task data;
  final Function onUpdate;

  const TaskWidget({
    Key? key,
    this.animationController,
    this.animation,
    required this.data,
    this.drawGroup = false,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  TextEditingController _nameController = TextEditingController();

  void _addNameToList() async {
    // await showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: Text('Add member to this task'),
    //       content: TextField(
    //         controller: _nameController,
    //         decoration: InputDecoration(hintText: "Enter username"),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           child: Text('Cancel'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //         TextButton(
    //           child: Text('Add'),
    //           onPressed: () async{
    //             if (_nameController.text.isNotEmpty) {
    //               bool success = await DataManager.assignMemberToTask(
    //                 widget.data.taskId,
    //                 MemberAssignRequest(
    //                   emails: [_nameController.text],
    //                 )
    //               );

    //               Navigator.of(context).pop();
    //               widget.onUpdate();
    //             }
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  TextEditingController _taskNameController = TextEditingController();
  TextEditingController _taskDescriptionController = TextEditingController();
  DateTime? selectedDeadline;
  List<String> _newMembers = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDeadline) {
      selectedDeadline = picked;
    }
  }

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Task'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _taskNameController,
                    decoration: InputDecoration(hintText: "Enter task name"),
                  ),
                  TextField(
                    controller: _taskDescriptionController,
                    decoration: InputDecoration(hintText: "Enter task description"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    selectedDeadline == null
                        ? "No Deadline Selected"
                        : "Deadline: ${DateFormat('yyyy-MM-dd').format(selectedDeadline!)}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context).then((_) => setState(() {})),
                    child: Text('Select Deadline'),
                  ),
                  Divider(),
                  widget.data.groupId != null ? Text('Add Members to Task', style: TextStyle(fontWeight: FontWeight.bold))
                  : SizedBox.shrink(),
                  widget.data.groupId != null ? SizedBox(height: 10)
                  : SizedBox.shrink(),
                  if (widget.data.groupId != null)
                  ...widget.data.usersAssigned.map((member) => ListTile(
                        title: Text(member),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              widget.data.usersAssigned.remove(member);
                            });
                          },
                        ),
                      )),
                  if (widget.data.groupId != null)    
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: "Enter username"),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _newMembers.add(value);
                            _nameController.clear();
                          });
                        }
                      },
                    ),
                  if (widget.data.groupId != null)
                    ..._newMembers.map((member) => ListTile(
                          title: Text(member),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _newMembers.remove(member);
                              });
                            },
                          ),
                        )
                      ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Save Changes'),
                onPressed: () async {
                  // Burada task adı, açıklaması, deadline ve yeni eklenen üyeleri kaydedebilirsiniz.
                  _newMembers.addAll(widget.data.usersAssigned);
                  await DataManager.updateTask(
                    widget.data.taskId,
                    TaskUpdateRequest(
                      name: _taskNameController.text, 
                      description: _taskDescriptionController.text, 
                      deadline: selectedDeadline != null ? selectedDeadline!.toIso8601String() : null, 
                      usersAssigned: widget.data.groupId != null ? _newMembers : null,
                  ));
                  Navigator.of(context).pop();
                  widget.onUpdate();
                },
              ),
            ],
          );
        },
      );
    },
  );


  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _addNameToList,
        child: AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 0, bottom: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(8.0)),
                ),
                child: Column(
                  children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.only(top: 0, left: 6, right: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Checkbox(
                          value: widget.data.done,
                          onChanged: (bool? newValue) async {
                            if (newValue != null) {
                              bool success = await DataManager.markTaskAsCompleted(widget.data.taskId);
                              if (success) {
                                setState(() {
                                  widget.data.done = newValue;
                                });
                              } else {
                                print("Task could not be set done.");
                              }
                            }
                          },
                          activeColor: Colors.green.withOpacity(0.8),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0, bottom: 5, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.data.name,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 19,
                                    color: AppTheme.nearlyDarkBlue,
                                  ),
                                ),
                                Text(
                                  widget.data.description,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppTheme.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget> [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey),
                              onPressed: () async{
                                bool success = await DataManager.deleteTask(widget.data.taskId);
                                if (success)
                                {
                                  widget.onUpdate();
                                }
                              },
                            ),
                            widget.data.deadline != null
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0, bottom: 0),
                                  child: Icon(
                                    Icons.access_time,
                                    color: AppTheme.grey
                                        .withOpacity(0.5),
                                    size: 16,
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(left: 4.0, bottom: 0),
                                  child: Text(
                                    widget.data.deadline!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily:
                                      AppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      letterSpacing: 0.0,
                                      color: AppTheme.grey
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                )
                              ],
                            )
                            : SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, bottom: 10),
                      child: widget.data.usersAssigned.length > 0 ? GridView.builder(
                        shrinkWrap: true, 
                        physics: NeverScrollableScrollPhysics(), 
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, 
                          childAspectRatio: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 2.0, 
                        ),
                        itemCount: widget.data.usersAssigned.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Align(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey), 
                                borderRadius: BorderRadius.circular(10.0), 
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  widget.data.usersAssigned[index],
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                      : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
    );
  }
}

class UpcomingTaskWidget extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final bool drawGroup;
  final Task data;

  const UpcomingTaskWidget({
    Key? key,
    this.animationController,
    this.animation,
    required this.data,
    this.drawGroup = false,
  }) : super(key: key);

  @override
  _UpcomingTaskWidgetState createState() => _UpcomingTaskWidgetState();
}

class _UpcomingTaskWidgetState extends State<UpcomingTaskWidget> {

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
                  left: 12, right: 12, top: 0, bottom: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(8.0)),

                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 6, left: 6, right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Checkbox(
                                    value: widget.data.done,
                                    onChanged: (bool? newValue) async {
                                      if (newValue != null) {
                                        bool success = await DataManager.markTaskAsCompleted(widget.data.taskId);
                                        if (success) {
                                          setState(() {
                                            widget.data.done = newValue;
                                          });
                                        } else {
                                          print("Task could not be set done.");
                                        }
                                      }
                                    },
                                    activeColor: Colors.green.withOpacity(0.8),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0, bottom: 5, top: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            widget.data.name,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 19,
                                              color: AppTheme.nearlyDarkBlue,
                                            ),
                                          ),
                                          Text(
                                            widget.data.description,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: AppTheme.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  widget.drawGroup 
                                  ? Text(
                                          "From: ${widget.data.groupName}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily:
                                                AppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            letterSpacing: 0.0,
                                            color: AppTheme.grey
                                                .withOpacity(0.5),
                                          ),
                                        )
                                  : SizedBox.shrink(),
                                  widget.data.deadline != null
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4.0, bottom: 10),
                                        child: Icon(
                                          Icons.access_time,
                                          color: AppTheme.grey
                                              .withOpacity(0.5),
                                          size: 16,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0, bottom: 10),
                                        child: Text(
                                          widget.data.deadline!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily:
                                                AppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            letterSpacing: 0.0,
                                            color: AppTheme.grey
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                  : SizedBox.shrink(),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}