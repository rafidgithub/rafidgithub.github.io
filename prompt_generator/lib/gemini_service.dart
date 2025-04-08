import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey = "AIzaSyAAzYqSmCaarEouSJEN2leY3PZULVdgtRY";

  Future<void> getAnswer(
    String query, {
    required Function(String response) onSuccess,
  }) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Create a single and meaningful prompt for this query to ask other ai models. Only provide plain text. \n Start of Query: $query \n End of Query',
            }
          ]
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // print('Response: ${response.body}');
        final Map<String, dynamic> responseMap = json.decode(response.body);
        final String responseText =
            responseMap['candidates'][0]['content']['parts'][0]['text'];

        onSuccess(responseText);
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
