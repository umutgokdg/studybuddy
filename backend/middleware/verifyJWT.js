const jwt = require('jsonwebtoken');

const verifyJWT = (req, res, next) => {
    const authHeader = req.headers.authorization || req.headers.Authorization;
    if (!authHeader?.startsWith('Bearer ')) {
        const error = new Error('Unauthorized');
        error.statusCode = 401;
        throw error;
    }

    const token = authHeader.split(' ')[1];
    jwt.verify(
        token,
        process.env.ACCESS_TOKEN_SECRET,
        (err, decodedToken) => {
            if (err) {
                return res.sendStatus(403);
            }
            req.id = decodedToken.id;
            next();
        }
    );
}

module.exports = verifyJWT;