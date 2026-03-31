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
    const Color primaryPurple = Color(0xFFA020F0);
    const Color headerPurple = Color(0xFF5B0A95);
    const Color logoYellow = Color(0xFFFFC107);
    const Color infoGrey = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [headerPurple, primaryPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Velocity Strike', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Action / Thriller', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Date Picker
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDateChip('Today', true),
                _buildDateChip('Tomorrow', false),
                _buildDateChip('Mar 19', false),
              ],
            ),
          ),
          
          // Location Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: primaryPurple),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Colombo, Sri Lanka',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/cinema-map'),
                  icon: const Icon(Icons.near_me, size: 16, color: primaryPurple),
                  label: const Text('Near me', style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Cinema>>(
              stream: DatabaseService().getCinemasStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final liveCinemas = snapshot.data ?? [];
                if (liveCinemas.isEmpty) {
                  return const Center(child: Text('No cinemas found. Please seed the database from Home.'));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    const Color primaryPurple = Color(0xFFA020F0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? Colors.white : Colors.white24),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, size: 16, color: isSelected ? primaryPurple : Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryPurple : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaCard(BuildContext context, Cinema cinema) {
    const Color primaryPurple = Color(0xFFA020F0);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cinema.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 6),
                      Text(cinema.location, style: const TextStyle(color: Colors.black45, fontSize: 13)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/cinema-map', extra: cinema),
                  child: Tooltip(
                    message: 'View on Map',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text('${cinema.distanceKm} km', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Showtimes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: cinema.showtimes.map((s) => _buildShowtimeCard(context, cinema, s)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowtimeCard(BuildContext context, Cinema cinema, Showtime showtime) {
    const Color primaryPurple = Color(0xFFA020F0);
    const Color logoYellow = Color(0xFFFFC107);

    return GestureDetector(
      onTap: () {
        context.push('/seat-selection', extra: {
          'movieId': movieId,
          'cinema': cinema,
          'showtime': showtime,
        });
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 92) / 2, // 2 items per row
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(text: showtime.time.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const TextSpan(text: ' '),
                      TextSpan(text: showtime.time.split(' ')[1], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    showtime.format,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('LKR ${showtime.price.toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${showtime.availableSeats} seats',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: showtime.isFillingFast ? const Color(0xFFDC2626) : const Color(0xFF059669),
                  ),
                ),
                if (showtime.isFillingFast)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
                    child: const Text('Filling Fast', style: TextStyle(color: Color(0xFFDC2626), fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
