const express = require('express');
const router = express.Router();
const resourceController = require('../../controllers/resourceController');

router.route('/:group_id')
    .get(resourceController.getResources)
    .post(resourceController.createResource)

router.route('/:group_id/:id')
    .get(resourceController.getResourceById)
    .delete(resourceController.deleteResource)
    .put(resourceController.updateResource)

module.exports = router;