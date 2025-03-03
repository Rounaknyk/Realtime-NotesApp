const mongoose = require('mongoose');

const noteSchema = mongoose.Schema({
    noteId: {
        required: true,
        type: String
    },
    uid: {
        required: true,
        type: String
    },
    note: {
        required: true,
        type: String
    },
    time: {
        required: true,
        type: String,
    },
    date: {
        required: true,
        type: String
    },
    liveId: {
        default: '0000',
        type: String
    },
});

const note = mongoose.model("Notes", noteSchema);

module.exports = note;