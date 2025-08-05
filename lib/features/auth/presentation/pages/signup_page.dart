import 'package:devgram/features/auth/presentation/components/custom_textfiled.dart';
import 'package:devgram/features/auth/presentation/components/my_button.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  final void Function()? togglePage;
  const SignupPage({super.key, this.togglePage});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        // Call your authentication service here
        print(
          'Signing up with name: $name, email: $email, and password: $password',
        );
        context.read<AuthCubit>().signUp(email, name, password);
        // After successful signup, you can navigate to the home page or show a success message
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_open_rounded, size: 100, color: Colors.black),
                const SizedBox(height: 30),
                Text(
                  'Let\'s create your account! ',

                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 25),
                //Name TextField
                CustomTextField(
                  controller: nameController,
                  hintText: "Name",
                  obscureText: false,
                ),
                const SizedBox(height: 25),
                //Email TextField
                CustomTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(height: 25),
                CustomTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                CustomTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                //Signup Button
                MyButton(onTap: signUp, text: "Sign up"),
                const SizedBox(height: 35),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already a member?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePage,
                      child: Text(
                        " Login now!",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                //Sign Up Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
