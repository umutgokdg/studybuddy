const { format } = require('date-fns');
const {v4: uuid} = require('uuid');

const fs = require('fs');
const fsPromises = fs.promises;
const path = require('path');

const logEvents = async (message, logName) => {
    const dateTime = `${format(new Date(), 'yyyy-MM-dd')}`;
    const logItem = `${dateTime}\t${uuid()}\t${message}\n`;

    try {
        if(!fs.existsSync(path.join(__dirname, `../logs`))) {
            await fsPromises.mkdir(path.join(__dirname, `../logs`));
        }
        await fsPromises.appendFile(path.join(__dirname, `../logs/${logName}.txt`), logItem);
    } catch (error) {
        console.log(error);
    }
}

const logger = (req, res, next) => {
    const { method, url } = req;
    const message = `${method}\t${url}`;
    logEvents(message, 'accessLog');
    next();
}

module.exports = {
    logger,
    logEvents
}
