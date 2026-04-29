
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class APICall {

  static Map<String, String> requestHeaders = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };


  static Future<dynamic> getGitUsers({String sUserName = ""}) async {
    String sPath = "/users";
    if(sUserName.isNotEmpty){
      sPath += "/$sUserName";
    }
    var url = Uri(
      scheme: 'https',
      host: 'api.github.com',
      path: sPath,
    );
    if (kDebugMode) {
      print('$url');
    }
    var response = await http.get(
      url,
      headers: requestHeaders,
    );

    dynamic parsedData;
    if (response.statusCode == 200) {

      if(sUserName.isNotEmpty){
        parsedData = convert.jsonDecode(response.body);
      }else{
        parsedData = convert.jsonDecode(response.body);
      }

    } else {
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}.');
      }
    }

    return parsedData;
  }

  static Future<List<dynamic>> getGitUsersRepository(String sUserName) async {
    String sPath = "/users/$sUserName/repos";
    var url = Uri(
      scheme: 'https',
      host: 'api.github.com',
      path: sPath,
    );
    if (kDebugMode) {
      print('$url');
    }
    var response = await http.get(
      url,
      headers: requestHeaders,
    );

    List parsedList = [];
    if (response.statusCode == 200) {
      parsedList = convert.jsonDecode(response.body);

    } else {
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}.');
      }
    }

    return parsedList;
  }


}
