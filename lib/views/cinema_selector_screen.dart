import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../models/core_models.dart';
import 'cinema_map_screen.dart';
import '../services/database_service.dart';

class CinemaSelectorScreen extends StatelessWidget {
  final String movieId;
  const CinemaSelectorScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseService _db = DatabaseService();

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Column(
          children: const [
            Text('Velocity Strike', style: TextStyle(fontSize: 18)),
            Text('Action / Thriller', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDateChip('Today', true),
                _buildDateChip('Tomorrow', false),
                _buildDateChip('Mar 19', false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Colombo, Sri Lanka'),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CinemaMapScreen()));
                  },
                  icon: const Icon(Icons.near_me, size: 16),
                  label: const Text('Near me'),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Cinema>>(
              stream: _db.getCinemasStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading cinemas: ${snapshot.error}'));
                }
                final liveCinemas = snapshot.data ?? [];
                if (liveCinemas.isEmpty) {
                  return const Center(child: Text('No cinemas found. Please press the download button on the Home Screen.'));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: liveCinemas.length,
                  itemBuilder: (context, index) {
                    return _buildCinemaCard(context, liveCinemas[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {},
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: const StadiumBorder(),
    );
  }

  Widget _buildCinemaCard(BuildContext context, Cinema cinema) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cinema.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CinemaMapScreen(targetCinema: cinema)));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.map, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(child: Text(cinema.location, style: const TextStyle(color: AppColors.primary, fontSize: 13, decoration: TextDecoration.underline))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${cinema.distanceKm} km', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            const Text('Showtimes', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cinema.showtimes.map((s) => _buildShowtimeCard(context, cinema, s)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowtimeCard(BuildContext context, Cinema cinema, Showtime showtime) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        context.push('/seat-selection', extra: {
          'movieId': movieId,
          'cinema': cinema,
          'showtime': showtime,
        });
      },
      child: Container(
        width: 120, // Increased from 100 to fix layout overflow
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(showtime.time.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 4),
                Text(showtime.time.split(' ')[1], style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: showtime.format == 'IMAX' ? colorScheme.tertiaryContainer : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                showtime.format,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text('LKR ${showtime.price.toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${showtime.availableSeats} seats',
                  style: TextStyle(
                    fontSize: 10,
                    color: showtime.isFillingFast ? AppColors.error : AppColors.success,
                  ),
                ),
                if (showtime.isFillingFast) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Filling Fast', style: TextStyle(color: Colors.white, fontSize: 8)),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
