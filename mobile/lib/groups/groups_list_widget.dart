import 'package:mobile_son/app_theme.dart';
import 'package:mobile_son/data/data.dart';
import 'package:mobile_son/models/groups_list_data.dart';
import 'package:flutter/material.dart';
import 'package:mobile_son/screen_enum.dart';
import 'package:mobile_son/utils.dart';

class GroupsListWidget extends StatefulWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final Function(int, [String?]) onScreenChange;
  GroupsData groupsData;

  GroupsListWidget({
    Key? key,
    required this.groupsData,
    required this.onScreenChange,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  }) : super(key: key);

  @override
  _GroupsListWidgetState createState() => _GroupsListWidgetState();
}

class _GroupsListWidgetState extends State<GroupsListWidget>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }



  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 170, right: 16, left: 16),
                itemCount: widget.groupsData.groups.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  final int count =
                      widget.groupsData.groups.length > 10 ? 10 : widget.groupsData.groups.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Interval((1 / count) * index, 1.0,
                                  curve: Curves.fastOutSlowIn)));
                  animationController?.forward();

                  return GroupsView(
                    groupData: widget.groupsData.groups[index],
                    animation: animation,
                    animationController: animationController!,
                    onScreenChange: () => widget.onScreenChange(Screens.InGroupScreen.index, widget.groupsData.groups[index].groupId),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class GroupsView extends StatelessWidget {
  final Group? groupData;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final VoidCallback onScreenChange;
  final textLimit = 20;

  const GroupsView({
    Key? key,
    this.groupData,
    this.animationController,
    this.animation,
    required this.onScreenChange,
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
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: SizedBox(
              // width: 130,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 5, left: 8, right: 8, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: HexColor(groupData!.endColor)
                                  .withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0),
                        ],
                        gradient: LinearGradient(
                          colors: <HexColor>[
                            HexColor(groupData!.startColor),
                            HexColor(groupData!.endColor),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(54.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 16, right: 16, bottom: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Bu satırı ekleyin
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              groupData!.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                shadows: [Shadow(offset: Offset(0.2, 0.4))],
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.2,
                                color: AppTheme.white,
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        "Description:",
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 0.2,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                      Text(
                                        groupData!.description.length > textLimit
                                        ? '${groupData!.description.substring(0, textLimit)}...'
                                        : groupData!.description,
                                        style: const TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          letterSpacing: 0.2,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                        height: 10,
                                      ),
                                      const Text(
                                        "Admin:",
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 0.2,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                      Text(
                                        groupData!.admin.length > textLimit
                                        ? '${groupData!.admin.substring(0, textLimit)}...'
                                        : groupData!.admin,
                                        style: const TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          letterSpacing: 0.2,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 1),
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
                                        onTap: onScreenChange,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color: HexColor(groupData!.endColor),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppTheme.nearlyWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Positioned(
                  //   top: 0,
                  //   left: 8,
                  //   child: SizedBox(
                  //     width: 80,
                  //     height: 80,
                  //     child: Image.asset(mealsListData!.imagePath),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
