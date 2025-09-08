import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rit_chat/presentation/screens/home/home_screen.dart';

class VerifyEmailScreens extends StatefulWidget {
  final String fullName;
  final String email;
  final String rollNumber;
  final String department;
  final String year;
  final String phoneNumber;
  final String dob;
  final String role; // 🔹 Added role field

  const VerifyEmailScreens({
    super.key,
    required this.fullName,
    required this.email,
    required this.rollNumber,
    required this.department,
    required this.year,
    required this.phoneNumber,
    required this.dob,
    required this.role, // 🔹 Added role field
  });

  @override
  State<VerifyEmailScreens> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreens> {
  bool _isChecking = false;
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verification email resent!"),
            backgroundColor: Colors.green,
          ),
        );
        _startCountdown();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      if (user != null && user.emailVerified) {
        // 🔹 Prepare Firestore user data based on role
        final Map<String, dynamic> userData = {
          "fullName": widget.fullName,
          "email": widget.email,
          "role": widget.role,
          "department": widget.department,
          "phoneNumber": widget.phoneNumber,
          "createdAt": DateTime.now().toIso8601String(),
          "emailVerified": true,
        };

        if (widget.role == "Student") {
          userData.addAll({
            "rollNumber": widget.rollNumber,
            "year": widget.year,
            "dob": widget.dob,
          });
        }

        // 🔹 Save to Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email not verified yet."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsRemaining == 0;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              "Verify your Email",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "We sent a verification link to:\n${widget.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Continue
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isChecking ? null : _checkVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isChecking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Continue",
                        style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),

            // Resend
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canResend ? _resendEmail : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  canResend
                      ? "Resend Verification Email"
                      : "Resend in $_secondsRemaining s",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel and go back to Login",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
