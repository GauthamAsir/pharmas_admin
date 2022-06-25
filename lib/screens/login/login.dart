import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_admin/utils/constants.dart';
import 'package:e_commerce_admin/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  static const routeName = '/login';

  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';

  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void setIsLoading() {
    if (mounted) {
      setState(() {
        isLoading = !isLoading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: error.isNotEmpty,
                          child: MaterialBanner(
                            backgroundColor: Theme.of(context).errorColor,
                            content: Text(error),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    error = '';
                                  });
                                },
                                child: const Text(
                                  'dismiss',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                            contentTextStyle:
                                const TextStyle(color: Colors.white),
                            padding: const EdgeInsets.all(10),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _emailAndPassword,
                            child: isLoading
                                ? const CircularProgressIndicator.adaptive()
                                : const Text('Login'),
                          ),
                        ),
                        TextButton(
                          onPressed: _resetPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _resetPassword() async {
    String? email;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email'),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        );
      },
    );

    if (email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: email!);
        // ignore: use_build_context_synchronously
        ScaffoldSnackbar.of(context).show('Password reset email is sent');
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldSnackbar.of(context).show('Error resetting');
      }
    }
  }

  Future<void> _emailAndPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setIsLoading();

      try {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        User? user = _auth.currentUser;

        if (user != null) {
          await db.collection('admin').doc(user.uid).set({
            'last_login': Timestamp.now(),
            'email': user.email,
            'uid': user.uid
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          error = '${e.message}';
        });
      } catch (e) {
        setState(() {
          error = '$e';
        });
      } finally {
        setIsLoading();
      }
    }
  }
}
