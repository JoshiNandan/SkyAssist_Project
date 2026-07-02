// lib/providers/recovery_provider.dart
import 'package:flutter/foundation.dart';

import '../models/alternate_flight_model.dart';
import '../models/booking_model.dart';
import '../models/recent_search_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class RecoveryProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final LocalStorageService _storage = LocalStorageService();

  BookingModel? currentBooking;
  List<RecentSearchModel> recentSearches = [];
  bool isLoading = false;
  String? errorMessage;

  // Part 2A state
  List<AlternateFlightModel> alternateFlights = [];
  String? pendingAction; // REBOOK / REFUND / SUPPORT
  String? selectedFlightId;
  String supportReason = "";

  // Part 2B state
  String? maskedOtpDestination;
  String? otpDebugCode;
  String? successMessage;
  Map<String, dynamic>? recoveryResult;

  // Part 3 — fare-adjustment rebook state
  String? recoveryStatus;
  int? fareDifference;
  int? originalFare;
  int? newFare;
  Map<String, dynamic>? fareAdjustmentSlip;

  // Refund / Support slip state
  Map<String, dynamic>? recoverySlip;

  void setPendingAction(String action) {
    pendingAction = action;
    notifyListeners();
  }

  void setSelectedFlight(String flightId) {
    selectedFlightId = flightId;
    notifyListeners();
  }

  void setSupportReason(String reason) {
    supportReason = reason;
    notifyListeners();
  }

  void clearRecoveryFlow() {
    alternateFlights = [];
    pendingAction = null;
    selectedFlightId = null;
    supportReason = "";
    errorMessage = null;
    maskedOtpDestination = null;
    otpDebugCode = null;
    successMessage = null;
    recoveryResult = null;
    recoveryStatus = null;
    fareDifference = null;
    originalFare = null;
    newFare = null;
    fareAdjustmentSlip = null;
    recoverySlip = null;
    notifyListeners();
  }

  Future<bool> fetchAlternateFlights() async {
    if (currentBooking == null) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      alternateFlights = await _api.getAlternateFlights(
        currentBooking!.bookingId,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestOtpForCurrentBooking() async {
    if (currentBooking == null) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.requestOtp(currentBooking!.bookingId);
      maskedOtpDestination = response['maskedDestination'];
      if (response.containsKey('otp')) {
        otpDebugCode = response['otp'].toString();
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtpCode(String otp) async {
    if (currentBooking == null) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.verifyOtp(currentBooking!.bookingId, otp);
      isLoading = false;
      notifyListeners();
      return response['otpVerified'] ?? false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> executePendingRecoveryAction() async {
    if (currentBooking == null) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> response;
      if (pendingAction == "REFUND") {
        response = await _api.requestRefund(currentBooking!.bookingId);
      } else if (pendingAction == "SUPPORT") {
        response = await _api.requestSupport(
          currentBooking!.bookingId,
          supportReason,
        );
      } else if (pendingAction == "REBOOK") {
        if (selectedFlightId == null) throw Exception("No flight selected");
        response = await _api.rebookFlight(
          currentBooking!.bookingId,
          selectedFlightId!,
        );
      } else {
        throw Exception("Unknown action");
      }

      recoveryResult = response;
      successMessage = response['message'];
      recoveryStatus = response['recoveryStatus'] as String?;

      // Extract fare-adjustment details when present (rebook only)
      if (pendingAction == "REBOOK" &&
          recoveryStatus == 'PENDING_FARE_ADJUSTMENT') {
        fareDifference = (response['fareDifference'] as num?)?.toInt();
        originalFare = (response['originalFare'] as num?)?.toInt();
        newFare = (response['newFare'] as num?)?.toInt();
        fareAdjustmentSlip = response['slip'] as Map<String, dynamic>?;
      }

      // Extract slip for direct rebook (equal/lower fare), refund, and support
      if ((pendingAction == "REBOOK" && recoveryStatus == 'REBOOKED') ||
          pendingAction == "REFUND" ||
          pendingAction == "SUPPORT") {
        recoverySlip = response['slip'] as Map<String, dynamic>?;
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadRecentSearches() async {
    recentSearches = await _storage.getRecentSearches();
    notifyListeners();
  }

  Future<bool> lookupBooking(String pnr, String lastName) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final booking = await _api.lookupBooking(pnr, lastName);
      currentBooking = booking;
      await _storage.saveRecentSearch(
        RecentSearchModel(pnr: pnr, lastName: lastName),
      );
      await loadRecentSearches();
      isLoading = false;
      notifyListeners();
      return true;
    } on BookingNotFoundException {
      errorMessage = 'No booking found for the entered PNR and last name.';
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> lookupFromRecent(RecentSearchModel search) async {
    return lookupBooking(search.pnr, search.lastName);
  }
}
