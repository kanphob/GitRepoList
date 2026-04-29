import 'package:flutter/material.dart';

class ModelUserRepo {
  String sID = "";
  String sUserName = "";
  String sImgProfileUrl = "";
  String sUserGitUrl = "";
  bool isChecked = false;
  List<ModelRepoData>? listRepoData = [];

  ModelUserRepo({
    this.sID = "",
    this.sUserName = "",
    this.sImgProfileUrl = "",
    this.sUserGitUrl = "",
    this.isChecked = false,
    this.listRepoData,
  });

  ModelUserRepo.fromJson(Map<String, dynamic> json) {
    sID = json['login'] ?? '';
    sUserGitUrl = json['url'] ?? '';
    sUserName = "";
    sImgProfileUrl = json['avatar_url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'login': sID,
      'url': sUserGitUrl,
      'avatar_url': sImgProfileUrl,
    };
  }
}

class ModelRepoData {
  int? id;
  String? nodeId;
  String? name;
  String? fullName;
  String? url;

  ModelRepoData({
    this.id,
    this.nodeId,
    this.name,
    this.fullName,
    this.url,
  });

  ModelRepoData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nodeId = json['node_id'];
    name = json['name'];
    fullName = json['fullName'];
    url = json['url'];
  }
}
