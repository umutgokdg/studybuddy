import 'package:intl/intl.dart';

class ProfileStatisticsData
{
  String nickname;
  String createDate;
  BadgeStatisticsData badgeStatistics;
  int achievedTasks;
  int activeGroups;

  ProfileStatisticsData({required this.nickname, required this.createDate, required this.badgeStatistics, required this.achievedTasks, required this.activeGroups});

  factory ProfileStatisticsData.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['createDate']);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

    return ProfileStatisticsData(
      nickname: json['nickname'],
      createDate: formattedDate,
      badgeStatistics: BadgeStatisticsData.fromJson(json['badgeStatistics']),
      achievedTasks: json['achievedTasks'],
      activeGroups: json['activeGroups'],
    );
  }
}

class BadgeStatisticsData
{
  int currentPoints;
  int toNextBadgePoints;

  BadgeStatisticsData({required this.currentPoints, required this.toNextBadgePoints});

  factory BadgeStatisticsData.fromJson(Map<String, dynamic> json) {
    return BadgeStatisticsData(
      currentPoints: json['currentPoints'],
      toNextBadgePoints: json['toNextBadgePoints'],
    );
  }
}

class GroupsData {
  List<Group> groups = [];

  GroupsData({required this.groups});

  factory GroupsData.fromJson(List<dynamic> jsonList) {
    List<Group> groups = jsonList.map((json) => Group.fromJson(json)).toList();
    return GroupsData(groups: groups);
  }

  void addGroup(Group group) {
    groups.add(group);
  }
}

class Group {
  String name;
  String admin;
  String description;
  String groupId;
  String adminId;
  ResourcesData resourcesData;
  List<User> usersList;
  TasksData tasksData;
  String endColor = "#FFB295";
  String startColor = "#FA7D82";

  Group({
    required this.name,
    required this.admin,
    required this.description,
    required this.groupId,
    required this.resourcesData,
    required this.tasksData,
    required this.adminId,
    this.usersList = const [],
    this.endColor = "#FFB295",
    this.startColor = "#FA7D82",
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    // var resourceListJson = json['ResourceList'] as List;
    // List<Resource> resourceList = resourceListJson.map((resourceJson) => Resource.fromJson(resourceJson)).toList();
    var usersListJson = json['users'] as List;
    List<User> usersList = usersListJson.map((userJson) => User.fromJson(userJson)).toList();

    return Group(
      name: json['name'],
      admin: json['admin'],
      groupId: json['groupId'],
      description: json['subject'],
      resourcesData: ResourcesData.fromJson(json['ResourceList']),
      tasksData: TasksData.fromJson(json['TaskList']),
      usersList: usersList,
      adminId: json['adminId'],
    );
  }
} 

class TasksData {
  List<Task> tasks;

  TasksData({required this.tasks});

  factory TasksData.fromJson(List<dynamic> jsonList) {
    List<Task> tasks = jsonList.map((json) => Task.fromJson(json)).toList();
    return TasksData(tasks: tasks);
  }

  void addTask(Task task) {
    tasks.add(task);
  }
}

class Task {
  String name;
  String description;
  String? deadline;
  bool done;
  String taskId;
  String? groupId; 
  String? groupName;
  List<String> usersAssigned;

  Task({
    required this.name,
    required this.description,
    required this.deadline,
    required this.done,
    required this.taskId,
    this.groupId,
    required this.groupName,
    required this.usersAssigned,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'],
      groupName: json['groupName'] ?? "Individual",
      description: json['description'],
      deadline: json['deadline'] != null 
                ? DateFormat('yyyy-MM-dd').format(DateTime.parse(json['deadline']))
                : null,
      done: json['done'],
      taskId: json['taskId'],
      groupId: json['groupId'], 
      usersAssigned: List<String>.from(json['usersAssigned'] ?? []),
    );
  }
}

class User {
  String name;
  String userId;
  User({
    required this.name,
    required this.userId,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json["nickname"],
      userId: json['userId'],
    );
  }
}

class ResourcesData
{
  List<Resource> resources = [];

  void addResource(Resource resource)
  {
    resources.add(resource);
  }
  
  ResourcesData({required this.resources});

  factory ResourcesData.fromJson(List<dynamic> jsonList) {
    List<Resource> resources = jsonList.map((json) => Resource.fromJson(json)).toList();
    return ResourcesData(resources: resources);
  }
}

class Resource {
  String title;
  String link;
  String description;
  String resourceId;

  Resource({required this.title, required this.link, required this.description, required this.resourceId});

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      title: json['title'],
      link: json['link'],
      description: json['description'],
      resourceId: json['resourceId'],
    );
  }
}

class TaskCreateRequest {
  String title;
  String description;
  String? deadline;

  TaskCreateRequest({
    required this.title,
    required this.description,
    this.deadline,
  });

  Map<String, dynamic> toJson() {
      Map<String, dynamic> data = {};
      data['title'] = title;
      data['description'] = description;
      if (deadline != null)
      {
        data['deadline'] = deadline;
      }
      return data;
  }
}

class ResourceCreateRequest {
  String title;
  String link;
  String description;

  ResourceCreateRequest({
    required this.title,
    required this.link,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'description': description,
    };
  }
}

class GroupCreateRequest {
  String title;
  String subject;

  GroupCreateRequest({
    required this.title,
    required this.subject,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject': subject,
    };
  }
}

class GroupUpdateRequest {
  String? title;
  String? subject;

  GroupUpdateRequest({
    this.title,
    this.subject,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    if (title != null) {
      data['title'] = title;
    }
    if (subject != null) {
      data['subject'] = subject;
    }
    return data;
  }
}

class UserUpdateRequest {
  String? firstName;
  String? lastName;
  String? password;

  UserUpdateRequest({this.firstName, this.lastName, this.password});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    if (firstName != null) {
      data['first_name'] = firstName;
    }
    if (lastName != null) {
      data['last_name'] = lastName;
    }
    if (password != null) {
      data['password'] = password;
    }
    return data;
  }
}

class MemberAddRequest {
  String email;

  MemberAddRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class MemberAssignRequest {
  List<String> emails;

  MemberAssignRequest({
    required this.emails,
  });

  Map<String, dynamic> toJson() {
    return {
      'emails': emails,
    };
  }
}

class RegistrationRequest {
  String email;
  String password;
  String firstname;
  String lastname;

  RegistrationRequest({
    required this.email,
    required this.password,
    required this.firstname,
    required this.lastname,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstname': firstname,
      'lastname': lastname,
    };
  }
}

class TaskUpdateRequest {
  String? name;
  String? description;
  String? deadline;
  List<String>? usersAssigned;

  TaskUpdateRequest({
    required this.name,
    required this.description,
    required this.deadline,
    required this.usersAssigned,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    if (name != null && name != "")
    {
      data['title'] = name;
    }
    if (description != null && description != "")
    {
      data['description'] = description;
    }
    if (deadline != null)
    {
      data['deadline'] = deadline;
    }
    if (usersAssigned != null)
    {
      data['emails'] = usersAssigned;
    }
    return data;
  }
}

