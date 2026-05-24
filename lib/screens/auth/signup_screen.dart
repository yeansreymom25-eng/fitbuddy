import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/user_profile_service.dart';
import 'auth_common.dart';
import 'verify_email_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage(context, 'Please complete all signup fields.');
      return;
    }

    if (!isValidEmail(email)) {
      showMessage(context, 'Please enter a valid email address.');
      return;
    }

    final passwordError = passwordValidationMessage(password);
    if (passwordError != null) {
      showMessage(context, passwordError);
      return;
    }

    if (password != confirmPassword) {
      showMessage(context, 'Passwords do not match.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await AuthService.instance.signUpWithEmail(
        email,
        password,
      );
      await credential.user?.updateDisplayName(name);
      await UserProfileService.instance.ensureAuthProfile(
        fullName: name,
        email: email,
      );
      await credential.user?.sendEmailVerification();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: email),
        ),
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
        showMessage(context, 'Unable to create account right now.');
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
          const SizedBox(height: 28),
          const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Let's get you started on your\nhealth journey",
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            hintText: 'Full Name',
            icon: Icons.person,
            controller: nameController,
            keyboardType: TextInputType.name,
            autofillHints: const [AutofillHints.name],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
          AppTextField(
            hintText: 'Email',
            icon: Icons.email,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 18),
          AppTextField(
            hintText: 'Password',
            icon: Icons.lock,
            controller: passwordController,
            obscureText: hidePassword,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
              icon: Icon(
                hidePassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.hint,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 18),
          AppTextField(
            hintText: 'Confirm Password',
            icon: Icons.lock,
            controller: confirmPasswordController,
            obscureText: hideConfirmPassword,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  hideConfirmPassword = !hideConfirmPassword;
                });
              },
              icon: Icon(
                hideConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.hint,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: isLoading ? 'Creating...' : 'Sign Up',
            onPressed: isLoading ? null : signUp,
          ),
          const SizedBox(height: 12),
          Center(
            child: InlineAuthLink(
              text: 'Already have an account ?',
              actionText: 'Login',
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}
