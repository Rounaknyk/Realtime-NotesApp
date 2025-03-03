const mongoose = require("mongoose");

const userSchema = mongoose.Schema({
    uid: {
        required: true,
        type: String
    },
    name: {
        required: true,
        type: String
    },
    email: {
        required: true,
        type: String
    },
    password: {
        required: true,
        type: String
    },
});

const user = mongoose.model("Users", userSchema);

module.exports = user;