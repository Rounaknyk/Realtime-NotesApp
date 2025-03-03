import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';

class Note {
  final String noteId;
  final String uid;
  final String note;
  final String time;
  final String date;

  Note({
    required this.noteId,
    required this.uid,
    required this.note,
    required this.time,
    required this.date,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      noteId: json['noteId'],
      uid: json['uid'],
      note: json['note'],
      time: json['time'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noteId': noteId,
      'uid': uid,
      'note': note,
      'time': time,
      'date': date,
    };
  }
}

class SocketService {

  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  // Socket instance
  late IO.Socket socket;
  bool isConnected = false;

  // Callbacks
  final ValueNotifier<List<Note>> notes = ValueNotifier<List<Note>>([]);
  Function(Note)? onNoteAdded;
  Function(Note)? onNoteUpdated;
  Function(String)? onNoteDeleted;

  void initialize(String userId) {
    socket = IO.io(kBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      isConnected = true;
      print('Connected to WebSocket server');

      socket.emit('join-notes-room', userId);
    });

    socket.on('note-added', (data) {
      final note = Note.fromJson(data);
      if (onNoteAdded != null) {
        onNoteAdded!(note);
      }
      _addNoteToList(note);
    });

    socket.on('note-updated', (data) {
      final note = Note.fromJson(data);
      if (onNoteUpdated != null) {
        onNoteUpdated!(note);
      }
      _updateNoteInList(note);
    });

    socket.on('note-deleted', (data) {
      final noteId = data['noteId'];
      if (onNoteDeleted != null) {
        onNoteDeleted!(noteId);
      }
      _removeNoteFromList(noteId);
    });

    socket.onDisconnect((_) {
      isConnected = false;
      print('Disconnected from WebSocket server');
    });

    socket.onError((error) {
      print('WebSocket Error: $error');
    });
  }

  void updateNote(Note note) {
    if (isConnected) {
      socket.emit('note-update', note.toJson());
    }
  }

  void deleteNote(String noteId, String uid) {
    if (isConnected) {
      socket.emit('note-delete', {'noteId': noteId, 'uid': uid});
    }
  }

  void _addNoteToList(Note note) {
    final currentNotes = List<Note>.from(notes.value);
    currentNotes.add(note);
    notes.value = currentNotes;
  }

  void _updateNoteInList(Note updatedNote) {
    final currentNotes = List<Note>.from(notes.value);
    final index = currentNotes.indexWhere((note) => note.noteId == updatedNote.noteId);

    if (index != -1) {
      currentNotes[index] = updatedNote;
      notes.value = currentNotes;
    }
  }

  void _removeNoteFromList(String noteId) {
    final currentNotes = List<Note>.from(notes.value);
    currentNotes.removeWhere((note) => note.noteId == noteId);
    notes.value = currentNotes;
  }

  void disconnect() {
    if (isConnected) {
      socket.disconnect();
      isConnected = false;
    }
  }
}