const { logEvents } = require('./logEvents');

const errorHandler = (err, req, res, next) => {
    const { statusCode, message } = err;
    logEvents(message, 'errorLog.txt');
    res.status(statusCode).json({ message });
}

module.exports = errorHandler;