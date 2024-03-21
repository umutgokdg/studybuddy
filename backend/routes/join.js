const express = require('express');
const router = express.Router();
const joinController = require('../controllers/joinController');

router.route('/:join')
    .get(joinController.handleJoin);

module.exports = router;