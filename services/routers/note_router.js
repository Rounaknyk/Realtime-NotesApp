const express = require("express");
const noteModel = require("../models/note");

const noteRouter = express.Router();

// Make sure to export the router setup function to have access to io
  noteRouter.get('/message', (req, res) => {
  console.log("HEEE");
  res.send("helllo");
  });

module.exports = function(io) {
  // Create a new note
  noteRouter.post('/add_note', async (req, res) => {
    try {
      const { noteId, uid, note, time, date } = req.body;

      let model = new noteModel({ noteId, uid, note, time, date });
      model = await model.save();
      
      // Emit event through WebSocket
      io.to(`user-${uid}`).emit('note-added', model);
      
      res.status(201).json({ success: true, note: model });
    } catch (e) {
      res.status(500).json({ "msg": `Error: ${e}` });
    }
  });


  // Update a note
  noteRouter.put('/update_note/:noteId', async (req, res) => {
    try {
      const { note, time, date } = req.body;
      const noteId = req.params.noteId;
      
      const updatedNote = await noteModel.findOneAndUpdate(
        { noteId },
        { note, time, date },
        { new: true }
      );
      
      if (!updatedNote) {
        return res.status(404).json({ msg: "Note not found" });
      }
      
      // Emit event through WebSocket
      io.to(`user-${updatedNote.uid}`).emit('note-updated', updatedNote);
      
      res.json({ success: true, note: updatedNote });
    } catch (e) {
      res.status(500).json({ "msg": `Error: ${e}` });
    }
  });

  // Delete a note
  noteRouter.delete('/delete_note/:noteId', async (req, res) => {
    try {
      const noteId = req.params.noteId;
      
      const note = await noteModel.findOne({ noteId });
      if (!note) {
        return res.status(404).json({ msg: "Note not found" });
      }
      
      const uid = note.uid;
      await noteModel.deleteOne({ noteId });
      
      // Emit event through WebSocket
      io.to(`user-${uid}`).emit('note-deleted', { noteId, uid });
      
      res.json({ success: true, msg: "Note deleted successfully" });
    } catch (e) {
      res.status(500).json({ "msg": `Error: ${e}` });
    }
  });

  // Get all notes for a user
  noteRouter.get('/notes/:uid', async (req, res) => {
      console.log("reached");
    try {

      const uid = req.params.uid;
      console.log(`UID ${uid}`);

//      let abc = noteModel({noteId: "12313", uid: "123123", time: "23", date: "23", note: "adad", liveId: "asd"});
//      await abc.save();

      const notes = await noteModel.find({uid});
      console.log(`NOTES FOUND IS ${notes}`);
      
      res.json({ success: true, notes});
//        res.send("ads");
    } catch (e) {
      res.status(500).json({ "msg": `Error: ${e}` }); 
    }
  });

  return noteRouter;
};