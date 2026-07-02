// lib/services/api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/alternate_flight_model.dart';
import '../models/booking_model.dart';

class BookingNotFoundException implements Exception {}

class ApiService {
  Future<BookingModel> lookupBooking(String pnr, String lastName) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.bookingLookup}',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'pnr': pnr, 'lastName': lastName}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final bookingJson = data['booking'] as Map<String, dynamic>?;
      if (bookingJson == null) {
        throw Exception('Booking data missing in API response');
      }
      return BookingModel.fromJson(bookingJson);
    } else if (response.statusCode == 404) {
      throw BookingNotFoundException();
    } else {
      throw Exception(
        'Failed to fetch booking (status ${response.statusCode})',
      );
    }
  }

  Future<List<AlternateFlightModel>> getAlternateFlights(
    String bookingId,
  ) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.alternateFlights(bookingId)}',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final alternatives = data['alternatives'] as List<dynamic>?;

      if (alternatives == null) {
        throw Exception('No alternate flights found in API response');
      }

      return alternatives
          .map(
            (json) =>
                AlternateFlightModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(
        'Failed to fetch alternate flights (status ${response.statusCode})',
      );
    }
  }

  Future<Map<String, dynamic>> requestOtp(String bookingId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.requestOtp}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'bookingId': bookingId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to request OTP (status ${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String bookingId, String otp) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyOtp}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'bookingId': bookingId, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify OTP (status ${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> requestRefund(String bookingId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refund}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'bookingId': bookingId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to request refund (status ${response.statusCode})',
      );
    }
  }

  Future<Map<String, dynamic>> requestSupport(
    String bookingId,
    String reason,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.support}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'bookingId': bookingId, 'reason': reason}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to request support (status ${response.statusCode})',
      );
    }
  }

  Future<Map<String, dynamic>> rebookFlight(
    String bookingId,
    String selectedFlightId,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.rebook}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bookingId': bookingId,
        'selectedFlightId': selectedFlightId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to rebook flight (status ${response.statusCode})',
      );
    }
  }
}
