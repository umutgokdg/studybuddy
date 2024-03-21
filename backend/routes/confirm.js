const express = require('express');
const router = express.Router();
const confirmController = require('../controllers/confirmController');

router.route('/:confirm')
    .get(confirmController.handleConfirm);

module.exports = router;