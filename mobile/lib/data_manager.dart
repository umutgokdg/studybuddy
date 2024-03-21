import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile_son/data/data.dart';

class DataManager 
{
  static const String _baseUrl = 'http://165.227.134.202:3500';
  static String? accessToken;
  static String? userId;

  static Future<GroupsData> getGroupsData() async {
    var url = Uri.parse('$_baseUrl/group/showByUser');
    var response = await http.get(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return GroupsData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load groups data. Status code: ${response.statusCode}');
    }
  }
 
  static Future<ProfileStatisticsData> getProfileStatisticsData() async
  {
    var url = Uri.parse('$_baseUrl/user/profile');
    var response = await http.get(
      url,
      headers: {
        'Authorization': "Bearer ${accessToken}",
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) 
    {
      return ProfileStatisticsData.fromJson(jsonDecode(response.body));
    } 
    else 
    {
      throw Exception('Failed to load profile statistics ${response.statusCode}');
    }

  }

  static BadgeStatisticsData getBadgeStatisticsData()
  {
    BadgeStatisticsData data = BadgeStatisticsData(currentPoints: Random().nextInt(100), toNextBadgePoints: 100);
    return data;
  }

  static Future<TasksData> getTasksData({bool onlyIndividualTasks = false}) async {
    var url = Uri.parse('$_baseUrl/task');
    var response = await http.get(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      if (onlyIndividualTasks) {
        jsonResponse = jsonResponse.where((task) => task['groupId'] == null).toList();
      }
      return TasksData.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load tasks data. Status code: ${response.statusCode}');
    }
  }

  static Future<Group> getInGroupData(String groupId) async {
    var url = Uri.parse('$_baseUrl/group/show/$groupId');
    var response = await http.get(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load tasks data. Status code: ${response.statusCode}');
    }
  }

  static Future<TasksData> getUpcomingTaskData() async {
    var url = Uri.parse('$_baseUrl/task/closesttasks');
    var response = await http.get(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return TasksData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load tasks data. Status code: ${response.statusCode}');
    }
  }

  static Future<bool> login(String email, String password) async {
    var url = Uri.parse('$_baseUrl/login');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(LoginData(email: email, password: password).toJson()),
    );

    accessToken = jsonDecode(response.body)['accessToken'];
    userId = jsonDecode(response.body)['userId'];
    return response.statusCode == 200; 
  }

  static Future<bool> register(RegistrationRequest registrationRequest) async {
    var url = Uri.parse('$_baseUrl/register');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(registrationRequest.toJson()),
    );

    return response.statusCode == 200;
  }


  static Future<bool> markTaskAsCompleted(String taskId) async {
    var url = Uri.parse('$_baseUrl/task/$taskId/completed');
    var response = await http.put(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> createTask(TaskCreateRequest task, {String? groupId}) async {
    String urlEndpoint = groupId == null ? '/task/create' : '/task/create/$groupId';
    var url = Uri.parse('$_baseUrl$urlEndpoint');

    var response = await http.post(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(task.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteTask(String taskId) async {
    var url = Uri.parse('$_baseUrl/task/delete/$taskId');
    var response = await http.delete(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> updateTask(String taskId, TaskUpdateRequest taskUpdateRequest) async {
    var url = Uri.parse('$_baseUrl/task/edit/$taskId');
    var response = await http.put(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(taskUpdateRequest.toJson()),
    );

    print(jsonEncode(taskUpdateRequest.toJson()));
    print(response.body);
    return response.statusCode == 200;
  }


  static Future<bool> createResource(ResourceCreateRequest resource, String groupId) async {
    var url = Uri.parse('$_baseUrl/resource/$groupId');
    var response = await http.post(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(resource.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteResource(String groupId, String resourceId) async {
    var url = Uri.parse('$_baseUrl/resource/$groupId/$resourceId');
    var response = await http.delete(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> createGroup(GroupCreateRequest groupRequest) async {
    var url = Uri.parse('$_baseUrl/group');
    var response = await http.post(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(groupRequest.toJson()),
    );

    return response.statusCode == 200;
  }
 
  static Future<bool> leaveGroup(String groupId) async {
    var url = Uri.parse('$_baseUrl/group/leaveGroup/$groupId');
    var response = await http.put(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> updateGroup(String groupId, GroupUpdateRequest groupUpdateRequest) async {
    var url = Uri.parse('$_baseUrl/group/update/$groupId');
    var response = await http.put(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(groupUpdateRequest.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> updateUser(UserUpdateRequest userUpdateRequest) async {
    var url = Uri.parse('$_baseUrl/user');
    var response = await http.put(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userUpdateRequest.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> addMember(String groupId, MemberAddRequest memberAddRequest) async {
    var url = Uri.parse('$_baseUrl/group/$groupId');
    var response = await http.post(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(memberAddRequest.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> removeMember(String groupId, String userId) async {
    var url = Uri.parse('$_baseUrl/group/removeUser/$groupId/$userId');
    var response = await http.put(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> assignMemberToTask(String taskId, MemberAssignRequest memberAssignRequest) async {
    var url = Uri.parse('$_baseUrl/task/assign/$taskId');
    var response = await http.put(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(memberAssignRequest.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> userDeleteAccount() async {
    var url = Uri.parse('$_baseUrl/user');
    var response = await http.delete(
      url,
      headers: {
        'Authorization': "Bearer $accessToken",
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

}

class LoginData
{
  final String email;
  final String password;

  LoginData({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

}
