import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service class that handles all HTTP communication with the Spring Boot backend.
/// Centralizes API calls so screens only need to call simple methods.
class ApiService {
  // For Web (Edge/Chrome) use localhost, for Android emulator use 10.0.2.2
  static const String baseUrl = 'http://localhost:8080/api';

  /// Register a new client.
  /// Sends [nom], [email], and [password] to the backend.
  /// Returns the response body as a Map on success, or throws an exception.
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/clients/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erreur lors de l\'inscription');
    }
  }

  /// Login an existing client.
  /// Sends [email] and [password] to the backend.
  /// Returns the client data as a Map on success, or throws an exception.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/clients/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Email ou mot de passe incorrect');
    }
  }

  /// Fetch all menu items from the backend.
  /// Calls GET /api/elements and returns a list of menu items.
  static Future<List<Map<String, dynamic>>> getMenu() async {
    final url = Uri.parse('$baseUrl/elements');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement du menu');
    }
  }
}
