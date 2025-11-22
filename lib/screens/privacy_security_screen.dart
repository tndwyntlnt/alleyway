import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Privacy & Security",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E392A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text("Change Password"),
            trailing: Icon(Icons.lock_outline),
          ),
          Divider(),
          ListTile(
            title: Text("Biometric Login"),
            trailing: Icon(Icons.fingerprint),
          ),
        ],
      ),
    );
  }
}
