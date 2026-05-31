import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_db_service.dart';

/// Service class that handles all HTTP communication with the Spring Boot backend.
/// Centralizes API calls so screens only need to call simple methods.
class ApiService {
  // For Web (Edge/Chrome) use localhost, for Android emulator use 10.0.2.2
  static const String baseUrl = 'http://localhost:8080/api';

  // ─────────────────────────────────────────────────
  //  AUTH ENDPOINTS
  // ─────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────
  //  MENU ENDPOINTS
  // ─────────────────────────────────────────────────

  /// Fetch all menu items from the backend.
  /// Calls GET /api/elements and returns a list of menu items.
  /// FALLBACK: If offline, returns cached menu from SQLite.
  static Future<List<Map<String, dynamic>>> getMenu() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult == ConnectivityResult.none;

    if (isOffline) {
      // Offline: Return cached menu
      final cached = await LocalDbService.getCachedMenu();
      if (cached.isNotEmpty) return cached;
      throw Exception('Hors ligne : Aucun menu en cache disponible.');
    }

    // Online: Fetch from API
    try {
      final url = Uri.parse('$baseUrl/elements');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final menuList = data.map((e) => e as Map<String, dynamic>).toList();
        
        // Cache the newly fetched menu
        await LocalDbService.cacheMenu(menuList);
        
        return menuList;
      } else {
        throw Exception('Erreur lors du chargement du menu');
      }
    } catch (e) {
      // Fallback on timeout/error
      final cached = await LocalDbService.getCachedMenu();
      if (cached.isNotEmpty) return cached;
      throw Exception('Erreur API/Cache: $e');
    }
  }

  // ─────────────────────────────────────────────────
  //  ORDER ENDPOINTS
  // ─────────────────────────────────────────────────

  /// Create a new order (Commande) for a client.
  /// Sends the client ID and list of element IDs.
  /// Returns the created order as a Map.
  static Future<Map<String, dynamic>> createOrder(
    int clientId,
    List<int> elementIds,
  ) async {
    final url = Uri.parse('$baseUrl/commandes');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'clientId': clientId,
        'elementIds': elementIds,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
          error['message'] ?? 'Erreur lors de la création de la commande');
    }
  }

  /// Fetch all orders for a specific client.
  /// Calls GET /api/commandes and filters by client ID.
  /// FALLBACK: If offline, returns cached orders from SQLite.
  static Future<List<Map<String, dynamic>>> getOrdersByClient(
      int clientId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult == ConnectivityResult.none;

    if (isOffline) {
      // Offline: Return cached orders
      final cached = await LocalDbService.getCachedOrders(clientId);
      if (cached.isNotEmpty) return cached;
      throw Exception('Hors ligne : Aucune commande en cache disponible.');
    }

    try {
      final url = Uri.parse('$baseUrl/commandes');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final filteredOrders = data
            .map((e) => e as Map<String, dynamic>)
            .where((o) => o['client'] != null && o['client']['id'] == clientId)
            .toList();

        // Cache the fetched orders
        await LocalDbService.cacheOrders(clientId, filteredOrders);

        return filteredOrders;
      } else {
        throw Exception('Erreur lors du chargement des commandes');
      }
    } catch (e) {
      final cached = await LocalDbService.getCachedOrders(clientId);
      if (cached.isNotEmpty) return cached;
      throw Exception('Erreur Commandes/Cache: $e');
    }
  }

  /// Fetch a specific order by ID.
  static Future<Map<String, dynamic>> getOrderById(int orderId) async {
    final url = Uri.parse('$baseUrl/commandes/$orderId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement de la commande');
    }
  }

  /// Cancel an order by updating its status to CANCELLED.
  static Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    final url = Uri.parse('$baseUrl/commandes/$orderId');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': 'CANCELLED',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de l\'annulation de la commande');
    }
  }

  // ─────────────────────────────────────────────────
  //  PROFILE ENDPOINTS
  // ─────────────────────────────────────────────────

  /// Update client profile information.
  static Future<Map<String, dynamic>> updateProfile({
    required int clientId,
    required String nom,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/clients/$clientId');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
          error['message'] ?? 'Erreur lors de la mise à jour du profil');
    }
  }

  /// Get client info by ID.
  static Future<Map<String, dynamic>> getClient(int clientId) async {
    final url = Uri.parse('$baseUrl/clients/$clientId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement du profil');
    }
  }
}
