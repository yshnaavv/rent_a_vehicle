import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/owner_provider.dart';
import '../../theme/app_theme.dart';
import 'owner_home.dart';
import 'owner_register_screen.dart';
import 'owner_pending_approval_screen.dart';

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginOwner() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password')),
      );
      return;
    }

    final status = await Provider.of<OwnerProvider>(context, listen: false)
        .loginOwner(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

    if (!mounted) return;

    if (status == 'approved') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OwnerHome()),
      );
    } else if (status != null) {
      if (status == 'pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account is waiting for admin approval.'),
            backgroundColor: AppColors.malt,
          ),
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OwnerPendingApprovalScreen(status: status),
        ),
      );
    } else {
      final provider = Provider.of<OwnerProvider>(context, listen: false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Partner login failed. Please check credentials.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Partner Portal')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.malt,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.malt.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.store_mall_directory_rounded,
                        size: 40,
                        color: AppColors.turmeric,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Partner Sign In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malt,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Manage your vehicles, fleet availability & bookings',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.maltMuted, fontSize: 14),
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Business / Partner Email',
                      hintText: 'partner@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.maltMuted,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Consumer<OwnerProvider>(
                    builder: (context, provider, child) {
                      return SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : loginOwner,
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.malt,
                                  ),
                                )
                              : const Text(
                                  'Sign In as Partner',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Register as New Partner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'New vehicle partner? ',
                        style: TextStyle(color: AppColors.maltMuted),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OwnerRegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Register Shop',
                          style: TextStyle(
                            color: AppColors.malt,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
