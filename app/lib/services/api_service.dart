// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String _baseUrl = 'YOUR_CLOUDFLARE_WORKER_URL'; // Replace with your Cloudflare Worker URL

  Future<List<dynamic>> fetchData(String? accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/items'), //Example endpoint
        headers: {
          'Authorization': 'Bearer $accessToken', // Send the access token
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch data: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error during API call: $e');
      rethrow;
    }
  }

  //Add more API calls here
}