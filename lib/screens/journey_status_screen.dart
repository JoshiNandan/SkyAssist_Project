// lib/screens/journey_status_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/booking_model.dart';
import '../providers/recovery_provider.dart';
import '../widgets/booking_summary_card.dart';
import 'alternate_flights_screen.dart';
import 'refund_screen.dart';
import 'support_screen.dart';

class JourneyStatusScreen extends StatelessWidget {
  const JourneyStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecoveryProvider>();
    final booking = provider.currentBooking;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(AppStrings.journeyTitle),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: booking == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flight_outlined,
                    size: 48,
                    color: AppColors.softSage.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppStrings.emptyBooking,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.text.withValues(alpha: 0.55),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BookingSummaryCard(booking: booking),
                  const SizedBox(height: 20),
                  if (booking.disruption != null) ...[
                    _buildDisruptionCard(booking.disruption!),
                    const SizedBox(height: 24),
                  ],

                  // Flight Segments section header
                  _buildSectionHeader(
                    icon: Icons.flight_takeoff_rounded,
                    title: 'Flight Segments',
                  ),
                  const SizedBox(height: 14),
                  ...booking.segments.map(
                    (segment) => _buildSegmentCard(segment),
                  ),

                  if (booking.disruption != null) ...[
                    const SizedBox(height: 28),
                    // Recovery Options section header
                    _buildSectionHeader(
                      icon: Icons.support_agent_rounded,
                      title: 'Recovery Options',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose how you\'d like to proceed with your disrupted booking.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.text.withValues(alpha: 0.5),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Primary action — Rebook
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                        label: const Text(
                          'Rebook Alternate Flight',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        onPressed: () {
                          if (!(booking.eligibleActions.contains('REBOOK'))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You are not eligible for rebooking on this booking.'),
                              ),
                            );
                            return;
                          }
                          provider.clearRecoveryFlow();
                          provider.setPendingAction("REBOOK");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AlternateFlightsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Secondary action — Refund
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.account_balance_wallet_outlined, size: 19),
                        label: const Text(
                          'Request Refund',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        onPressed: () {
                          if (!(booking.eligibleActions.contains('REFUND'))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You are not eligible for a refund on this booking.'),
                              ),
                            );
                            return;
                          }
                          provider.clearRecoveryFlow();
                          provider.setPendingAction("REFUND");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RefundScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tertiary action — Support
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.headset_mic_outlined, size: 19),
                        label: const Text(
                          'Contact Support',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: () {
                          if (!(booking.eligibleActions.contains('SUPPORT'))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You are not eligible for support on this booking.'),
                              ),
                            );
                            return;
                          }
                          provider.clearRecoveryFlow();
                          provider.setPendingAction("SUPPORT");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SupportScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
    );
  }

  // --- Section header helper ---
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.text.withValues(alpha: 0.45)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text.withValues(alpha: 0.8),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  // --- Disruption banner ---
  Widget _buildDisruptionCard(DisruptionInfo disruption) {
    // Choose colors based on severity
    final isCancelled = disruption.type.toLowerCase() == 'cancellation' ||
        disruption.label.toLowerCase().contains('cancelled');
    final accentColor = isCancelled ? AppColors.error : AppColors.warning;

    return Container(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  isCancelled
                      ? Icons.cancel_outlined
                      : Icons.warning_amber_rounded,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disruption.label,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (disruption.reason.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        disruption.reason,
                        style: TextStyle(
                          color: accentColor.withValues(alpha: 0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              disruption.message,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.75),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Segment card ---
  Widget _buildSegmentCard(FlightSegment segment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Top row: flight number + status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.airlines_rounded,
                        size: 18,
                        color: AppColors.text.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        segment.flightNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.text,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      segment.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(
                        segment.status,
                      ).withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    segment.status,
                    style: TextStyle(
                      color: _getStatusColor(segment.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Divider
            Divider(
              color: AppColors.softSage.withValues(alpha: 0.25),
              height: 1,
            ),
            const SizedBox(height: 16),
            // Route row
            Row(
              children: [
                Expanded(
                  child: _buildTimeColumn(
                    segment.origin,
                    segment.scheduledDep,
                    segment.updatedDep,
                    'Departure',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Icon(
                        Icons.flight_takeoff_rounded,
                        color: AppColors.softSage,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 1,
                        color: AppColors.softSage.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildTimeColumn(
                    segment.destination,
                    segment.scheduledArr,
                    segment.updatedArr,
                    'Arrival',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(
    String location,
    String scheduled,
    String? updated,
    String label,
  ) {
    final schedTime = _formatTime(scheduled);
    final updTime = updated != null ? _formatTime(updated) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.text.withValues(alpha: 0.4),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        if (updTime != null && updTime != schedTime) ...[
          Text(
            schedTime,
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey.withValues(alpha: 0.6),
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            updTime,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.warning,
              fontSize: 15,
            ),
          ),
        ] else ...[
          Text(
            schedTime,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.75),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      if (dateTimeStr.contains('T')) {
        // Handle ISO format: 2026-07-03T10:00:00+05:30 -> 10:00
        return dateTimeStr.split('T')[1].substring(0, 5);
      } else if (dateTimeStr.contains(' ')) {
        // Handle space format: 2026-07-03 10:00 -> 10:00
        return dateTimeStr.split(' ')[1].substring(0, 5);
      }
    } catch (_) {}
    return dateTimeStr;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return AppColors.success;
      case 'delayed':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.text;
    }
  }
}
