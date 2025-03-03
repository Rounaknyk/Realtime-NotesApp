const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const User = require('../models/user');
const dotenv = require('dotenv');

dotenv.config();
const router = express.Router();

// Register Route
router.post('/register', async (req, res) => {
    try {
        const { name, email, password } = req.body;
        if (!name || !email || !password) return res.status(400).json({ message: 'All fields are required' });

        const existingUser = await User.findOne({ email });
        if (existingUser) return res.status(400).json({ message: 'User already exists' });

        const hashedPassword = await bcrypt.hash(password, 10);
        const uid = uuidv4();

        const user = new User({ uid, name, email, password: hashedPassword });
        await user.save();

        res.status(201).json({user});
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// Login Route
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) return res.status(400).json({ message: 'All fields are required' });

        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ message: 'Invalid credentials' });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

        const token = jwt.sign({ uid: user.uid }, "passwordKey");
        user.token = token;
        await user.save();

        res.status(200).json({ user});
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

module.exports = router;