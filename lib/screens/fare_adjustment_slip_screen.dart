// lib/screens/fare_adjustment_slip_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/booking_model.dart';
import '../providers/recovery_provider.dart';
import 'booking_lookup_screen.dart';

class FareAdjustmentSlipScreen extends StatelessWidget {
  const FareAdjustmentSlipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecoveryProvider>();
    final booking = provider.currentBooking;

    // Resolve the active slip — rebook uses fareAdjustmentSlip,
    // refund/support use recoverySlip.
    final slip = provider.fareAdjustmentSlip ?? provider.recoverySlip;
    final slipType = (slip?['type'] as String? ?? provider.pendingAction ?? '').toUpperCase();

    if (booking == null || slip == null) {
      return Scaffold(
        appBar: _buildAppBar(slipType),
        backgroundColor: AppColors.background,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.warning),
                SizedBox(height: 20),
                Text('Slip details are not available.', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    final result = provider.recoveryResult;
    final selectedFlight = (result?['selectedFlight'] ?? slip['selectedFlight']) as Map<String, dynamic>?;
    final isRebook = slipType == 'REBOOK' || slipType.contains('REBOOK');
    final isRefund = slipType == 'REFUND';
    final isSupport = slipType == 'SUPPORT';
    final isFareAdj = isRebook && provider.fareAdjustmentSlip != null;

    return Scaffold(
      appBar: _buildAppBar(slipType, isFareAdj: isFareAdj),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(slip, slipType, isFareAdj: isFareAdj),
            const SizedBox(height: 16),

            _buildSectionCard(
              icon: Icons.person_outline,
              title: 'Passenger & Booking',
              child: _buildPassengerDetails(booking),
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              icon: Icons.flight_outlined,
              title: 'Original Journey',
              child: _buildOriginalJourney(booking),
            ),
            const SizedBox(height: 12),

            // Rebook: show alternate flight section
            if (isRebook) ...[
              _buildSectionCard(
                icon: Icons.flight_takeoff,
                title: 'Requested Alternate Flight',
                child: selectedFlight != null
                    ? _buildAlternateFlight(selectedFlight)
                    : _buildUnavailable(),
              ),
              const SizedBox(height: 12),
            ],

            // Rebook with fare diff: show fare summary
            if (isRebook && provider.fareAdjustmentSlip != null) ...[
              _buildSectionCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Fare Summary',
                child: _buildFareSummary(provider),
              ),
              const SizedBox(height: 12),
            ],

            // Refund: show refund details section
            if (isRefund) ...[
              _buildSectionCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Refund Details',
                child: _buildRefundDetails(slip, booking),
              ),
              const SizedBox(height: 12),
            ],

            // Support: show support details section
            if (isSupport) ...[
              _buildSectionCard(
                icon: Icons.headset_mic_outlined,
                title: 'Support Request Details',
                child: _buildSupportDetails(slip, provider),
              ),
              const SizedBox(height: 12),
            ],

            _buildSectionCard(
              icon: Icons.tag,
              title: 'Request Reference',
              child: _buildRequestReference(slip),
            ),
            const SizedBox(height: 16),

            _buildNote(slip),
            const SizedBox(height: 24),

            SizedBox(
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
                child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  AppBar _buildAppBar(String slipType, {bool isFareAdj = false}) {
    final title = slipType == 'REFUND'
        ? 'Refund Request Slip'
        : slipType == 'SUPPORT'
            ? 'Support Request Slip'
            : isFareAdj
                ? 'Fare Adjustment Slip'
                : 'Rebook Confirmation Slip';
    return AppBar(
      backgroundColor: AppColors.primary,
      title: Text(title),
      elevation: 0,
    );
  }

  // ── Header banner ───────────────────────────────────────────────────────────
  Widget _buildHeader(Map<String, dynamic> slip, String slipType, {bool isFareAdj = false}) {
    final isRefund = slipType == 'REFUND';
    final isSupport = slipType == 'SUPPORT';

    final Color accentColor = isRefund
        ? AppColors.success
        : isSupport
            ? AppColors.primary
            : isFareAdj
                ? AppColors.warning
                : AppColors.success;

    final IconData icon = isRefund
        ? Icons.account_balance_wallet_outlined
        : isSupport
            ? Icons.headset_mic_outlined
            : isFareAdj
                ? Icons.receipt_long
                : Icons.flight_takeoff;

    final String title = isRefund
        ? 'Refund Request Slip'
        : isSupport
            ? 'Support Request Slip'
            : isFareAdj
                ? 'Fare Adjustment Slip'
                : 'Rebook Confirmation Slip';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            slip['instruction'] as String? ?? '',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.text.withValues(alpha: 0.65),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Passenger details ───────────────────────────────────────────────────────
  Widget _buildPassengerDetails(BookingModel booking) {
    return Column(
      children: [
        _dataRow('Passenger', booking.passengerName),
        _dataRow('Booking ID', booking.bookingId),
        _dataRow('PNR', booking.pnr),
        _dataRow('Route', booking.route),
        _dataRow('Travel Date', booking.travelDate),
      ],
    );
  }

  // ── Original journey ────────────────────────────────────────────────────────
  Widget _buildOriginalJourney(BookingModel booking) {
    if (booking.segments.isEmpty) return _buildUnavailable();
    final seg = booking.segments.first;
    return Column(
      children: [
        _dataRow('Flight', seg.flightNumber),
        _routeRow(seg.origin, seg.destination),
        _dataRow('Scheduled Departure', seg.scheduledDep),
        _dataRow('Scheduled Arrival', seg.scheduledArr),
        if (booking.disruption != null && booking.disruption!.label.isNotEmpty)
          _dataRow('Status', booking.disruption!.label),
      ],
    );
  }

  // ── Alternate flight (rebook only) ──────────────────────────────────────────
  Widget _buildAlternateFlight(Map<String, dynamic> flight) {
    final label = flight['label']?.toString() ?? '';
    return Column(
      children: [
        _dataRow('Flight', flight['flightNumber']?.toString() ?? '—'),
        _routeRow(
          flight['origin']?.toString() ?? '—',
          flight['destination']?.toString() ?? '—',
        ),
        _dataRow('Departure', flight['departureTime']?.toString() ?? '—'),
        _dataRow('Arrival', flight['arrivalTime']?.toString() ?? '—'),
        if (label.isNotEmpty) _dataRow('Type', label),
      ],
    );
  }

  // ── Fare summary (rebook with fare diff only) ───────────────────────────────
  Widget _buildFareSummary(RecoveryProvider provider) {
    return Column(
      children: [
        _dataRow('Original Fare', provider.originalFare != null ? '₹${provider.originalFare}' : '—'),
        _dataRow('New Flight Fare', provider.newFare != null ? '₹${provider.newFare}' : '—'),
        const Divider(height: 20),
        _dataRow(
          'Additional Fare Required',
          provider.fareDifference != null ? '₹${provider.fareDifference}' : '—',
          highlight: true,
        ),
      ],
    );
  }

  // ── Refund details ──────────────────────────────────────────────────────────
  Widget _buildRefundDetails(Map<String, dynamic> slip, BookingModel booking) {
    return Column(
      children: [
        _dataRow('Request Type', 'Refund'),
        _dataRow('Status', slip['status']?.toString() ?? 'REQUESTED'),
        _dataRow('Booking ID', slip['bookingId']?.toString() ?? booking.bookingId),
      ],
    );
  }

  // ── Support details ─────────────────────────────────────────────────────────
  Widget _buildSupportDetails(Map<String, dynamic> slip, RecoveryProvider provider) {
    return Column(
      children: [
        _dataRow('Request Type', 'Support'),
        _dataRow('Status', slip['status']?.toString() ?? 'OPEN'),
        if (provider.supportReason.isNotEmpty)
          _dataRow('Reason', provider.supportReason),
      ],
    );
  }

  // ── Request reference ───────────────────────────────────────────────────────
  Widget _buildRequestReference(Map<String, dynamic> slip) {
    final requestId = slip['requestId']?.toString() ?? '—';
    final generatedAt = slip['generatedAt']?.toString() ?? '—';
    final displayDate = generatedAt.contains('T')
        ? generatedAt.replaceFirst('T', '  ').replaceAll('Z', ' UTC').trim()
        : generatedAt;
    return Column(
      children: [
        _dataRow('Request ID', requestId),
        _dataRow('Generated At', displayDate),
      ],
    );
  }

  // ── Bottom note ─────────────────────────────────────────────────────────────
  Widget _buildNote(Map<String, dynamic> slip) {
    final instruction = slip['instruction'] as String? ??
        'Please keep this reference for further communication.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card wrapper ────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  // ── Data row ────────────────────────────────────────────────────────────────
  Widget _dataRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: constraints.maxWidth * 0.38,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: AppColors.text.withValues(alpha: 0.6)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                    color: highlight ? AppColors.warning : AppColors.text,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Route row ───────────────────────────────────────────────────────────────
  Widget _routeRow(String origin, String destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              origin,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.arrow_forward, size: 18, color: AppColors.softSage),
          ),
          Flexible(
            child: Text(
              destination,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailable() {
    return Text(
      'Details unavailable',
      style: TextStyle(fontSize: 13, color: AppColors.text.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
    );
  }
}
