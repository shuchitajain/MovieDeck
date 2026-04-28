import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_deck/providers/providers.dart';
import 'package:movie_deck/ui/config.dart';
import 'package:movie_deck/ui/screens/login_screen.dart';
import 'package:movie_deck/ui/widgets/app_logo_widget.dart';
import 'package:movie_deck/ui/widgets/back_button_widget.dart';
import 'package:movie_deck/ui/widgets/bezier_container_widget.dart';
import 'package:movie_deck/ui/widgets/reusable_button_widget.dart';
import 'package:page_transition/page_transition.dart';

import 'home_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isPassword = true;

  void _toggle() {
    setState(() {
      _isPassword = !_isPassword;
    });
  }

  Widget _entryField({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    obscure,
    isPassword,
    FormFieldValidator? validate,
    required String hint,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            key: Key(title),
            obscureText: obscure,
            controller: controller,
            validator: validate,
            keyboardType:
                !isPassword ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(
              border: InputBorder.none,
              errorStyle: TextStyle(fontSize: 13.5),
              hintText: hint,
              prefixIcon: Icon(icon),
              suffix: isPassword
                  ? InkWell(
                      child: Icon(Icons.remove_red_eye,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 20),
                      onTap: () => _toggle(),
                    )
                  : null,
              fillColor: colors.surfaceContainerHighest,
              filled: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _loginLabel() {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft, child: LoginScreen()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: RichText(
          text: TextSpan(
            text: 'Already have an account ?  ',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.onSurface),
            children: [
              TextSpan(
                text: 'Login',
                style: TextStyle(
                    color: colors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -App.height(context) * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer(),
                ),
                Positioned(
                  left: 0,
                  top: App.height(context) * .15,
                  child: appLogoWidget(context),
                ),
                Container(
                  margin: EdgeInsets.only(top: App.height(context) * 0.34),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _entryField(
                        title: "Name",
                        icon: Icons.person,
                        controller: _userNameController,
                        obscure: false,
                        isPassword: false,
                        validate: (name) =>
                            (name!.isEmpty) ? "Please enter a name" : null,
                        hint: "John Doe",
                      ),
                      _entryField(
                        title: "Email ",
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        obscure: false,
                        isPassword: false,
                        validate: (email) {
                          if (!email.isEmpty) {
                            bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(email);
                            return !emailValid ? "Invalid email address" : null;
                          } else {
                            return "Please enter an email address";
                          }
                        },
                        hint: "johndoe@gmail.com",
                      ),
                      _entryField(
                        title: "Password",
                        icon: Icons.lock,
                        controller: _passwordController,
                        obscure: _isPassword,
                        isPassword: true,
                        validate: (pass) =>
                            (pass!.isEmpty) ? "Please enter a password" : null,
                        hint: "*******",
                      ),
                      SizedBox(height: 30),
                      submitButton(
                        context: context,
                        text: "Register",
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            FocusScope.of(context).unfocus();
                            await ref
                                .read(authProvider.notifier)
                                .signUpWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  name: _userNameController.text.trim(),
                                )
                                .then((value) async {
                              if (value >= 0) {
                                switch (value) {
                                  case 0:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Email is already in use")));
                                    break;
                                  case 1:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("Password is too weak")));
                                    break;
                                }
                              } else {
                                bool success = await showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (_) {
                                    Future.delayed(Duration(seconds: 1), () {
                                      Navigator.of(context).pop(true);
                                    });
                                    return AlertDialog(
                                      insetPadding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      content: Container(
                                        height: 80,
                                        padding: EdgeInsets.only(right: 30),
                                        child: Row(
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(width: 15),
                                            Text(
                                                'Please wait, signing you up...',
                                                style: GoogleFonts.lato(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                                if (success) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: HomeScreen(),
                                      ),
                                      (route) => false);
                                  _emailController.clear();
                                  _passwordController.clear();
                                }
                              }
                            });
                          }
                        },
                      ),
                      SizedBox(height: 50),
                      _loginLabel(),
                    ],
                  ),
                ),
                Positioned(top: 40, left: 0, child: backButton(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
