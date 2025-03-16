import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/auth.dart';
import 'package:skill_share_hub/views/home_views/home.dart';
import 'package:skill_share_hub/views/login_views/signup.dart';
// import 'package:skill_share_hub/services/api_service.dart'; // Import the API service

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // API service instance
  final _apiService = AuthRepo();

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login process
  Future<void> _handleLogin() async {
    // Validate form first
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call the login API
        final login_res = await _apiService.login(
            _emailController.text.trim(), _passwordController.text);

        if (login_res != null) {
          // Get the UserProvider instance
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);

          // Save the token securely
          await userProvider.setToken(login_res.token!);
          await userProvider.setUser(login_res.user!);
          // If successful, navigate to home screen
          if (mounted) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
        } else {
          throw Exception('Login failed');
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: Form(
          key: _formKey, // Add form key for validation
          child: Column(
            children: [
              const Spacer(),
              Image.asset("assets/images/main.png"),
              const Spacer(),
              Text(
                "Login",
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 31),
              TextFormField(
                controller: _emailController, // Add controller
                style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
                cursorColor: ColorsUtil.primaryclr,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  label: Text("Email"), // Changed from "User name" to "Email"
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  // Email validation
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Simple email format validation
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _passwordController, // Add controller
                style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
                cursorColor: ColorsUtil.primaryclr,
                obscureText: true, // Hide password
                decoration: const InputDecoration(
                  label: Text("Password"),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  // Password validation
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 9),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Do not have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUp()));
                    },
                    child: Text(
                      "SignUp",
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: ColorsUtil.primaryclr),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: theme.elevatedButtonTheme.style,
                onPressed: _isLoading
                    ? null
                    : _handleLogin, // Disable button while loading
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Login",
                        style: theme.textTheme.bodyLarge,
                      ),
              ),
              const Spacer(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
