import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_colors.dart';
import '../models/core_models.dart';
import '../services/database_service.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({Key? key}) : super(key: key);

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  bool _showActive = true;

  @override
  Widget build(BuildContext context) {
    // Dynamically pull currently authenticated User ID
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('My Tickets'),
        ),
        body: Center(
          child: Text('Please log in to view your tickets.', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onBackground)),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Tickets', style: TextStyle(fontSize: 18)),
            Text('Your booking history', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: colorScheme.onSurfaceVariant)),
          ],
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: DatabaseService().getUserTicketsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading tickets: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final tickets = snapshot.data ?? [];
          
          // Split tickets into "History" vs "Upcoming" dynamically
          final now = DateTime.now().subtract(const Duration(hours: 3));
          final activeTickets = tickets.where((t) => t.date.isAfter(now)).toList();
          final pastTickets = tickets.where((t) => t.date.isBefore(now)).toList();

          final displayTickets = _showActive ? activeTickets : pastTickets;

          return Column(
            children: [
              Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showActive = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _showActive ? colorScheme.secondaryContainer : Colors.transparent, 
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text('Active (${activeTickets.length})', 
                              style: TextStyle(
                                color: _showActive ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showActive = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_showActive ? colorScheme.secondaryContainer : Colors.transparent, 
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text('Past (${pastTickets.length})', 
                              style: TextStyle(
                                color: !_showActive ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: displayTickets.isEmpty
                  ? Center(
                      child: Text(
                        _showActive ? 'No active tickets found. Book a movie now!' : 'No past booking history found.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayTickets.length,
                      itemBuilder: (context, index) {
                        return _buildTicketCard(context, displayTickets[index]);
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        context.push('/ticket-details', extra: ticket);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ticket.movie.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                        const SizedBox(height: 4),
                        Text('${ticket.cinema.name} - Hall 1', style: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(0.8), fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ticket.status == 'Pending Split Payment' ? colorScheme.errorContainer : colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(ticket.status == 'Pending Split Payment' ? Icons.hourglass_top : Icons.qr_code, size: 14, color: ticket.status == 'Pending Split Payment' ? colorScheme.onErrorContainer : colorScheme.onTertiaryContainer),
                        const SizedBox(width: 4),
                        Text(ticket.status == 'Pending Split Payment' ? 'Pending' : 'Ready', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ticket.status == 'Pending Split Payment' ? colorScheme.onErrorContainer : colorScheme.onTertiaryContainer)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                           Icon(Icons.calendar_today, size: 14, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${ticket.date.year}-${ticket.date.month.toString().padLeft(2, '0')}-${ticket.date.day.toString().padLeft(2, '0')}', 
                            style: TextStyle(color: colorScheme.onSurfaceVariant)
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(ticket.showtime.time, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.black12),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Seats', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Row(
                            children: ticket.seatNumbers.map((seat) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(4)),
                                child: Text(seat, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.primary)),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text('LKR ${ticket.totalAmount.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ref: ${ticket.id.substring(0, 15)}...', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(4)),
                        child: Text(ticket.showtime.format, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
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
