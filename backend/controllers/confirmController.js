const User = require('../model/User');
const handleConfirm = async (req, res) => {
    if (!req?.params?.confirm) {
        return res.status(400).json({ message: 'Bad Request. Confirmation is failed.' });
    }
    //const userFound = await User.findOne({ confirmation_code: req.params.confirm}).exec();
    const userFound = await User.findOne({ confirmation_code: req.params.confirm });

    if (!userFound) {
        return res.status(400).json({ message: 'Confirmation code is not valid or used already.' });
    }

    if (userFound.confirmation_code === req.params.confirm) {
        userFound.status = 'Active';
        userFound.confirmation_code = null;
        const result = await userFound.save();
        return res.status(200).json({ message: 'User is confirmed.' });

    }
    else {
        return res.status(400).json({ message: 'Bad Request. Confirmation is failed. Try Again' });
    }
}

module.exports = {
    handleConfirm
}