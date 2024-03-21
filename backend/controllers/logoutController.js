const User = require('../model/User');

const handleLogout = async (req, res) => {
    const cookies = req.cookies;
    if (!cookies?.jwt) {
        return res.status(200).json({ "message": "No cookie found." });
    }
    const refreshToken = cookies.jwt;
    // if delete request it means deletion
    if (req.method === 'DELETE' || req.method === 'delete') {
        return res.status(200).json({ "message": "Deletion succesful." });
    }
    const userFound = await User.findOne({ refreshToken }).exec();
    if (!userFound) {
        res.clearCookie('jwt', { httpOnly: true, sameSite: 'None' });
        return res.status(200).json({ "message": "No user found." });
    }

    userFound.refreshToken = '';
    await userFound.save();
    res.clearCookie('jwt', { httpOnly: true, sameSite: 'None' });
    res.status(200).json({ "message": "Logout successful." });
}

module.exports = { handleLogout };