import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final String userId;
  final Note? note;

  const AddEditNoteScreen({
    Key? key,
    required this.userId,
    this.note,
  }) : super(key: key);

  @override
  _AddEditNoteScreenState createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final TextEditingController _noteController = TextEditingController();
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _noteController.text = widget.note!.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _noteController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Write your note here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                isEditing ? 'Update Note' : 'Save Note',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final timeFormat = DateFormat('HH:mm');
      final dateFormat = DateFormat('yyyy-MM-dd');

      final isEditing = widget.note != null;

      if (isEditing) {
        final updatedNote = Note(
          noteId: widget.note!.noteId,
          uid: widget.userId,
          note: _noteController.text.trim(),
          time: timeFormat.format(now),
          date: dateFormat.format(now),
        );

        await _apiService.updateNote(updatedNote);
        _socketService.updateNote(updatedNote);
      } else {
        final newNote = Note(
          noteId: Uuid().v4(),
          uid: widget.userId,
          note: _noteController.text.trim(),
          time: timeFormat.format(now),
          date: dateFormat.format(now),
        );

        await _apiService.addNote(newNote);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}