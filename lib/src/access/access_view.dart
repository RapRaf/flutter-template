import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_template/http_requests/log_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_template/route_controller.dart';
import 'package:flutter_template/store_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class AccessView extends StatefulWidget {
  const AccessView({Key? key}) : super(key: key);

  static const routeName = AppRoutes.root;

  @override
  AccessViewState createState() => AccessViewState();
}

class AccessViewState extends State<AccessView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;
  bool _keepLogged = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleKeepLogged(bool? value) {
    if (value != null) {
      setState(() {
        _keepLogged = value;
      });
      StoreController().setKeepLogged(value);
    }
  }

  void logIn() {
    if (emailController.text.isEmpty) return;
    if (!isValidEmail(emailController.text)) return;
    if (passwordController.text.isEmpty) return;
    if (passwordController.text.length < 7) return;

    LogIn(
        email: emailController.text,
        password: passwordController.text,
        responseListener: (value) {
          Navigator.pushReplacementNamed(context, AppRoutes.home.toString());
        },
        errorListener: (value) {
          if (value == -1) debugPrint("Non concesso");
          debugPrint(value.toString());
        }).run();
  }

  bool isValidEmail(String email) {
    final RegExp regex =
        RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    StoreController().getKeepLogged().then((value) => {
          setState(() {
            _keepLogged = value!;
          })
        });
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.access),
      ),
      body: Column(
        children: [
          Container(
            height: 150.0,
            width: 150.0,
            padding: const EdgeInsets.all(30),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/images/flutter_logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
                value: _keepLogged,
                onChanged: _toggleKeepLogged,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
            child: Row(
              children: [
                Text(localizations.ifNoAccount),
                InkWell(
                    onTap: () {
                      launchUrl(Uri(
                          scheme: dotenv.get('SCHEMA'),
                          host: dotenv.get('VUE_HOST'),
                          path: '/'));
                    },
                    child: Text(" ${localizations.here}.",
                        style: const TextStyle(color: Colors.blueAccent))),
              ],
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
    );
  }
}
