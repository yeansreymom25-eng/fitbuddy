import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../onboarding/personalize_screen.dart';
import 'auth_common.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final codeController = TextEditingController();
  bool isChecking = false;
  bool isResending = false;
  bool isApplyingCode = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> checkVerification() async {
    setState(() {
      isChecking = true;
    });

    try {
      await AuthService.instance.reloadCurrentUser();
      final user = AuthService.instance.currentUser;
      if (!mounted) {
        return;
      }

      if (user != null && user.emailVerified) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PersonalizeScreen()),
        );
        return;
      }

      showMessage(context, 'Please verify your email first.');
    } on FirebaseException catch (error) {
      if (mounted) {
        showMessage(context, firebaseErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Unable to check verification right now.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isChecking = false;
        });
      }
    }
  }

  Future<void> resendVerification() async {
    setState(() {
      isResending = true;
    });

    try {
      await AuthService.instance.sendEmailVerification();
      if (mounted) {
        showMessage(context, 'Verification email sent again.');
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        showMessage(context, firebaseErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Unable to resend verification email.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isResending = false;
        });
      }
    }
  }

  Future<void> verifyWithEmailCode() async {
    final code = extractFirebaseActionCode(codeController.text);
    if (code == null || code.isEmpty) {
      showMessage(context, 'Paste the email link or oobCode first.');
      return;
    }

    setState(() {
      isApplyingCode = true;
    });

    try {
      await AuthService.instance.applyEmailVerificationCode(code);
      if (!mounted) {
        return;
      }
      showMessage(context, 'Email verified.');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PersonalizeScreen()),
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        showMessage(context, authErrorMessage(error));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        showMessage(context, firebaseErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Unable to verify this code right now.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isApplyingCode = false;
        });
      }
    }
  }

  Future<void> backToLogin() async {
    await AuthService.instance.signOut();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            const BackArrow(),
            const SizedBox(height: 34),
            Center(
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCFEBDD)),
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: AppColors.green,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Center(
              child: Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'We sent a secure verification link to',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                border: Border.all(color: const Color(0xFFCFEBDD)),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(14),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.green, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Open your email, tap the verification link, then return here and check again. You can also paste the full link or oobCode below.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppTextField(
              hintText: 'Paste email link or oobCode',
              icon: Icons.link_rounded,
              controller: codeController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: isApplyingCode ? 'Verifying...' : 'Verify With Code',
              onPressed: isApplyingCode ? null : verifyWithEmailCode,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: isChecking ? 'Checking...' : 'I Verified My Email',
              onPressed: isChecking ? null : checkVerification,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: isResending ? null : resendVerification,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(isResending ? 'Sending...' : 'Resend Email'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: backToLogin,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textGrey,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
