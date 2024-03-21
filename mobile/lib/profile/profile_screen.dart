import 'package:mobile_son/data/data.dart';
import 'package:mobile_son/login_screen.dart';
import 'package:mobile_son/ui_view/badge_statistics_widget.dart';
import 'package:mobile_son/app_theme.dart';
import 'package:mobile_son/profile/profile_statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:mobile_son/data_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  // ProfileStatisticsData? data;
  late Future<ProfileStatisticsData> profileDataFuture;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
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

    profileDataFuture = DataManager.getProfileStatisticsData();
    super.initState();
  }

  void addAllListData(ProfileStatisticsData profileStatisticsData) {
    listViews.clear();
    const int count = 9;
    listViews.add(
      ProfileStatisticsView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / count) * 7, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController!,
        data: profileStatisticsData
      ),
    );
    listViews.add(
      BadgeStatisticsWidget(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        data: profileStatisticsData.badgeStatistics,
      ),
    );

    listViews.add(
      SpecificView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        taskName: 'Change Username',
        taskIcon: Icons.edit,
        onUpdate: _reloadProfileData,
      ),
    );

    listViews.add(
      SpecificView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        taskName: 'Change Password',
        taskIcon: Icons.edit,
      ),
    );

    listViews.add(
      SpecificView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        taskName: 'Sign Out',
        taskIcon: Icons.exit_to_app_rounded,
      ),
    );

    listViews.add(
      SpecificView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve:
            Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
        taskName: 'Delete Account',
        taskIcon: Icons.exit_to_app_rounded,
      ),
    );
  }

  void _reloadProfileData() {
    setState(() {
      profileDataFuture = DataManager.getProfileStatisticsData();
    });
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder<ProfileStatisticsData>(
      future: profileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppTheme.circularProgressIndicator;
        } else if (snapshot.hasError) {
          return Padding(padding: const EdgeInsets.only(top:50), child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          ProfileStatisticsData profileData = snapshot.data!;
          addAllListData(profileData);
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
                                  'Profile',
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

class SpecificView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String taskName;
  final IconData taskIcon;
  Function? onUpdate;

  SpecificView({
    Key? key,
    this.animationController,
    this.animation,
    required this.taskName,
    required this.taskIcon,
    this.onUpdate,
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
                        offset: Offset(0, 3),
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
                            style: TextStyle(
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
                              taskIcon,
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
      case 'Change Username':
        _showChangeUsernameDialog(context);
        break;
      case 'Change Password':
        _showChangePasswordDialog(context);
        break;
      case 'Sign Out':
        _showSignOutConfirmation(context);
        break;
      case 'Delete Account':
        _showDeleteAccountConfirmation(context);
      default:
      // Handle other tasks
        break;
    }
  }

  void _showChangeUsernameDialog(BuildContext context) {
    TextEditingController userfirstnameController = TextEditingController();
    TextEditingController userlastnameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget> [
              TextField(
                controller: userfirstnameController,
                decoration: InputDecoration(hintText: "Enter first name"),
              ),
              TextField(
                controller: userlastnameController,
                decoration: InputDecoration(hintText: "Enter last name"),
              )
            ]
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async{
                bool success = await DataManager.updateUser(
                  UserUpdateRequest(
                    firstName: userfirstnameController.text,
                    lastName: userlastnameController.text,
                  )
                );
                Navigator.of(context).pop();
                if (success)
                {
                  if (onUpdate != null)
                  {
                    onUpdate!();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: TextField(
            controller: passwordController,
            decoration: InputDecoration(hintText: "Enter new password"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async{
                await DataManager.updateUser(
                  UserUpdateRequest(
                    password: passwordController.text
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

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Sign Out'),
              onPressed: () => Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete Account', style: TextStyle(color: Colors.red),),
              onPressed: () async{
                bool success = await DataManager.userDeleteAccount();
                Navigator.of(context).pop();
                if (success)
                {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

