const User = require('../model/User');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const handleRefreshToken = async (req, res) => {
    const cookies = req.cookies;
    if (!cookies?.jwt) {
        return res.status(401).json({ message: 'It is not your business!' });
    }
    const refreshToken = cookies.jwt;

    const foundUser = await User.findOne({ refreshToken });
    if (!foundUser) {
        return res.status(403).json({ message: 'Token is not valid.' });
    }

    jwt.verify(
        refreshToken,
        process.env.REFRESH_TOKEN_SECRET,
        (err, decodedToken) => {
            if (err || decodedToken.id !== foundUser._id.toString()) {
                return res.status(403).json({ message: 'User IDs not matched.' });
            }
            const accessToken = jwt.sign(
                { "id": decodedToken.id },
                process.env.ACCESS_TOKEN_SECRET,
                { expiresIn: '10m' }
            );
            res.json({ accessToken });
        }
    );
}

module.exports = { handleRefreshToken };
