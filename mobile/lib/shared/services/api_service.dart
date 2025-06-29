import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  static const String _baseUrl = 'http://localhost:3001'; // Development URL
  
  String get baseUrl => _baseUrl;
  
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET request
  Future<http.Response> get(String endpoint, {Map<String, String>? additionalHeaders}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = {...headers, ...?additionalHeaders};
    
    try {
      final response = await http.get(url, headers: requestHeaders);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint, 
    {Map<String, dynamic>? body, Map<String, String>? additionalHeaders}
  ) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = {...headers, ...?additionalHeaders};
    
    try {
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, 
    {Map<String, dynamic>? body, Map<String, String>? additionalHeaders}
  ) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = {...headers, ...?additionalHeaders};
    
    try {
      final response = await http.put(
        url,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(String endpoint, {Map<String, String>? additionalHeaders}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = {...headers, ...?additionalHeaders};
    
    try {
      final response = await http.delete(url, headers: requestHeaders);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Multipart request for file uploads
  Future<http.StreamedResponse> postMultipart(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files,
    {Map<String, String>? additionalHeaders}
  ) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);
    
    // Add headers (excluding Content-Type as it's set automatically for multipart)
    final requestHeaders = {'Accept': 'application/json', ...?additionalHeaders};
    request.headers.addAll(requestHeaders);
    
    // Add fields
    request.fields.addAll(fields);
    
    // Add files
    request.files.addAll(files);
    
    try {
      final response = await request.send();
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}