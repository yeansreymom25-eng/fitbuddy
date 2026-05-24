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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 42),
          const BackArrow(),
          const SizedBox(height: 50),
          const Text(
            'Verify Your Email',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent a verification link to\n${widget.email}\nIf you do not see it, please check Spam or Junk.',
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 36),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8EA),
              border: Border.all(color: const Color(0xFFA8E8A8)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(14),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.mark_email_read, color: AppColors.green, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Copy the full email link or the oobCode value, paste it below, then verify.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppTextField(
            hintText: 'Paste link or oobCode',
            icon: Icons.link,
            controller: codeController,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: isApplyingCode ? 'Verifying...' : 'Verify With Code',
            onPressed: isApplyingCode ? null : verifyWithEmailCode,
          ),
          const Spacer(),
          PrimaryButton(
            label: isChecking ? 'Checking...' : 'I Verified My Email',
            onPressed: isChecking ? null : checkVerification,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: TextButton(
              onPressed: isResending ? null : resendVerification,
              style: TextButton.styleFrom(foregroundColor: AppColors.green),
              child: Text(
                isResending ? 'Sending...' : 'Resend Email',
                style: const TextStyle(fontWeight: FontWeight.w800),
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}
