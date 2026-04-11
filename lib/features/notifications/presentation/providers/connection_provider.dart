// lib/features/connections/presentation/providers/connection_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectionProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _pendingConnectionRequests = [];
  List<Map<String, dynamic>> _pendingApplicationRequests = [];
  bool _isLoadingConnections = false;
  bool _isLoadingApplications = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get pendingConnectionRequests => _pendingConnectionRequests;
  List<Map<String, dynamic>> get pendingApplicationRequests => _pendingApplicationRequests;
  bool get isLoadingConnections => _isLoadingConnections;
  bool get isLoadingApplications => _isLoadingApplications;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  // Load pending connection requests
  Future<void> loadPendingConnectionRequests() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoadingConnections = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user's profile
      final profile = await _supabase
          .from('profiles')
          .select('connections_requests')
          .eq('id', userId)
          .single();
      print("Profile:$profile");


      List<String> requesterIds = List<String>.from(profile['connections_requests'] ?? []);

      if (requesterIds.isEmpty) {
        _pendingConnectionRequests = [];
      } else {
        // Get full profiles of requesters
        final requesters = await _supabase
            .from('profiles')
            .select()
            .inFilter('id', requesterIds);

        _pendingConnectionRequests = List<Map<String, dynamic>>.from(requesters);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingConnections = false;
      notifyListeners();
    }
  }

  // Load pending application requests
  Future<void> loadPendingApplicationRequests() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoadingApplications = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get all posts by current user
      final posts = await _supabase
          .from('posts')
          .select('id')
          .eq('author_id', userId);
      // print("Posts:$posts");


      final postIds = posts.map((p) => p['id'] as String).toList();

      if (postIds.isEmpty) {
        _pendingApplicationRequests = [];
      } else {
        // Get pending applications for these posts
        final applications = await _supabase
            .from('applications')
            .select('*, profiles(*)')
            .inFilter('post_id', postIds)
            .eq('status', 'pending');
        // print("Applications:$applications");


        _pendingApplicationRequests = List<Map<String, dynamic>>.from(applications);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingApplications = false;
      notifyListeners();
    }
  }

  // Accept connection request
  Future<bool> acceptConnectionRequest(String requesterId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      // Add to connections and remove from requests
      final response=await _supabase.rpc('accept_connection_request', params: {
        'p_user_id': userId,
        'p_requester_id': requesterId,
      });

      await loadPendingConnectionRequests();
      return response == true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reject connection request
  Future<bool> rejectConnectionRequest(String requesterId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      // Remove from requests only
      final currentRequests = await _supabase
          .from('profiles')
          .select('connections_requests')
          .eq('id', userId)
          .single();

      List<dynamic> requests = currentRequests['connections_requests'] ?? [];
      requests.remove(requesterId);

      await _supabase
          .from('profiles')
          .update({'connections_requests': requests})
          .eq('id', userId);

      await loadPendingConnectionRequests();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Accept application
  Future<bool> acceptApplication(String applicationId) async {
    try {
      await _supabase
          .from('applications')
          .update({'status': 'accepted'})
          .eq('id', applicationId);

      await loadPendingApplicationRequests();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reject application
  Future<bool> rejectApplication(String applicationId) async {
    try {
      await _supabase
          .from('applications')
          .update({'status': 'rejected'})
          .eq('id', applicationId);

      await loadPendingApplicationRequests();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}