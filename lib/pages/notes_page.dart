import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> notes = [];

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  Future<void> fetchNotes() async {
    final user = Supabase.instance.client.auth.currentUser;
    final response = await Supabase.instance.client
        .from('notes')
        .select()
        .eq('user_id', user?.id)
        .order('id', ascending: false);

    setState(() {
      notes = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> addNote(String title, String content) async {
    final user = Supabase.instance.client.auth.currentUser;
    await Supabase.instance.client.from('notes').insert({
      'title': title,
      'content': content,
      'user_id': user?.id,
    });
    await fetchNotes();
    titleController.clear();
    contentController.clear();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملاحظاتك'),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              TextField(
                  controller: titleController,
                  decoration:
                      const InputDecoration(labelText: 'عنوان الملاحظة')),
              const SizedBox(height: 8),
              TextField(
                  controller: contentController,
                  decoration:
                      const InputDecoration(labelText: 'محتوى الملاحظة')),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      contentController.text.isNotEmpty) {
                    addNote(titleController.text.trim(),
                        contentController.text.trim());
                  }
                },
                child: const Text('إضافة ملاحظة'),
              ),
            ]),
          ),
          const Divider(),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('لا توجد ملاحظات بعد'))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return ListTile(
                        title: Text(note['title']),
                        subtitle: Text(note['content']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
