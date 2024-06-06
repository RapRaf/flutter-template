import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_template/components/existing_accounts.dart';
import 'package:flutter_template/http_requests/auth/log_in.dart';
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

  void _toggleKeepLogged(bool? value) async {
    if (Provider.of<AuthProvider>(context, listen: false).hasFingerPrints()) {
      await Provider.of<AuthProvider>(context, listen: false)
          .authFingerprints()
          .then((bool isAuth) =>
              Provider.of<AuthProvider>(context, listen: false)
                  .setKeepLogged());
    }
  }

  void _autoLogIn(String email) async {
    if (!Provider.of<AuthProvider>(context, listen: false).hasFingerPrints()) {
      return;
    }

    await Provider.of<AuthProvider>(context, listen: false)
        .authFingerprints()
        .then((bool isAuth) async {
      if (!isAuth) return;
      await Provider.of<AuthProvider>(context, listen: false)
          .getPassword(email)
          .then((String? pass) {
        if (pass != null && pass.isNotEmpty) {
          LogIn logIn = LogIn(
              email: email, password: pass, context: context, automatic: false);
          logIn.send();
        }
      });
    });
  }

  void _removeAccount(String email) async {
    if (!Provider.of<AuthProvider>(context, listen: false).hasFingerPrints()) {
      return;
    }

    await Provider.of<AuthProvider>(context, listen: false)
        .authFingerprints()
        .then((bool isAuth) async {
      if (!isAuth) return;
      Provider.of<AuthProvider>(context, listen: false).deleteAccount(email);
    });
  }

  void logIn() {
    if (emailController.text.isEmpty) return;
    if (!isValidEmail(emailController.text)) return;
    if (passwordController.text.isEmpty) return;
    if (passwordController.text.length < 7) return;

    LogIn logIn = LogIn(
        email: emailController.text,
        password: passwordController.text,
        context: context,
        automatic: false);
    logIn.send();
  }

  bool isValidEmail(String email) {
    final RegExp regex =
        RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    ThemeMode sysTheme =
        Provider.of<AuthProvider>(context, listen: false).theme;

    bool isDark = false;

    switch (sysTheme) {
      case ThemeMode.system:
        isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
        break;
      case ThemeMode.light:
        isDark = false;
        break;
      default:
        isDark = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.access),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150.0,
              width: 150.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: !isDark ? Colors.black : null,
                image: const DecorationImage(
                    image: AssetImage('assets/images/logo/logo.png'),
                    fit: BoxFit.cover,
                    scale: .5),
              ),
            ),
            if (Provider.of<AuthProvider>(context, listen: false)
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(localizations.keepConnection),
                Checkbox(
                  value: context.watch<AuthProvider>().keepLogged,
                  onChanged: _toggleKeepLogged,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              child: Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    text: localizations.ifNoAccount,
                    children: [
                      TextSpan(
                        text: " ${localizations.here}.",
                        style: const TextStyle(color: Colors.blueAccent),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            Uri url = Uri(
                                scheme: dotenv.get('SCHEMA'),
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
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
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
    );
  }
}
