const express = require('express');
const router = express.Router();
const groupController = require('../../controllers/groupController');


router.route('/')
  .get(groupController.getGroups)
  .post(groupController.createGroup)
// .put(groupController.updateGroup)

router.route('/show/:id')
  .get(groupController.getGroupById)

router.route('/showByUser/')
  .get(groupController.getGroupsOfUser)

router.route('/delete/:groupId')
  .delete(groupController.deleteGroup)

router.route('/update/:id')
  .put(groupController.updateGroup)

router.route('/:invite')
  .post(groupController.addUserToGroupByInvitationCode)

router.route('/getUsers/:groupId')
  .get(groupController.getUsersOfGroup)

router.route('/removeUser/:groupId/:userId')
  .put(groupController.removeUserFromGroup)
  
router.route('/leaveGroup/:groupId')
  .put(groupController.leaveGroup) 
//bütün grupları alan ayrı bul bir de kendi grubumu bulayım
module.exports = router;

