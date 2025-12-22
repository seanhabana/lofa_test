import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/authprovider.dart';
import '../../widgets/authtopbar.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final forgotPasswordState = ref.watch(forgotPasswordProvider);

    // Listen to success messages
    ref.listen<ForgotPasswordState>(forgotPasswordProvider, (previous, next) {
      if (next.successMessage != null) {
        _showMessage(next.successMessage!);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top pattern section
              AuthTopBar(title: 'LOFA Consulting'),

              // Form section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Title
                    Text(
                      forgotPasswordState.isCodeSent
                          ? 'Verify Code'
                          : 'Forgot Password',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF581C87),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      forgotPasswordState.isCodeSent
                          ? 'Enter the 6-digit code sent to ${forgotPasswordState.email}'
                          : 'Enter your email to receive a verification code',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),

                    // Error message
                    if (forgotPasswordState.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                forgotPasswordState.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Content based on state
                    if (!forgotPasswordState.isCodeSent) ...[
                      // Email input section
                      TextField(
                        onChanged: (value) => ref
                            .read(forgotPasswordProvider.notifier)
                            .updateEmail(value),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF9D65AA),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF9D65AA),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Send Code Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: forgotPasswordState.isLoading
                              ? null
                              : () async {
                                  await ref
                                      .read(forgotPasswordProvider.notifier)
                                      .sendCode();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF581C87),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: forgotPasswordState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Send Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      // Code input section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 50,
                            height: 60,
                            child: TextField(
                              focusNode: _codeFocusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF581C87),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF9D65AA),
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                ref
                                    .read(forgotPasswordProvider.notifier)
                                    .updateCodeDigit(index, value);

                                if (value.length == 1 && index < 5) {
                                  _codeFocusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _codeFocusNodes[index - 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Resend Code Button
                      TextButton(
                        onPressed:
                            forgotPasswordState.isResendEnabled &&
                                !forgotPasswordState.isLoading
                            ? () async {
                                await ref
                                    .read(forgotPasswordProvider.notifier)
                                    .resendCode();
                              }
                            : null,
                        child: Text(
                          forgotPasswordState.isResendEnabled
                              ? 'Resend Code'
                              : 'Resend in ${forgotPasswordState.resendCountdown}s',
                          style: TextStyle(
                            color: forgotPasswordState.isResendEnabled
                                ? const Color(0xFF9D65AA)
                                : Colors.grey[400],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: forgotPasswordState.isLoading
                              ? null
                              : () async {
                                  final success = await ref
                                      .read(forgotPasswordProvider.notifier)
                                      .verifyCode();
                                  if (success && mounted) {
                                    // TODO: Navigate to reset password page
                                    _showMessage(
                                      'Code verified! Proceed to reset password',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF581C87),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: forgotPasswordState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Verify Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Back to Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Color(0xFF581C87),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(forgotPasswordProvider.notifier).reset();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(left: 4),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Back to Login',
                            style: TextStyle(
                              color: Color(0xFF581C87),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
