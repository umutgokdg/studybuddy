import 'package:mobile_son/data/data.dart';
import 'package:mobile_son/screen_enum.dart';
import 'package:mobile_son/ui_view/badge_statistics_widget.dart';
import 'package:mobile_son/app_theme.dart';
import 'package:mobile_son/profile/profile_statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:mobile_son/data_manager.dart';
import 'package:mobile_son/ui_view/task_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, this.animationController, required this.groupId, required this.onScreenChange}) : super(key: key);

  final String groupId;
  final Function(int) onScreenChange;

  final AnimationController? animationController;
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  ProfileStatisticsData? data;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  late Future<Group> groupDataFuture;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

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
    listViews.clear();
    const int count = 9;

    listViews.add(
      GeneralSettingsView(
        titleTxt: 'Members',
        data: data,
        isOpen: true,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            const Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
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
        taskName: 'Update Group Description',
        taskIcon: Icons.edit,
        groupId: widget.groupId,
        onScreenChange: widget.onScreenChange,
      ),
    );

    listViews.add(
      SpecificView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            const Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        taskName: 'Update Group Name',
        taskIcon: Icons.edit,
        groupId: widget.groupId,
        onScreenChange: widget.onScreenChange,
      ),
    );

    listViews.add(
      SpecificView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            const Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        taskName: 'Leave Group',
        taskIcon: Icons.exit_to_app_rounded,
        groupId: widget.groupId,
        onScreenChange: widget.onScreenChange,
      ),
    );
  }

  void _reloadGroupData() {
    setState(() {
      groupDataFuture = DataManager.getInGroupData(widget.groupId);
    });
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
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
                  getAppBarUI(),
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
                                  'Settings',
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

class GeneralSettingsView extends StatefulWidget {
  final String titleTxt;
  bool isOpen;
  final AnimationController? animationController;
  final Animation<double>? animation;
  Group data;
  bool drawMember = false;
  final Function onUpdate;

  GeneralSettingsView({
    Key? key,
    this.titleTxt = "",
    this.isOpen = false,
    this.animationController,
    this.animation,
    required this.data,
    this.drawMember = false,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _GeneralSettingsViewState createState() => _GeneralSettingsViewState();
}

class _GeneralSettingsViewState extends State<GeneralSettingsView> {
  List<UserWidget> userWidgetList = <UserWidget>[];

  @override
  void initState() {
    addUserWidgets();

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
                0.0, 50 * (1.0 - widget.animation!.value), 0.0), // Yükseklik değerini artırdım
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 12), // Padding değerlerini artırdım
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 135, 140, 197),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 32, right: 8), // Padding değerlerini artırdım
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                widget.titleTxt,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontWeight: FontWeight.w600, // Font ağırlığını artırdım
                                  fontSize: 22, // Font boyutunu artırdım
                                  letterSpacing: 0.5,
                                  color: AppTheme.nearlyBlack,
                                ),
                              ),
                            ),
                            InkWell(
                              highlightColor: Colors.transparent,
                              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                              onTap: () { _showAddUserDialog(context); },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0), // Padding ekledim
                                child: Icon(
                                  Icons.add,
                                  color: AppTheme.darkText,
                                  size: 36, // İkon boyutunu artırdım
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
                                padding: const EdgeInsets.all(8.0), // Padding ekledim
                                child: Icon(
                                  widget.isOpen ? Icons.arrow_drop_up_sharp : Icons.arrow_drop_down_sharp,
                                  color: AppTheme.darkText,
                                  size: 36, // İkon boyutunu artırdım
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
                      padding: const EdgeInsets.only(top: 16), // Üst padding'i artırdım
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userWidgetList.length,
                      itemBuilder: (context, index) {
                        return userWidgetList[index];
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

  void _showAddUserDialog(BuildContext context) {
    TextEditingController memberController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add User'),
          content: TextField(
            controller: memberController,
            decoration: const InputDecoration(hintText: "Enter new user's username"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async{
                bool success = await DataManager.addMember(
                  widget.data.groupId,
                  MemberAddRequest(
                    email: memberController.text
                  )
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addUserWidgets()
  {
    int count = 9;
    userWidgetList.clear();

    for(int i = 0; i < widget.data.usersList.length; i++)
    {
      userWidgetList.add(
        UserWidget(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: widget.animationController!,
              curve:
              Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
          data: widget.data.usersList[i],
          groupId: widget.data.groupId,
          adminId: widget.data.adminId,
          drawMember: true,
          onUpdate: widget.onUpdate,
        ),
      );
    }
  }
}

class UserWidget extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final bool drawMember;
  final User data;
  final String groupId;
  final String adminId;
  final Function onUpdate;

  const UserWidget({
    Key? key,
    this.animationController,
    this.animation,
    required this.data,
    this.drawMember = false,
    required this.groupId,
    required this.adminId,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
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
                      padding: const EdgeInsets.only(top: 6, left: 6, right: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 10, top: 5),
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
                                      color: Color.fromARGB(255, 98, 97, 97),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataManager.userId == widget.adminId && widget.data.userId != DataManager.userId
                          ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.grey),
                            onPressed: () async{
                              bool success = await DataManager.removeMember(
                                widget.groupId,
                                widget.data.userId
                              );
                              if (success)
                              {
                                widget.onUpdate();
                              }
                            },
                          )
                          : const SizedBox.shrink(),
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




class RowElement extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final Resource data;

  const RowElement({
    Key? key,
    this.animationController,
    this.animation,
    required this.data,
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
                      left: 24, right: 24, top: 0, bottom: 8),
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
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 8, right: 24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {

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
                                                padding: const EdgeInsets.only(left: 12, bottom: 8,),
                                                child: Text(
                                                  widget.data.title.length > textLimit
                                                      ? '${widget.data.title.substring(0, textLimit)}...'
                                                      : widget.data.title,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontFamily: AppTheme.fontName,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color: AppTheme.nearlyDarkBlue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ]
                  ),
                ),
              )
          );
        }
    );
  }
}

class SpecificView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String taskName;
  final IconData taskIcon;
  final Function(int) onScreenChange;
  final String groupId;

  const SpecificView({
    Key? key,
    this.animationController,
    this.animation,
    required this.taskName,
    required this.taskIcon,
    required this.onScreenChange,
    required this.groupId,
  }) : super(key: key);

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
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 0, bottom: 18),
              child: InkWell(
                onTap: () => _handleTaskAction(context, taskName),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            taskName,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: AppTheme.nearlyDarkBlue,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              taskIcon, // Kullanılan yeni ikon parametresi
                              color: AppTheme.darkText,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTaskAction(BuildContext context, String taskName) {
    switch (taskName) {
      case 'Update Group Description':
        _showUpdateGroupDescriptionDialog(context);
        break;
      case 'Update Group Name':
        _showUpdateGroupNameDialog(context);
        break;
      case 'Leave Group':
        _showLeaveGroupConfirmation(context);
        break;
      default:
      // Handle other tasks
        break;
    }
  }

  void _showUpdateGroupDescriptionDialog(BuildContext context) {
    TextEditingController groupDescriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Group Description'),
          content: TextField(
            controller: groupDescriptionController,
            decoration: const InputDecoration(hintText: "Enter new group description"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async{
                await DataManager.updateGroup(
                  groupId, 
                  GroupUpdateRequest(
                    subject: groupDescriptionController.text,
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateGroupNameDialog(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Group Name'),
          content: TextField(
            controller: groupNameController,
            decoration: const InputDecoration(hintText: "Enter new group name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async{
                await DataManager.updateGroup(
                  groupId, 
                  GroupUpdateRequest(
                    title: groupNameController.text,
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLeaveGroupConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leaving Group '),
          content: const Text('Are you sure you want to leave this group?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Leave Group'),
              onPressed: () async{
                bool success = await DataManager.leaveGroup(groupId);
                Navigator.of(context).pop();
                if (success)
                {
                  Navigator.of(context).pop();
                  onScreenChange(Screens.DiaryScreen.index);
                }
                else
                {
                  print("Couldn't leave group!");
                }
              },
            ),
          ],
        );
      },
    );
  }
}

