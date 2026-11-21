import 'package:material_ui/material_ui.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('联系人')),
      body: const Center(child: Text('联系人列表')),
    );
  }
}
