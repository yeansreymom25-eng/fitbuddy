import 'package:flutter/material.dart';

import 'auth_common.dart';

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
                showMessage(context, 'Code sent again.');
              },
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Verify Code',
            onPressed: () {
              showMessage(context, 'Code verified.');
            },
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}
