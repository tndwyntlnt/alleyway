import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Help & Support",
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
          ListTile(title: Text("FAQ"), trailing: Icon(Icons.chevron_right)),
          Divider(),
          ListTile(
            title: Text("Contact Us"),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          ListTile(
            title: Text("Terms of Service"),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
