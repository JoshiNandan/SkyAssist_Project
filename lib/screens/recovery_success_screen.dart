// lib/screens/recovery_success_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/recovery_provider.dart';
import 'booking_lookup_screen.dart';
import 'fare_adjustment_slip_screen.dart';

class RecoverySuccessScreen extends StatelessWidget {
  const RecoverySuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecoveryProvider>();
    final result = provider.recoveryResult;
    final action = provider.pendingAction;

    final bool isPendingFareAdjustment =
        action == 'REBOOK' &&
        provider.recoveryStatus == 'PENDING_FARE_ADJUSTMENT';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isPendingFareAdjustment
              ? SingleChildScrollView(
                  child: _buildPendingFareAdjustmentBody(
                    context,
                    provider,
                    result,
                  ),
                )
              : _buildDefaultSuccessBody(context, provider, result, action),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DEFAULT SUCCESS (Refund / Support / Direct Rebook)
  // ---------------------------------------------------------------------------

  Widget _buildDefaultSuccessBody(
    BuildContext context,
    RecoveryProvider provider,
    Map<String, dynamic>? result,
    String? action,
  ) {
    final slip = provider.recoverySlip;
    final requestId = slip?['requestId'] as String?;
    final isRefund = action == 'REFUND';
    final isSupport = action == 'SUPPORT';
    final hasSlip = slip != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasSlip ? Icons.check_circle_outline : Icons.check_circle,
          color: AppColors.success,
          size: 80,
        ),
        const SizedBox(height: 24),
        Text(
          provider.successMessage ?? 'Request processed successfully!',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Direct rebook: show selected flight card
        if (action == 'REBOOK' && result != null && result.containsKey('selectedFlight'))
          _buildRebookedFlightCard(result['selectedFlight']),

        // Refund / Support / Rebook: show request reference chip
        if (hasSlip && requestId != null && requestId.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildRequestReference(requestId),
        ],

        // Rebook: View Slip button
        if (action == 'REBOOK' && hasSlip) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.receipt_long, size: 20),
              label: const Text('View Rebook Slip', style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: const BorderSide(color: AppColors.success),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FareAdjustmentSlipScreen()),
                );
              },
            ),
          ),
        ],

        // Refund: View Slip button
        if (isRefund && hasSlip) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.receipt_long, size: 20),
              label: const Text('View Refund Slip', style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: const BorderSide(color: AppColors.success),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FareAdjustmentSlipScreen()),
                );
              },
            ),
          ),
        ],

        // Support: View Slip button
        if (isSupport && hasSlip) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.receipt_long, size: 20),
              label: const Text('View Support Slip', style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FareAdjustmentSlipScreen()),
                );
              },
            ),
          ),
        ],

        const Spacer(),
        _buildBackToHomeButton(context, provider),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PENDING FARE ADJUSTMENT SUCCESS
  // ---------------------------------------------------------------------------

  Widget _buildPendingFareAdjustmentBody(
    BuildContext context,
    RecoveryProvider provider,
    Map<String, dynamic>? result,
  ) {
    final slip = provider.fareAdjustmentSlip;
    final requestId = slip?['requestId'] as String?;
    final selectedFlight = result?['selectedFlight'] as Map<String, dynamic>?;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Icon — informational amber
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppColors.warning,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Rebooking Request Created',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle / backend message
          Text(
            provider.successMessage ??
                'Additional fare adjustment is required before final ticket reissue.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.text.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Selected flight card
          if (selectedFlight != null) _buildRebookedFlightCard(selectedFlight),
          const SizedBox(height: 16),

          // Fare summary card
          _buildFareSummaryCard(provider),

          // Request reference
          if (requestId != null && requestId.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildRequestReference(requestId),
          ],

          const SizedBox(height: 12),

          // Help-desk note
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Please visit the airport support desk for fare collection and final ticket reissue.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.text.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Placeholder button — will navigate to slip screen in H3
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.receipt, size: 20),
              label: const Text(
                'View Fare Adjustment Slip',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FareAdjustmentSlipScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          _buildBackToHomeButton(context, provider),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Fare summary card
  // ---------------------------------------------------------------------------

  Widget _buildFareSummaryCard(RecoveryProvider provider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fare Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.text,
              ),
            ),
            const Divider(height: 20),
            if (provider.originalFare != null)
              _buildFareRow('Original Fare', '₹${provider.originalFare}'),
            if (provider.newFare != null)
              _buildFareRow('New Flight Fare', '₹${provider.newFare}'),
            if (provider.fareDifference != null) ...[
              const Divider(height: 16),
              _buildFareRow(
                'Additional Fare',
                '₹${provider.fareDifference}',
                highlight: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: highlight ? AppColors.warning : AppColors.text,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.warning : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Request reference chip
  // ---------------------------------------------------------------------------

  Widget _buildRequestReference(String requestId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tag, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ref: $requestId',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared widgets
  // ---------------------------------------------------------------------------

  Widget _buildRebookedFlightCard(Map<String, dynamic> flight) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Flight ${flight['flightNumber']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.text,
                  ),
                ),
                if (flight['label'] != null &&
                    flight['label'].toString().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      flight['label'],
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRoutePoint(flight['origin'], flight['departureTime']),
                const Icon(Icons.flight_takeoff, color: AppColors.softSage),
                _buildRoutePoint(flight['destination'], flight['arrivalTime']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutePoint(String city, String time) {
    return Column(
      children: [
        Text(
          city,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(time, style: const TextStyle(color: AppColors.text, fontSize: 14)),
      ],
    );
  }

  Widget _buildBackToHomeButton(
    BuildContext context,
    RecoveryProvider provider,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          provider.clearRecoveryFlow();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const BookingLookupScreen()),
            (route) => false,
          );
        },
        child: const Text(
          'Back to Home',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
