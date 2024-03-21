require('dotenv').config();
const express = require('express');
const app = express();
const path = require('path');
const cors = require('cors');
const corsOptions = require('./config/corsOptions');
const { logger } = require('./middleware/logEvents')
const errorHandler = require('./middleware/errorHandler');
const credentials = require('./middleware/credentials');
const cookieParser = require('cookie-parser');
const verifyJWT = require('./middleware/verifyJWT');
const mongoose = require('mongoose');
const connectDB = require('./config/dbConn');
const PORT = process.env.PORT || 3500;


connectDB();

app.use(logger);
app.use(credentials);
app.use(cors(corsOptions));
app.use(express.urlencoded({ extended: false }));

app.use(express.json());
app.use(cookieParser());
app.use('/', express.static(path.join(__dirname, 'public')));

app.use(express.json());
app.use(cookieParser());
app.use('/', express.static(path.join(__dirname, '/public')));

app.use('/', require('./routes/root'));
app.use('/register', require('./routes/register'));
app.use('/confirm', require('./routes/confirm'));
app.use('/login', require('./routes/login'));
app.use('/refresh', require('./routes/refresh'));
app.use('/logout', require('./routes/logout'));
//app.use('/invite', require('./routes/invite'));
app.use('/join', require('./routes/join'));
app.use(verifyJWT);
app.use('/group', require('./routes/api/group'));

app.use('/task', require('./routes/api/task'));
app.use('/resource', require('./routes/api/resource'));
app.use('/user', require('./routes/api/user'));
app.all('*', (req, res) => {
    res.status(404);
    if (req.accepts('html')) {
        res.sendFile(path.join(__dirname, 'views', '404.html'));
    } else if (req, accepts('json')) {
        res.json({ "error": "404 Not Found" });
    } else {
        res.type('txt').send("404 Not Found");
    }
});

app.use(errorHandler);

mongoose.connection.once('open', () => {
    app.listen(PORT, () => {
        console.log(`Server listening on port ${PORT}`);
    });
});

