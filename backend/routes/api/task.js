const express = require('express');
const router = express.Router();
const taskController = require('../../controllers/taskController');
const verifyJWT = require('../../middleware/verifyJWT');

router.route('/create')
    .post(taskController.createIndividualTask);

router.route('/create/:groupId')
    .post(taskController.createGroupTask);

router.route('/assign/:taskId')
    .put(taskController.assignUsersToTask);

router.route('/edit/:taskId')
    .put(taskController.editTask);

router.route('/delete/:taskId')
    .delete(taskController.deleteTask);

router.route('/')
    .get(taskController.getUserTasks);

router.route('/grouptasks/:groupId')
    .get(taskController.getGroupTasks);

router.route('/closesttasks')
    .get(taskController.getClosestTasks);

router.route('/:taskId')
    .put(taskController.updateTaskDueDate);

router.route('/:taskId/completed')
    .put(taskController.markTaskAsCompleted);

module.exports = router;