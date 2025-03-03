const express = require("express");
const userRouter = express.Router();
const mongoose = require('mongoose');
const userModel = require('../models/user')

userRouter.post("/register", async (req, res) => {
    try{

        const {name, email, password, uid} = req.body;

        const existingUser = await userModel.findOne({email});
        if(existingUser){
            return res.status(400).json({"msg" : "User with this email already exists!"});
        }

        let user = new userModel({name, email, password, uid});

        user = await user.save();

        return res.json(user);
        
    }catch(e){
        console.log(`Error signing up: ${e}`);
        return res.json({"msg" : `Error : ${e}`});
    }
});

module.exports = userRouter;