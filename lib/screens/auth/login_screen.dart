import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/user_profile_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../onboarding/personalize_screen.dart';
import 'auth_common.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage(context, 'Please enter your email and password.');
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
      final credential = await AuthService.instance.signInWithEmail(
        email,
        password,
      );
      await credential.user?.reload();
      final user = AuthService.instance.currentUser;
      if (!mounted) {
        return;
      }

      if (user == null || !user.emailVerified) {
        await AuthService.instance.sendEmailVerification();
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(email: email),
          ),
        );
        return;
      }

      final profile = await UserProfileService.instance.getCurrentProfile();
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => profile?.onboardingComplete == true
              ? const DashboardScreen()
              : const PersonalizeScreen(),
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
        showMessage(context, 'Unable to login right now. Please try again.');
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
          const SizedBox(height: 76),
          const Text(
            'Welcome Back !',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Login to continue your\nhealth journey',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 48),
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
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ForgotPasswordScreen(
                      initialEmail: emailController.text.trim(),
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.green,
                padding: const EdgeInsets.only(top: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot Password',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: isLoading ? 'Logging in...' : 'Login',
            onPressed: isLoading ? null : login,
          ),
          const SizedBox(height: 18),
          const OrDivider(),
          const SizedBox(height: 18),
          Center(
            child: InlineAuthLink(
              text: "Don't have an account ?",
              actionText: 'Sign Up',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}
