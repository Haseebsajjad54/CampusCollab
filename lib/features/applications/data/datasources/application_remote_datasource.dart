import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';

class ApplicationRemoteDataSource {
  final SupabaseClient supabaseClient;

  ApplicationRemoteDataSource({
    required this.supabaseClient,
  });

  /// Submit new application
  Future<Application> submitApplication({
    required String postId,
    required String message,
  }) async {
    final user = supabaseClient.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final response = await supabaseClient
        .from('applications')
        .insert({
      'post_id': postId,
      'applicant_id': user.id,
      'message': message,
      'status': 'pending',
    })
        .select()
        .single();

    return Application.fromJson(response);
  }

  /// Get applications sent by current user
  Future<List<Application>> getSentApplications() async {
    final user = supabaseClient.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final response = await supabaseClient
        .from('applications')
        .select()
        .eq('applicant_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Application.fromJson(json))
        .toList();
  }

  /// Get applications received (applications for posts owned by user)
  Future<List<Application>> getReceivedApplications() async {
    final user = supabaseClient.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final response = await supabaseClient
        .from('applications')
        .select()
        .eq('owner_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Application.fromJson(json))
        .toList();
  }

  /// Get application by ID
  Future<Application> getApplicationById(String applicationId) async {
    final response = await supabaseClient
        .from('applications')
        .select()
        .eq('id', applicationId)
        .single();

    return Application.fromJson(response);
  }

  /// Update application status
  Future<Application> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? responseMessage,
  }) async {
    final response = await supabaseClient
        .from('applications')
        .update({
      'status': status,
      'response_message': responseMessage,
    })
        .eq('id', applicationId)
        .select()
        .single();

    return Application.fromJson(response);
  }

  /// Withdraw application
  Future<void> withdrawApplication(String applicationId) async {
    await supabaseClient
        .from('applications')
        .delete()
        .eq('id', applicationId);
  }

  /// Get applications for specific post
  Future<List<Application>> getApplicationsForPost(
      String postId,
      ) async {
    final response = await supabaseClient
        .from('applications')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Application.fromJson(json))
        .toList();
  }
}
