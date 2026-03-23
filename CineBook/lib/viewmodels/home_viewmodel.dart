import 'dart:async';
import 'package:flutter/material.dart';
import '../models/core_models.dart';
import '../services/database_service.dart';
import '../services/seed_service.dart';

class HomeViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;
  bool _showNowShowing = true;
  String? _errorMessage;

  List<Movie> _allMovies = [];
  StreamSubscription? _moviesSub;

  bool get isLoading => _isLoading;
  bool get showNowShowing => _showNowShowing;
  String? get errorMessage => _errorMessage;

  /// All movies unfiltered — used by MovieDetailsScreen to find any movie by id
  List<Movie> get allMovies => _allMovies;

  /// Movies for the currently selected toggle (Now Showing / Upcoming)
  List<Movie> get currentMovies =>
      _allMovies.where((m) => m.isNowShowing == _showNowShowing).toList();

  HomeViewModel() {
    _listenToMovies();
  }

  void toggleMovieType(bool isNowShowing) {
    _showNowShowing = isNowShowing;
    notifyListeners();
  }

  void _listenToMovies() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _moviesSub = _db.getMoviesStream().listen((movies) async {
      if (movies.isEmpty) {
        // Auto-seed empty database
        try {
          await SeedService().seedDatabase();
          // Stream will fire again with data after seed — keep loading
        } catch (e) {
          debugPrint('Seed failed: $e');
          _errorMessage = 'Could not load movies. Please check your connection.';
          _isLoading = false;
          notifyListeners();
        }
        return;
      }
      _allMovies = movies;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error fetching movies: $error');
      _errorMessage = 'Failed to load movies: $error';
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _moviesSub?.cancel();
    super.dispose();
  }
}
