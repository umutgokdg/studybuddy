class GroupsListData {
  GroupsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.groups,
    this.kacl = 0,
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? groups;
  int kacl;

  static List<GroupsListData> tabIconsList = <GroupsListData>[
    GroupsListData(
      imagePath: 'assets/fitness_app/breakfast.png',
      titleTxt: 'BLG411E',
      kacl: 525,
      groups: <String>['Software Engineering', 'esatgundogdu'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    GroupsListData(
      imagePath: 'assets/fitness_app/lunch.png',
      titleTxt: 'BLG335E',
      kacl: 602,
      groups: <String>['Analysis of Algorithms', 'umutgokdg'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    GroupsListData(
      imagePath: 'assets/fitness_app/snack.png',
      titleTxt: 'BLG458E',
      kacl: 0,
      groups: <String>['Functional Progamming', 'silakucuknane'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
    GroupsListData(
      imagePath: 'assets/fitness_app/dinner.png',
      titleTxt: 'BLG435E',
      kacl: 0,
      groups: <String>['Artificial Intelligence', 'ulassezen'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
    GroupsListData(
      imagePath: 'assets/fitness_app/dinner.png',
      titleTxt: 'BLG454E',
      kacl: 0,
      groups: <String>['Learning From Data', 'baristurker'],
      startColor: '#87F7BB',
      endColor: '#13B05C',
    ),
  ];
}
