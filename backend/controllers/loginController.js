const User = require('../model/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const handleLogin = async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json({ "message": "Missing required fields." });
    }
    const userFound = await User.findOne({ email: email });
    if (!userFound) {
        return res.status(401).json({ "message": "User not found." });
    }
    if (userFound.status !== 'Active') {
        return res.status(400).json({ "message": "User is not confirmed." });
    }

    const match = await bcrypt.compare(password, userFound.hashed_pwd);
    if (match) {
        const accessToken = jwt.sign(
            { "id": userFound._id },
            process.env.ACCESS_TOKEN_SECRET,
            { expiresIn: '10m' }
        );

        const refreshToken = jwt.sign(
            { "id": userFound._id },
            process.env.REFRESH_TOKEN_SECRET,
            { expiresIn: '4h' }
        );

        userFound.refreshToken = refreshToken;
        await userFound.save();
        res.cookie('jwt', refreshToken, { httpOnly: true, sameSite: 'none', maxAge: 4 * 60 * 60 * 1000 });
        res.json({ userId: userFound._id, accessToken: accessToken });
    } else {
        return res.status(401).json({ "message": "Password is not correct." });
    }
}

module.exports = { handleLogin };

