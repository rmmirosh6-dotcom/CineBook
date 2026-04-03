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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seeding database... Please wait.')),
          );
          try {
            await SeedService().seedDatabase();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Database seeded! Pull to refresh or wait a second.'), backgroundColor: Colors.green),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Database seeding failed! Please ensure Firestore is created.'), backgroundColor: Colors.red),
            );
          }
        },
        child: const Icon(Icons.download),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [headerPurple, colorScheme.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
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
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search movies, genres...',
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant.withOpacity(0.5), size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
                      Icon(Icons.location_on, color: colorScheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Colombo, Sri Lanka',
                          style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurface),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Change',
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => viewModel.toggleMovieType(true),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: viewModel.showNowShowing ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: viewModel.showNowShowing
                        ? [BoxShadow(color: colorScheme.shadow.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'Now Showing',
                      style: TextStyle(
                        fontWeight: viewModel.showNowShowing ? FontWeight.w600 : FontWeight.w500,
                        color: viewModel.showNowShowing ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
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
                    color: !viewModel.showNowShowing ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: !viewModel.showNowShowing
                        ? [BoxShadow(color: colorScheme.shadow.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'Upcoming',
                      style: TextStyle(
                        fontWeight: !viewModel.showNowShowing ? FontWeight.w600 : FontWeight.w500,
                        color: !viewModel.showNowShowing ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    const Color logoYellow = Color(0xFFFFC107);
    
    return GestureDetector(
      onTap: () {
        context.push('/movie/${movie.id}');
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      image: DecorationImage(
                        image: movie.posterUrl.startsWith('http') 
                          ? NetworkImage(movie.posterUrl) as ImageProvider 
                          : AssetImage(movie.posterUrl),
                        fit: BoxFit.cover,
                        onError: (_, __) {}, 
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: logoYellow,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.genre,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        movie.duration,
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
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
