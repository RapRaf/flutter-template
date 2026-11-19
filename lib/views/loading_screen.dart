import 'package:flutter/material.dart';
import 'package:flutter_template/http_requests/auth/auth.dart';
import 'package:flutter_template/localization/app_localizations.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Validates the saved token with the server and opens the session.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _pingServer();
  }

  Future<void> _pingServer() async {
    if (_failed) setState(() => _failed = false);
    // Short delay so the splash is visible and we are out of the build phase.
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    if (authProvider.token.isEmpty) {
      authProvider.setLoginState(newLoginState: LoginState.loggedOut);
      return;
    }

    /// HANDLE BACKEND LOGIC
    final HttpEntry ping = HttpRequests().ping(
      responseListener: (response) {
        final sessionToken = response['data'];
        if (sessionToken is String) {
          authProvider.setSessionToken(newSessionToken: sessionToken);
        }
        authProvider.setLoginState(newLoginState: LoginState.loggedIn);
      },
      errorListener: (response, statusCode) {
        if (statusCode == 401 || statusCode == 403) {
          // The saved token is no longer valid.
          authProvider.setToken(newToken: '');
          authProvider.setSessionToken(newSessionToken: '');
          authProvider.showSnackBar(authProvider.localizations.session_expired);
          authProvider.setLoginState(newLoginState: LoginState.loggedOut);
        } else if (mounted) {
          // Offline / server error: keep the token and let the user retry.
          setState(() => _failed = true);
        }
      },
    );

    authProvider.sendRequest(ping);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/logo/logo.png',
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Center(
                child: _failed
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localizations.network_error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _pingServer,
                            child: Text(localizations.retry),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.read<AuthProvider>().setLoginState(
                                  newLoginState: LoginState.loggedOut,
                                ),
                            child: Text(localizations.logIn),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
