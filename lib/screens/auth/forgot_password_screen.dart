import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'auth_common.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = '',
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.initialEmail;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showMessage(context, 'Please enter your email address.');
      return;
    }

    if (!isValidEmail(email)) {
      showMessage(context, 'Please enter a valid email address.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService.instance.sendPasswordReset(email);
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
      });
      await showResetEmailDialog(context, email);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
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
        showMessage(context, 'Unable to send reset email right now.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
            'Forgot Password',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your email to reset\nyour password',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 44),
          AppTextField(
            hintText: 'Email',
            icon: Icons.email,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
          ),
          const Spacer(),
          PrimaryButton(
            label: isLoading ? 'Sending...' : 'Send Reset Link',
            onPressed: isLoading ? null : sendResetLink,
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}
