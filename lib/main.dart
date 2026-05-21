import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (error) {
    debugPrint('Firebase did not initialize: ${error.message}');
  } catch (error) {
    debugPrint('Firebase did not initialize: $error');
  }

  runApp(const FitBuddyApp());
}

class FitBuddyApp extends StatelessWidget {
  const FitBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ColoredBox(
          color: AppColors.paleGreen,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: const OnboardingScreen(),
    );
  }
}

class AppColors {
  static const green = Color(0xFF008A08);
  static const paleGreen = Color(0xFFEAF8EA);
  static const textGrey = Color(0xFF777777);
  static const border = Color(0xFFD8D8D8);
  static const hint = Color(0xFFC7C7CC);

  const AppColors._();
}

void showMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(content: Text(message)),
  );
}

String authErrorMessage(FirebaseAuthException error) {
  debugPrint(
    'FirebaseAuthException: code=${error.code}, message=${error.message}',
  );

  switch (error.code) {
    case 'email-already-in-use':
      return 'This email is already registered.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email or password is incorrect.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'operation-not-allowed':
    case 'admin-restricted-operation':
      return 'Email/password sign up is not enabled in Firebase.';
    case 'configuration-not-found':
      return 'Firebase Auth is not enabled for this project yet.';
    case 'app-not-authorized':
    case 'unauthorized-domain':
      return 'This app or domain is not authorized in Firebase.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait and try again.';
    case 'network-request-failed':
      return 'Network error. Please check your connection.';
    default:
      final message = error.message;
      if (message != null && message.trim().isNotEmpty && message != 'Error') {
        return message;
      }
      return 'Authentication failed (${error.code}). Check Firebase setup.';
  }
}

String firebaseErrorMessage(FirebaseException error) {
  debugPrint('FirebaseException: code=${error.code}, message=${error.message}');

  if (error.code == 'core/no-app' || error.code == 'no-app') {
    return 'Firebase is not configured for this platform yet.';
  }

  final message = error.message;
  if (message != null && message.trim().isNotEmpty && message != 'Error') {
    return message;
  }

  return 'Firebase is unavailable right now (${error.code}).';
}

bool isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}

String? passwordValidationMessage(String password) {
  if (password.length < 8) {
    return 'Password must be at least 8 characters.';
  }
  if (!RegExp('[A-Z]').hasMatch(password)) {
    return 'Password needs at least one uppercase letter.';
  }
  if (!RegExp('[a-z]').hasMatch(password)) {
    return 'Password needs at least one lowercase letter.';
  }
  if (!RegExp(r'\d').hasMatch(password)) {
    return 'Password needs at least one number.';
  }

  return null;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<OnboardData> pages = const [
    OnboardData(
      image: 'assets/images/welcome.png',
      greenTitle: 'Healthy You,',
      blackTitle: 'Better Tomorrow',
      description:
          'Track your meals, improve\nyour sleep and achieve\nyour health goals',
      button: 'Get Start',
    ),
    OnboardData(
      image: 'assets/images/track.png',
      greenTitle: 'Track',
      blackTitle: 'Everything',
      description: 'Log your meals, sleep\nand stay on track',
      button: 'Next',
    ),
    OnboardData(
      image: 'assets/images/heart.png',
      greenTitle: 'Improve',
      blackTitle: 'Your Health',
      description:
          'Get insights and personalized\nrecommendation to build\nbetter habits',
      button: 'Next',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentIndex < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final page = pages[index];

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final topGap = constraints.maxHeight * 0.09;
                final imageHeight = constraints.maxHeight * 0.24;
                final titleGap = constraints.maxHeight * 0.05;
                final descriptionGap = constraints.maxHeight * 0.035;
                final bottomGap = constraints.maxHeight * 0.04;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    children: [
                      SizedBox(height: topGap.clamp(36.0, 86.0)),
                      Image.asset(
                        page.image,
                        height: imageHeight.clamp(145.0, 185.0),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: titleGap.clamp(24.0, 58.0)),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.22,
                            letterSpacing: 0,
                          ),
                          children: [
                            TextSpan(
                              text: '${page.greenTitle} ',
                              style: const TextStyle(color: AppColors.green),
                            ),
                            TextSpan(
                              text: page.blackTitle,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: descriptionGap.clamp(18.0, 34.0)),
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                          letterSpacing: 0,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (dotIndex) => AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 7),
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: currentIndex == dotIndex
                                  ? AppColors.green
                                  : const Color(0xFFD8D8D8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: 165,
                        height: 40,
                        child: PrimaryButton(
                          label: page.button,
                          onPressed: nextPage,
                        ),
                      ),
                      SizedBox(height: bottomGap.clamp(18.0, 40.0)),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

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
          ),
          const SizedBox(height: 18),
          AppTextField(
            hintText: 'Password',
            icon: Icons.lock,
            controller: passwordController,
            obscureText: hidePassword,
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
                    builder: (_) => const ForgotPasswordScreen(),
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

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
      showMessage(context, 'Password reset email sent.');
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
  bool isChecking = false;
  bool isResending = false;

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
            'We sent a verification link to\n${widget.email}',
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
                    'Open your inbox, tap the verification link, then return here.',
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

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 42),
          const BackArrow(),
          const SizedBox(height: 46),
          const Text(
            'Check Your Email',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the 4 digit code we sent\nto your email',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 42),
          const VerificationCodeFields(),
          const SizedBox(height: 18),
          Center(
            child: InlineAuthLink(
              text: "Didn't receive code ?",
              actionText: 'Resend',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code sent again')),
                );
              },
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Verify Code',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code verified')),
              );
            },
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}

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
          ),
          const SizedBox(height: 18),
          AppTextField(
            hintText: 'Email',
            icon: Icons.email,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          AppTextField(
            hintText: 'Password',
            icon: Icons.lock,
            controller: passwordController,
            obscureText: hidePassword,
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

class PersonalizeScreen extends StatefulWidget {
  const PersonalizeScreen({super.key});

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  String? gender;
  DateTime? dateOfBirth;
  String? weight;
  String? height;
  String? healthGoal;

  String get birthDateLabel {
    final value = dateOfBirth;
    if (value == null) {
      return 'Select your date of birth';
    }

    return '${value.month}/${value.day}/${value.year}';
  }

  Future<void> chooseGender() async {
    final selected = await showOptionsSheet(
      title: 'Gender',
      options: const ['Female', 'Male', 'Other'],
      currentValue: gender,
    );

    if (selected != null) {
      setState(() {
        gender = selected;
      });
    }
  }

  Future<void> chooseDateOfBirth() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );

    if (selected != null) {
      setState(() {
        dateOfBirth = selected;
      });
    }
  }

  Future<void> chooseWeight() async {
    final selected = await showNumberDialog(
      title: 'Weight',
      hintText: 'Enter your weight',
      suffix: 'kg',
      initialValue: weight?.replaceAll(' kg', ''),
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        weight = '$selected kg';
      });
    }
  }

  Future<void> chooseHeight() async {
    final selected = await showNumberDialog(
      title: 'Height',
      hintText: 'Enter your height',
      suffix: 'cm',
      initialValue: height?.replaceAll(' cm', ''),
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        height = '$selected cm';
      });
    }
  }

  Future<void> chooseHealthGoal() async {
    final selected = await showOptionsSheet(
      title: 'Health Goal',
      options: const [
        'Lose Weight',
        'Build Muscle',
        'Sleep Better',
        'Eat Healthier',
        'Stay Active',
      ],
      currentValue: healthGoal,
    );

    if (selected != null) {
      setState(() {
        healthGoal = selected;
      });
    }
  }

  Future<String?> showOptionsSheet({
    required String title,
    required List<String> options,
    String? currentValue,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.38),
      builder: (context) {
        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...options.map(
                  (option) {
                    final isSelected = currentValue == option;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop(option);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEAF8EA)
                                : const Color(0xFFF9FBF9),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.green
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.textGrey,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> showNumberDialog({
    required String title,
    required String hintText,
    required String suffix,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hintText,
              suffixText: suffix,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  void continueNext() {
    final isComplete = gender != null &&
        dateOfBirth != null &&
        weight != null &&
        height != null &&
        healthGoal != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isComplete
              ? 'Profile details saved on this device.'
              : 'Please complete all fields first.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      PreferenceOption(
        icon: Icons.person,
        title: 'Gender',
        subtitle: gender ?? 'Select your gender',
        onTap: chooseGender,
      ),
      PreferenceOption(
        icon: Icons.calendar_month,
        title: 'Date of Birth',
        subtitle: birthDateLabel,
        onTap: chooseDateOfBirth,
      ),
      PreferenceOption(
        icon: Icons.monitor_weight,
        title: 'Weight',
        subtitle: weight ?? 'Enter your weight',
        onTap: chooseWeight,
      ),
      PreferenceOption(
        icon: Icons.insert_chart,
        title: 'Height',
        subtitle: height ?? 'Enter your height',
        onTap: chooseHeight,
      ),
      PreferenceOption(
        icon: Icons.signpost,
        title: 'Health Goal',
        subtitle: healthGoal ?? "What's your main goal?",
        onTap: chooseHealthGoal,
      ),
    ];

    return AuthScaffold(
      decorated: false,
      horizontalPadding: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 42),
          const BackArrow(),
          const SizedBox(height: 10),
          const Text(
            'Personalize Your\nExperience',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us a bit about yourself to get\nbetter recommendations',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PreferenceTile(option: option),
            ),
          ),
          const SizedBox(height: 4),
          const SafeDataTile(),
          const Spacer(),
          PrimaryButton(
            label: 'Continue',
            onPressed: continueNext,
          ),
          const SizedBox(height: 10),
          const StepDots(activeIndex: 3, count: 4),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final double horizontalPadding;
  final bool decorated;

  const AuthScaffold({
    super.key,
    required this.child,
    this.horizontalPadding = 36,
    this.decorated = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!decorated) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paleGreen,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(0, 0, 0, 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.hint,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Icon(icon, color: Colors.black87, size: 18),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: AppColors.green, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class VerificationCodeFields extends StatelessWidget {
  const VerificationCodeFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: 52,
          height: 56,
          child: TextField(
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF9FBF9),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.green,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFF9E9E9E), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFF9E9E9E), thickness: 1)),
      ],
    );
  }
}

class InlineAuthLink extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const InlineAuthLink({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.green,
            padding: const EdgeInsets.only(left: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionText,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class BackArrow extends StatelessWidget {
  const BackArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).maybePop();
      },
      icon: const Icon(Icons.arrow_back, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      alignment: Alignment.centerLeft,
    );
  }
}

class PreferenceTile extends StatelessWidget {
  final PreferenceOption option;

  const PreferenceTile({
    super.key,
    required this.option,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: option.onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(option.icon, color: AppColors.green, size: 17),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      option.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.green,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SafeDataTile extends StatelessWidget {
  const SafeDataTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFD8FBD8),
        border: Border.all(color: const Color(0xFFA8E8A8)),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: Colors.black87, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data is safe with us.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'We never share your personal\ninformation.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: AppColors.green, size: 18),
        ],
      ),
    );
  }
}

class StepDots extends StatelessWidget {
  final int activeIndex;
  final int count;

  const StepDots({
    super.key,
    required this.activeIndex,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: index == activeIndex ? AppColors.green : AppColors.border,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class OnboardData {
  final String image;
  final String greenTitle;
  final String blackTitle;
  final String description;
  final String button;

  const OnboardData({
    required this.image,
    required this.greenTitle,
    required this.blackTitle,
    required this.description,
    required this.button,
  });
}

class PreferenceOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const PreferenceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
