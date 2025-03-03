import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notes_app/utils/constants.dart';

import 'socket_service.dart';

class ApiService {

  Future<List<Note>> getNotes(String userId) async {
    print("asdaklj ${userId}");
    final response = await http.get(
      Uri.parse('$kBaseUrl/notes/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    print("o2342098");


    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("reacjed");
      if (data['success'] && data['notes'] is List) {
        return (data['notes'] as List)
            .map((note) => Note.fromJson(note))
            .toList();
      }

      print(data);
      return [];
    } else {
      throw Exception('Failed to load notes: ${response.statusCode}');
    }
  }

  Future<Note> addNote(Note note) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/add_note'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(note.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success']) {
        return Note.fromJson(data['note']);
      }
      throw Exception('Failed to add note: ${data['msg']}');
    } else {
      throw Exception('Failed to add note: ${response.statusCode}');
    }
  }

  Future<Note> updateNote(Note note) async {
    final response = await http.put(
      Uri.parse('$kBaseUrl/update_note/${note.noteId}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'note': note.note,
        'time': note.time,
        'date': note.date,
        'noteId' : note.noteId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return Note.fromJson(data['note']);
      }
      throw Exception('Failed to update note: ${data['msg']}');
    } else {
      throw Exception('Failed to update note: ${response.statusCode}');
    }
  }

  Future<void> deleteNote(String noteId) async {
    final response = await http.delete(
      Uri.parse('$kBaseUrl/delete_note/$noteId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception('Failed to delete note: ${data['msg']}');
    }
  }
}