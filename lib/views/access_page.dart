import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/components/existing_accounts.dart';
import 'package:flutter_template/config/env.dart';
import 'package:flutter_template/http_requests/auth/auth.dart';
import 'package:flutter_template/localization/app_localizations.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AccessView extends StatefulWidget {
  const AccessView({super.key});

  static const int minPasswordLength = 7;

  static bool isValidEmail(String email) {
    final RegExp regex = RegExp(
      r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
    );
    return regex.hasMatch(email);
  }

  @override
  AccessViewState createState() => AccessViewState();
}

class AccessViewState extends State<AccessView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late final TapGestureRecognizer _signUpRecognizer;
  bool _obscureText = true;
  bool _loggingIn = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _signUpRecognizer = TapGestureRecognizer()..onTap = _openWebsite;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _signUpRecognizer.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // void _toggleKeepLogged(bool? value) {
  //   context.read<AuthProvider>().setKeepLogged();
  // }

  Future<void> _openWebsite() async {
    final url = Env.websiteUri();
    if (url == null) return;
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Unable to open $url: $e');
    }
  }

  /// Sends the login request. Values are captured now, so editing the fields
  /// while waiting does not change what is saved.
  void _sendLogin(String email, String password) {
    final authProvider = context.read<AuthProvider>();
    setState(() => _loggingIn = true);

    authProvider.sendRequest(
      HttpRequests().logIn(
        email: email,
        password: password,
        responseListener: (response) {
          if (mounted) setState(() => _loggingIn = false);
          authProvider.handleLoginResponse(response, email, password);
        },
        errorListener: (response, statusCode) {
          if (mounted) setState(() => _loggingIn = false);
          authProvider.showSnackBar(
            statusCode == HttpRequest.networkErrorStatus
                ? authProvider.localizations.network_error
                : response,
          );
        },
      ),
    );
  }

  Future<void> _autoLogIn(String email) async {
    if (_loggingIn) return;
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.hasFingerPrints()) return;

    final isAuth = await authProvider.authFingerprints();
    if (!isAuth || !mounted) return;

    final pass = await authProvider.getPassword(email);
    if (!mounted) return;
    if (pass == null || pass.isEmpty) {
      // No saved password for this account: prefill the form instead.
      emailController.text = email;
      return;
    }
    _sendLogin(email, pass);
  }

  Future<void> _removeAccount(String email) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.hasFingerPrints()) return;

    final isAuth = await authProvider.authFingerprints();
    if (!isAuth || !mounted) return;
    await authProvider.deleteAccount(email);
  }

  void logIn() {
    if (_loggingIn) return;
    final localizations = AppLocalizations.of(context)!;
    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      _emailError = AccessView.isValidEmail(email)
          ? null
          : localizations.validEmail;
      _passwordError = password.length >= AccessView.minPasswordLength
          ? null
          : localizations.pass7Chars;
    });
    if (_emailError != null || _passwordError != null) return;

    FocusScope.of(context).unfocus();
    _sendLogin(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.access)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width > 500 ? 490 : width * 0.9,
              child: AutofillGroup(
                child: Column(
                  children: [
                    Container(
                      height: 150.0,
                      width: 150.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isDark ? null : Colors.black,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo/logo.png'),
                          fit: BoxFit.cover,
                          scale: .5,
                        ),
                      ),
                    ),
                    if (authProvider.hasFingerPrints() &&
                        authProvider.emails.isNotEmpty)
                      ExistingAccount(
                        onTap: _autoLogIn,
                        onLongPressed: _removeAccount,
                      ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: localizations.email,
                          hintText: localizations.insert_email,
                          errorText: _emailError,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        obscureText: _obscureText,
                        autocorrect: false,
                        enableSuggestions: false,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => logIn(),
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: localizations.password,
                          hintText: localizations.insertPassword,
                          errorText: _passwordError,
                          suffixIcon: IconButton(
                            onPressed: _togglePasswordVisibility,
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: <Widget>[
                    //     Text(localizations.keepConnection),
                    //     Checkbox(
                    //       value: context.watch<AuthProvider>().keepLogged,
                    //       onChanged: _toggleKeepLogged,
                    //     ),
                    //   ],
                    // ),
                    if (Env.websiteUri() != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 15,
                          left: 15,
                          right: 15,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                              text: localizations.ifNoAccount,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              children: [
                                TextSpan(
                                  text: " ${localizations.here}.",
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                  ),
                                  recognizer: _signUpRecognizer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Container(
                      height: 43,
                      width: 170,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: _loggingIn ? null : logIn,
                        child: _loggingIn
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                localizations.logIn,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
