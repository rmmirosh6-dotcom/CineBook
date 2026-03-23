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
    return Scaffold(
      backgroundColor: AppColors.background,
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
        backgroundColor: AppColors.primary,
      ),
      appBar: AppBar(
        title: const Text('CineBook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Re-seeding Cinemas...')));
              await SeedService().seedDatabase();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cinemas Re-seeded!')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CinemaMapScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.confirmation_number_outlined),
            onPressed: () {
              context.push('/tickets');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search movies, genres...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.all(0),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // mock refresh
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text('Colombo, Sri Lanka', style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Change', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildToggleSwitch(context, viewModel),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildMovieCard(context, viewModel.currentMovies[index]);
                      },
                      childCount: viewModel.currentMovies.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleSwitch(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => viewModel.toggleMovieType(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: viewModel.showNowShowing ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: viewModel.showNowShowing
                        ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'Now Showing',
                      style: TextStyle(
                        fontWeight: viewModel.showNowShowing ? FontWeight.bold : FontWeight.normal,
                        color: viewModel.showNowShowing ? AppColors.textPrimary : AppColors.textSecondary,
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !viewModel.showNowShowing ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: !viewModel.showNowShowing
                        ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'Upcoming',
                      style: TextStyle(
                        fontWeight: !viewModel.showNowShowing ? FontWeight.bold : FontWeight.normal,
                        color: !viewModel.showNowShowing ? AppColors.textPrimary : AppColors.textSecondary,
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
    return GestureDetector(
      onTap: () {
        context.push('/movie/${movie.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                  ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: movie.posterUrl.startsWith('http')
                      ? Image.network(
                          movie.posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(Icons.movie, size: 48, color: Colors.white)),
                          ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Center(child: Icon(Icons.movie, size: 48, color: Colors.white)),
                        ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          movie.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            movie.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            movie.genre,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                movie.duration,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
