import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF008A08);
  static const paleGreen = Color(0xFFEAF8EA);
  static const surfaceGreen = Color(0xFFF6FCF6);
  static const softGreen = Color(0xFFDDFBDD);
  static const textGrey = Color(0xFF777777);
  static const border = Color(0xFFD8D8D8);
  static const hint = Color(0xFFC7C7CC);

  const AppColors._();
}

void showMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  final isSuccess = message.toLowerCase().contains('sent') ||
      message.toLowerCase().contains('created') ||
      message.toLowerCase().contains('saved') ||
      message.toLowerCase().contains('verified');
  final backgroundColor = isSuccess ? AppColors.green : const Color(0xFF303037);
  final icon = isSuccess ? Icons.check_circle : Icons.info_outline;

  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 22),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showResetEmailDialog(BuildContext context, String email) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: AppColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read,
                  color: AppColors.green,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Check your inbox',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If an account exists for\n$email, Firebase will send reset instructions.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Back to Login',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
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
    case 'expired-action-code':
      return 'This email code has expired. Please resend the email.';
    case 'invalid-action-code':
      return 'This email code is invalid or was already used.';
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

String? extractFirebaseActionCode(String value) {
  final input = value.trim();
  if (input.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(input);
  final codeFromUri = uri?.queryParameters['oobCode'];
  if (codeFromUri != null && codeFromUri.trim().isNotEmpty) {
    return codeFromUri.trim();
  }

  final match = RegExp(r'oobCode=([^&\s]+)').firstMatch(input);
  final codeFromText = match?.group(1);
  if (codeFromText != null && codeFromText.trim().isNotEmpty) {
    return Uri.decodeComponent(codeFromText.trim());
  }

  return input;
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
        backgroundColor: AppColors.paleGreen,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE4F2E4)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(24, 92, 36, 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
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
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE4F2E4)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(24, 92, 36, 0.08),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
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
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.autofillHints,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        textInputAction: textInputAction,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceGreen,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.hint,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Icon(icon, color: AppColors.green, size: 19),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E8E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
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
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: option.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.surfaceGreen,
            border: Border.all(color: const Color(0xFFE0E8E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.softGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(option.icon, color: AppColors.green, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
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
                        fontSize: 10,
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
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        border: Border.all(color: const Color(0xFFA8E8A8)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.green, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data is safe with us.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'We never share your personal\ninformation.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 10,
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
