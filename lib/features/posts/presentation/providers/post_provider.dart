// post_provider.dart
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/post_model.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

class PostProvider extends ChangeNotifier {
  final PostRepository repository;
  final SupabaseClient client;

  PostProvider(this.repository, this.client) {
    _posts = [];
    _isLoading = false;
    _error = null;
  }

  // ------------------------------
  // State
  // ------------------------------
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> get posts => _posts;

  Post? _currentPost;
  Post? get currentPost => _currentPost;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Multi-step form fields
  String _title = '';
  String get title => _title;
  setTitle(String val) {
    _title = val;
    notifyListeners();
  }

  String _description = '';
  String get description => _description;
  setDescription(String val) {
    _description = val;
    notifyListeners();
  }

  int _teamSize = 5;
  int get teamSize => _teamSize;
  setTeamSize(int val) {
    _teamSize = val;
    notifyListeners();
  }

  int _currentMembers = 1;
  int get currentMembers => _currentMembers;
  setCurrentMembers(int val) {
    _currentMembers = val;
    notifyListeners();
  }

  DateTime? _deadline;
  DateTime? get deadline => _deadline;
  setDeadline(DateTime val) {
    _deadline = val;
    notifyListeners();
  }

  String _duration = '';
  String get duration => _duration;
  setDuration(String val) {
    _duration = val;
    notifyListeners();
  }

  Map<String, bool> _selectedSkillsWithRequirement = {};
  Map<String, bool> get selectedSkillsWithRequirement => _selectedSkillsWithRequirement;
  List<String> get selectedSkills => _selectedSkillsWithRequirement.keys.toList();

  List<String> _lookingFor = [];
  List<String> get lookingFor => _lookingFor;
  addLookingFor(String role) {
    if (!_lookingFor.contains(role)) {
      _lookingFor.add(role);
      notifyListeners();
    }
  }
  removeLookingFor(String role) {
    _lookingFor.remove(role);
    notifyListeners();
  }

  String _postType = 'academic_project';
  String get postType => _postType;
  setPostType(String val) {
    _postType = val;
    notifyListeners();
  }

  final String _projectType = 'academic_project';
  String get projectType => _projectType;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  final int _totalSteps = 5;
  int get totalSteps => _totalSteps;

  nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  resetForm() {
    _currentStep = 0;
    _title = '';
    _description = '';
    _teamSize = 4;
    _currentMembers = 1;
    _deadline = null;
    _duration = '';
    _selectedSkillsWithRequirement = {};
    _lookingFor = [];
    _postType = 'academic_project';
    notifyListeners();
  }

  // ------------------------------
  // Internal helpers
  // ------------------------------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void _setPosts(List<Map<String, dynamic>> posts) {
    _posts = posts;
    notifyListeners();
  }

  final _uuid = Uuid();

  // Get All Posts
  Future<void> getPosts() async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    final result = await repository.getPosts();

    result.fold(
          (failure) => _setError(failure.message),
          (posts) => _setPosts(posts),
    );

    _setLoading(false);
  }

  // Create Post
  Future<void> createPost() async {
    final user = client.auth.currentUser;

    if (user == null) {
      _setError('User not authenticated');
      return;
    }

    // Validation
    if (_title.isEmpty) {
      _setError('Please enter a project title');
      return;
    }

    if (_description.isEmpty) {
      _setError('Please enter a project description');
      return;
    }

    if (_selectedSkillsWithRequirement.isEmpty) {
      _setError('Please select at least one required skill');
      return;
    }

    _setLoading(true);
    _setError(null);

    // Map the post type to a valid database category
    String dbCategory;
    String displayType;

    switch (_postType) {
      case 'fyp_group':
        dbCategory = 'academic_project';
        displayType = 'FYP Group';
        break;
      case 'project_partner':
        dbCategory = 'startup';
        displayType = 'Project Partner';
        break;
      default:
        dbCategory = _postType;
        displayType = _postType;
    }

    final postId = _uuid.v4();

    final post = Post(
      id: postId,
      title: _title,
      description: _description,
      postType: dbCategory,
      teamSize: _teamSize,
      currentTeamSize: _currentMembers,
      deadline: _deadline,
      duration: _duration.isNotEmpty ? _duration : 'Not specified',
      lookingFor: _lookingFor,
      selectedSkills: _selectedSkillsWithRequirement.keys.toList(),
      authorId: user.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      matchScore: 0,
      viewCount: 0,
      status: 'open',
      isPublished: true,
      projectDomain: displayType,
    );

    print('Selected skills with requirements: $_selectedSkillsWithRequirement');

    // First create the post
    final result = await repository.createPost(post);

    await result.fold(
          (failure) async {
        _setError(failure.message);
        _setLoading(false);
      },
          (createdPost) async {
        try {
          // After post is created successfully, add skills to post_skills table
          await _addSkillsToPost(postId);

          // ✅ Get or create project chat room using safe function
          await client.rpc('get_or_create_project_chat_room', params: {
            'p_post_id': postId,
          });

          print('✅ Project chat room created/retrieved for post: $postId');

          notifyListeners();
          resetForm();
          _setLoading(false);
        } catch (e) {
          _setError('Failed to create chat room: $e');
          _setLoading(false);
        }
      },
    );
  }

  // Helper method to add skills to post_skills table
  Future<void> _addSkillsToPost(String postId) async {
    try {
      // First, get all skill IDs from the skills table
      final skillsResponse = await client
          .from('skills')
          .select('id, name');

      // Create a map of skill name to ID
      final Map<String, String> skillIdMap = {};
      for (var skill in skillsResponse) {
        skillIdMap[skill['name'] as String] = skill['id'] as String;
      }

      // Prepare post_skills entries
      final List<Map<String, dynamic>> postSkillsEntries = [];

      for (var entry in _selectedSkillsWithRequirement.entries) {
        final skillName = entry.key;
        final isRequired = entry.value;

        final skillId = skillIdMap[skillName];
        if (skillId != null) {
          postSkillsEntries.add({
            'post_id': postId,
            'skill_id': skillId,
            'is_required': isRequired,
            'created_at': DateTime.now().toIso8601String(),
          });
        } else {
          print('Skill not found: $skillName');
        }
      }

      // Insert all skills at once
      if (postSkillsEntries.isNotEmpty) {
        await client
            .from('post_skills')
            .insert(postSkillsEntries);

        print('Added ${postSkillsEntries.length} skills to post_skills table');
      }
    } catch (e) {
      print('Error adding skills to post: $e');
      rethrow;
    }
  }

  // Delete Post
  Future<void> deletePost(String postId) async {
    _setLoading(true);

    final result = await repository.deletePost(postId);

    result.fold(
          (failure) => _setError(failure.message),
          (_) {
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  // Edit Post
  Future<void> editPost(Post post) async {
    _setLoading(true);

    final result = await repository.editPost(post);

    result.fold(
          (failure) => _setError(failure.message),
          (updatedPost) {
        // Update logic if needed
      },
    );

    _setLoading(false);
  }

  // Get Single Post
  Future<void> getPost(String postId) async {
    _setLoading(true);

    final result = await repository.fetchPostById(postId);
    print(result);

    if (result == null) {
      _setError('Post not found');
      return;
    }
    _currentPost = PostModel.fromJson(result);
    notifyListeners();

    _setLoading(false);
  }

  // Filter Posts
  Future<void> filterPosts(String filter) async {
    if (_isLoading) return;

    _setLoading(true);

    final result = await repository.filterPosts(filter);

    _setLoading(false);
  }

  // Search Posts
  Future<void> searchPosts(String query) async {
    if (_isLoading) return;

    _setLoading(true);

    final result = await repository.searchPosts(query);

    _setLoading(false);
  }

  Future<List<String>> getSkills() async {
    final result = await repository.skills();
    return result;
  }

  bool isSkillMandatory(String skill) {
    return _selectedSkillsWithRequirement[skill] ?? false;
  }

  void addSkillWithRequirement(String skill, bool isMandatory) {
    if (!_selectedSkillsWithRequirement.containsKey(skill)) {
      _selectedSkillsWithRequirement[skill] = isMandatory;
      notifyListeners();
    }
  }

  void toggleSkill(String skill) {
    if (_selectedSkillsWithRequirement.containsKey(skill)) {
      _selectedSkillsWithRequirement.remove(skill);
    }
    notifyListeners();
  }

  Map<String, bool> getSelectedSkillsWithRequirement() {
    return Map.from(_selectedSkillsWithRequirement);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}