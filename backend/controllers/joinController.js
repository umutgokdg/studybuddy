const User = require('../model/User');
const Group = require('../model/Group');
const jwt = require('jsonwebtoken');

const getUserIdFromToken = (req, res) => {
    try {
        const authHeader = req.headers.authorization || req.headers.Authorization;
        if (!authHeader?.startsWith('Bearer ')) {
            const error = new Error('Unauthorized Bereared');
            error.statusCode = 401;
            throw error;
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
        return decoded.id;
    } catch (error) {
        // Handle invalid or expired token
        return res.status(401).json({ "message": "Unauthorized. Tokened" });
    }
};

const handleJoin = async (req, res) => {
    const { join } = req.params;
    if (!join) {
        return res.status(400).json({ "message": "Missing required fields." });
    }
    // check if user is logged in
    // const userId = getUserIdFromToken(req, res);
    // if(!userId) {
    //     return res.status(401).json({ "message": "Unauthorized, userid" });
    // }
    try {
        const decoded = jwt.verify(
            join,
            process.env.ACCESS_TOKEN_SECRET,
        );

        const foundedGroup = await Group.findOne({ _id: decoded.groupId }).exec();
        const foundedUser = await User.findOne({ _id: decoded.userId }).exec();

        if (foundedUser.status !== 'Active') {
            return res.status(409).json({ "message": "User has not confirmed yet." });
        }
        // check if user is already in group
        if (foundedGroup.user_ids.includes(foundedUser._id)) {
            return res.status(409).json({ "message": "User already in group." });
        }

        //check if user is invited to group
        if (!foundedGroup.invited_user_ids.includes(foundedUser._id)) {
            return res.status(409).json({ "message": "User is not invited to group." });
        }

        foundedGroup.user_ids.push(foundedUser._id);

        await Group.updateOne(
            { _id: decoded.groupId },
            { $pull: { invited_user_ids: foundedUser._id } }
        );

        foundedGroup.save();
        res.json("ok")
    } catch (error) {
        return res.status(401).json({ "message": "Token is not valid." });
    }
}

module.exports = {
    handleJoin
}

//TODO yeni göndersen bile eski gönderdiğin link çalışıyor mu? çalışıyorsa çalışmaması lazım
//TODO access token expired ise uyar yeni link iste
