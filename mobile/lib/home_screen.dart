import 'package:mobile_son/data/data.dart';
import 'package:mobile_son/data_manager.dart';
import 'package:mobile_son/groups/groups_screen.dart';
import 'package:mobile_son/models/tabIcon_data.dart';
import 'package:mobile_son/profile/profile_screen.dart';
import 'package:mobile_son/diary/diary_screen.dart';
import 'package:flutter/material.dart';
import 'package:mobile_son/bottom_navigation_view/bottom_bar_view.dart';
import 'package:mobile_son/app_theme.dart';
import 'package:mobile_son/screen_enum.dart';
import 'package:mobile_son/tasks/tasks_screen.dart';

import 'in_group_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  late StatefulWidget tabBody;
  late int screenIndex;

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    screenIndex = Screens.DiaryScreen.index;
    changeScreen(screenIndex);

    tabIconsList[Screens.DiaryScreen.index].isSelected = true;
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async {
        // Geri tuşuna basıldığında hiçbir şey yapma
        return false;
      },
      child: Container(
        color: AppTheme.background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: FutureBuilder<bool>(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              } else {
                return Stack(
                  children: <Widget>[
                    tabBody,
                    bottomBar(),
                  ],
                );
              }
            },
          ),
        ),
      )
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  void changeScreen(int index, [String? groupId]) {
    setState(() {
      screenIndex = index;
      if (index < Screens.InGroupScreen.index){
        setRemoveAllSelection(tabIconsList[index]);
      }
      else {
        setRemoveAllSelection(null);
      }
      if (index == Screens.DiaryScreen.index) {
        animationController?.reverse().then<dynamic>((data) {
          if (!mounted) {
            return;
          }
          setState(() {
            tabBody =
                new DiaryScreen(animationController: animationController, onScreenChange: changeScreen,);
          });
        });
      }
      else if (index == Screens.GroupsScreen.index) {
        animationController?.reverse().then<dynamic>((data) {
          if (!mounted) {
            return;
          }
          setState(() {
            tabBody =
                GroupsScreen(animationController: animationController, onScreenChange: changeScreen,);
          });
        });
      }
      else if (index == Screens.TasksScreen.index) {
        animationController?.reverse().then<dynamic>((data) {
          if (!mounted) {
            return;
          }
          setState(() {
            tabBody =
                TasksScreen(animationController: animationController);
          });
        });
      }
      else if (index == Screens.ProfileScreen.index) {
        animationController?.reverse().then<dynamic>((data) {
          if (!mounted) {
            return;
          }
          setState(() {
            tabBody =
                ProfileScreen(animationController: animationController);
          });
        });
      }
      else if (index == Screens.InGroupScreen.index){
        animationController?.reverse().then<dynamic>((data) {
          if (!mounted) {
            return;
          }
          setState(() {
            tabBody =
                InGroupScreen(animationController: animationController, groupId: groupId!, onScreenChange: changeScreen,);
          });
        });
      }
    });
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            showAddGroupDialog(context); // Bu fonksiyonu çağırır
          },
          changeIndex: changeScreen,
        ),
      ],
    );
  }

  void setRemoveAllSelection(TabIconData? tabIconData) {
    setState(() {
      for (var tab in tabIconsList) {
        tab.isSelected = tabIconData != null && tabIconData.index == tab.index;
      }
    });
  }

  void showAddGroupDialog(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();
    TextEditingController groupDescriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Group"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: groupNameController,
                decoration: InputDecoration(
                  labelText: "Group Name:",
                ),
              ),
              TextField(
                controller: groupDescriptionController,
                decoration: InputDecoration(
                  labelText: "Group Description:",
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () async{

                bool success = await DataManager.createGroup(
                  GroupCreateRequest(
                    title: groupNameController.text,
                    subject: groupDescriptionController.text
                  )
                );

                Navigator.of(context).pop();

                if (success)
                {
                setState(() {
                  if (screenIndex == Screens.InGroupScreen.index)
                  {
                    changeScreen(Screens.DiaryScreen.index);
                  }
                  else
                  {
                    Key diaryScreenKey = UniqueKey();
                    screenIndex = Screens.DiaryScreen.index;
                    tabBody = DiaryScreen(animationController: animationController, key: diaryScreenKey,onScreenChange: changeScreen);
                  }
                });
                }
              },
            ),
          ],
        );
      },
    );
  }
}

