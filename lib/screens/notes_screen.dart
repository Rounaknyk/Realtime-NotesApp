import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';
import 'edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  final String userId;

  const NotesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _fetchNotes();
  }

  void _initializeSocket() {
    _socketService.initialize(widget.userId);

    _socketService.onNoteAdded = (note) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New note added!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    };

    _socketService.onNoteUpdated = (note) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note updated!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    };

    _socketService.onNoteDeleted = (noteId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note deleted!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    };
  }

  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedNotes = await _apiService.getNotes(widget.userId);
      _socketService.notes.value = fetchedNotes;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching notes: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchNotes,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white,),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('uid'); // Clear the stored UID
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen(isLogin: true)),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<Note>>(
        valueListenable: _socketService.notes,
        builder: (context, notes, _) {
          if (notes.isEmpty) {
            return Center(
              child: Text(
                'No notes yet. Add your first note!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteCard(
                note: note,
                onEdit: () => _navigateToEditNote(note),
                onDelete: () => _deleteNote(note),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        onPressed: _navigateToAddNote,
      ),
    );
  }

  void _navigateToAddNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(userId: widget.userId),
      ),
    );
  }

  void _navigateToEditNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(
          userId: widget.userId,
          note: note,
        ),
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    try {
      await _apiService.deleteNote(note.noteId);
      _socketService.deleteNote(note.noteId, widget.userId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting note: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.note,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${note.date} at ${note.time}',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}