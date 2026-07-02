// lib/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://skyassist-gwfb.onrender.com';
  static const String bookingLookup = '/api/bookings/lookup';
  static String alternateFlights(String bookingId) =>
      '/api/recovery/$bookingId/alternatives';

  static const String requestOtp = '/api/recovery/request-otp';
  static const String verifyOtp = '/api/recovery/verify-otp';
  static const String refund = '/api/recovery/refund';
  static const String support = '/api/recovery/support';
  static const String rebook = '/api/recovery/rebook';
}
