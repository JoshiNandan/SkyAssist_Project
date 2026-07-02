// lib/screens/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/recovery_provider.dart';
import 'recovery_success_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecoveryProvider>().requestOtpForCurrentBooking();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onVerify(RecoveryProvider provider) async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    final verified = await provider.verifyOtpCode(otp);
    if (verified) {
      final success = await provider.executePendingRecoveryAction();
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RecoverySuccessScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Action failed')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecoveryProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'We sent a one-time verification code to your registered contact.',
              style: TextStyle(fontSize: 16, color: AppColors.text),
              textAlign: TextAlign.center,
            ),
            if (provider.maskedOtpDestination != null) ...[
              const SizedBox(height: 10),
              Text(
                'OTP sent to ${provider.maskedOtpDestination}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'Enter 6-digit OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            if (provider.otpDebugCode != null) ...[
              const SizedBox(height: 10),
              Text(
                'Test OTP: ${provider.otpDebugCode}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: provider.isLoading ? null : () => _onVerify(provider),
              child: provider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Verify and Continue',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
