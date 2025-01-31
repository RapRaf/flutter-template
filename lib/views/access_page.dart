import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_template/components/existing_accounts.dart';
import 'package:flutter_template/http_requests/auth/auth.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class AccessView extends StatefulWidget {
  const AccessView({super.key});

  @override
  AccessViewState createState() => AccessViewState();
}

class AccessViewState extends State<AccessView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // void _toggleKeepLogged(bool? value) {
  //   context.read<AuthProvider>().setKeepLogged();
  // }

  void _autoLogIn(String email) async {
    if (!context.read<AuthProvider>().hasFingerPrints()) {
      return;
    }

    await context
        .read<AuthProvider>()
        .authFingerprints()
        .then((bool isAuth) async {
      if (!isAuth) return;
      await context
          .read<AuthProvider>()
          .getPassword(email)
          .then((String? pass) {
        if (pass != null && pass.isNotEmpty) {
          context.read<AuthProvider>().sendRequest(HttpRequests().logIn(
              responseListener: (response) {
                context
                    .read<AuthProvider>()
                    .handleLoginResponse(response, email, pass);
              },
              email: email,
              password: pass));
        }
      });
    });
  }

  void _removeAccount(String email) async {
    if (!context.read<AuthProvider>().hasFingerPrints()) {
      return;
    }

    await context
        .read<AuthProvider>()
        .authFingerprints()
        .then((bool isAuth) async {
      if (!isAuth) return;
      context.read<AuthProvider>().deleteAccount(email);
    });
  }

  void logIn() {
    if (emailController.text.isEmpty) return;
    if (!isValidEmail(emailController.text)) return;
    if (passwordController.text.isEmpty) return;
    if (passwordController.text.length < 7) return;

    context.read<AuthProvider>().sendRequest(HttpRequests().logIn(
        responseListener: (response) {
          context.read<AuthProvider>().handleLoginResponse(
              response, emailController.text, passwordController.text);
        },
        email: emailController.text,
        password: passwordController.text));
  }

  bool isValidEmail(String email) {
    final RegExp regex =
        RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.access),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width > 500 ? 490 : width * 0.9,
            child: Column(
              children: [
                Container(
                  height: 150.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: !context.read<AuthProvider>().isDark
                        ? Colors.black
                        : null,
                    image: const DecorationImage(
                        image: AssetImage('assets/images/logo/logo.png'),
                        fit: BoxFit.cover,
                        scale: .5),
                  ),
                ),
                if (context.read<AuthProvider>()
                        .hasFingerPrints() &&
                    context.watch<AuthProvider>().emails.isNotEmpty)
                  ExistingAccount(
                    onTap: (String email) => _autoLogIn(email),
                    onLongPressed: (String email) => _removeAccount(email),
                  ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: localizations.email,
                        hintText: localizations.insert_email),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Password",
                      hintText: localizations.insertPassword,
                      suffixIcon: InkWell(
                        onTap: _togglePasswordVisibility,
                        child: Icon(
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
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 15, left: 15, right: 15),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(
                        text: localizations.ifNoAccount,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        children: [
                          TextSpan(
                            text: " ${localizations.here}.",
                            style: const TextStyle(color: Colors.blueAccent),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                Uri url = Uri(
                                    scheme: dotenv.get('HTTP_SCHEMA'),
                                    host: dotenv.get('VUE_HOST'),
                                    path: '/');
                                if (await canLaunchUrl(url)) {
                                  launchUrl(url);
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 43,
                  width: 170,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () {
                      logIn();
                    },
                    child: Text(
                      localizations.logIn,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
