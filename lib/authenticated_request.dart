import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:verlichting/credentials.dart';

class AuthenticatedRequest {
  static const Map<String, String> defaultHeaders = {};

  static Future<http.Response> get(String path, { headers = defaultHeaders }) {
    return http.get(CONNECTION_INFO.host + path,
      headers: _addAuthentication(headers),
    );
  }
  static Future<http.Response> post(String path, { headers = defaultHeaders }) {
    return http.post(CONNECTION_INFO.host + path,
      headers: _addAuthentication(headers),
    );
  }

  static Map<String, String> _addAuthentication(Map<String, String> headers) {
    var basicAuth = 'Basic ' +
        base64Encode(utf8
            .encode('${CONNECTION_INFO.username}:${CONNECTION_INFO.password}'));

    var headersWithAuthentication = new Map<String, String>.from(headers);

    headersWithAuthentication[HttpHeaders.authorizationHeader] = basicAuth;

    return headersWithAuthentication;
  }

}