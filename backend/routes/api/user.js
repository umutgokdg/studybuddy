const express = require('express');
const router = express.Router();
const userController = require('../../controllers/userController');

router.route('/')
    .get(userController.getUserById)
    .delete(userController.deleteUser)
    .put(userController.updateUser)

router.route('/all')
    .get(userController.getUsers)

router.route('/profile')
    .get(userController.getProfile)
module.exports = router;