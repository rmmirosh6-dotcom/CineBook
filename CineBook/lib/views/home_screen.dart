import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/core_models.dart';
import '../services/seed_service.dart';
import 'cinema_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFFA020F0);
    const Color headerPurple = Color(0xFF5B0A95);
    const Color logoYellow = Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return CustomScrollView(
            slivers: [
              // Purple Header with Search
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    bottom: 24,
                    left: 20,
                    right: 20,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [headerPurple, primaryPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.movie_rounded, color: logoYellow, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'CineBook',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.confirmation_num_outlined, color: Colors.white, size: 22),
                                onPressed: () => context.push('/tickets'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.person_outline, color: Colors.white, size: 22),
                                onPressed: () => context.push('/profile'),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Search movies, genres...',
                            hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.black38, size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Location Picker
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: primaryPurple, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Colombo, Sri Lanka',
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Change',
                          style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Now Showing / Upcoming Toggle
              SliverToBoxAdapter(
                child: _buildToggleSwitch(context, viewModel),
              ),

              // Movie Grid
              if (viewModel.isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildMovieCard(context, viewModel.currentMovies[index]);
                      },
                      childCount: viewModel.currentMovies.length,
                    ),
                  ),
                ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggleSwitch(BuildContext context, HomeViewModel viewModel) {
    const Color primaryPurple = Color(0xFFA020F0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => viewModel.toggleMovieType(true),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: viewModel.showNowShowing ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: viewModel.showNowShowing
                        ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'Now Showing',
                      style: TextStyle(
                        fontWeight: viewModel.showNowShowing ? FontWeight.bold : FontWeight.w600,
                        color: viewModel.showNowShowing ? Colors.black87 : Colors.black45,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => viewModel.toggleMovieType(false),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: !viewModel.showNowShowing ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: !viewModel.showNowShowing
                        ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'Upcoming',
                      style: TextStyle(
                        fontWeight: !viewModel.showNowShowing ? FontWeight.bold : FontWeight.w600,
                        color: !viewModel.showNowShowing ? Colors.black87 : Colors.black45,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    const Color logoYellow = Color(0xFFFFC107);
    return GestureDetector(
      onTap: () {
        context.push('/movie/${movie.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      movie.posterUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.movie, color: Colors.black12, size: 40)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: logoYellow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            '${movie.rating}/10',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.genre,
                    style: const TextStyle(color: Colors.black45, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        movie.duration,
                        style: const TextStyle(color: Colors.black45, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
