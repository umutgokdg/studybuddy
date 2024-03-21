const Group = require('../model/Group');
const User = require('../model/User');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const Mailgen = require('mailgen');
const PointsEnum = require('../enums/pointsEnum');
const Resource = require('../model/Resource');
const Task = require('../model/Task');

const getUserIdFromToken = (req, res) => {
    try {
        const authHeader = req.headers.authorization || req.headers.Authorization;
        if (!authHeader?.startsWith('Bearer ')) {
            const error = new Error('Unauthorized');
            error.statusCode = 401;
            throw error;
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
        return decoded.id;
    } catch (error) {
        // Handle invalid or expired token
        return res.status(401).json({ "message": "Unauthorized" });
    }
};

const getGroups = async (req, res) => {
    // check if user is logged in
    const userId = getUserIdFromToken(req, res);

    // check if user is super admin

    const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
    if (!isSuperAdmin) {
        return res.status(401).json({ "message": "Unauthorized, not super admin" });
    }

    const groups = await Group.find();
    if (!groups) {
        return res.status(404).json({ "message": "Groups not found." });
    }
    res.json(groups);
}



const createGroup = async (req, res) => {
    if (!req?.body?.title || !req?.body?.subject) {
        return res.status(400).json({ "message": "Missing required fields." });
    }

    const duplicate = await Group.findOne({ title: req.body.title, subject: req.body.subject });

    if (duplicate) {
        return res.status(409).json({ "message": "Group already exists." });
    }
    try {

        const userId = getUserIdFromToken(req, res);

        const group = await Group.create({
            title: req.body.title,
            subject: req.body.subject,
            created_by: userId,
            user_ids: [userId],
            created_at: Date.now()
        });


        // Award points for creating a group
        const user = await User.findById(userId);
        user.awardPoints(PointsEnum.CREATE_GROUP);
        await user.save();

        res.status(200).json(group);
    } catch (error) {
        res.status(500).json({ "message": "Internal server error" });
    }
}

// send email to user with invite code
const addUserToGroupByInvitationCode = async (req, res) => {
    const userId = getUserIdFromToken(req, res);

    //check if user is a member in the group or super admin
    const group = await Group.findOne({ _id: req.params.invite });
    if (!group) {
        return res.status(404).json({ "message": "Group not found." });
    }

    const isMember = group.user_ids.includes(userId);
    const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
    if (!isMember && !isSuperAdmin) {
        return res.status(401).json({ "message": "You are not a member of the group!" });
    }
    const { email } = req.body;


    if (!email || !req.params.invite) {
        return res.status(400).json({ "message": "Missing required fields." });
    }
    const foundedGroup = group;


    //check any user with this email exists
    const foundedUserToInvite = await User.findOne({ email: email });
    if (!foundedUserToInvite) {
        return res.status(404).json({ "message": "User not found. " });
    }
    // if user is not active

    if(foundedUserToInvite.status !== 'Active') {
        return res.status(400).json({ "message": "User is not active. " });
    }
    //check if user is already in the group
    const isUserInGroup = foundedGroup.user_ids.includes(foundedUserToInvite._id);
    if (isUserInGroup) {
        return res.status(409).json({ "message": "User already in the group." });
    }

    try {

        // check if the group is created by the user logged in

        if (foundedGroup.created_by.toString() !== userId) {
            return res.status(401).json({ "message": "Unauthorized, group created by another user" });
        }

        // add user to invited_user_ids if not already in
        if (!foundedGroup.invited_user_ids.includes(foundedUserToInvite._id)) {
            foundedGroup.invited_user_ids.push(foundedUserToInvite._id);
            await foundedGroup.save();
        }

        // send email to join the group with crypted invite code
        const inviteCode = jwt.sign({ groupId: foundedGroup._id, userId: foundedUserToInvite._id }, process.env.ACCESS_TOKEN_SECRET, { expiresIn: '1h' });


        // Create a nodemailer transporter
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: 'studybuddy.blg411@gmail.com',
                pass: 'uzmwgzrjmceiohuw'
            }
        });
        const mailGenerator = new Mailgen({
            theme: 'default',
            product: {
                name: 'StudyBuddy',
                link: 'https://www.studybuddy.com'
            }
        });
        const emailContent = {
            body: {
                name: `${email}`,
                intro: 'You have been invited to join a group on StudyBuddy',
                action: {
                    instructions: 'To join a group, please click here:',
                    button: {
                        color: '#22BC66', // Optional action button color
                        text: 'Join the group',
                        link: `http://165.227.134.202:3500/join/${inviteCode}`
                    }
                },
                outro: 'Need help, or have questions? Just reply to this email, we\'d love to help.'
            }
        };
        const emailBody = mailGenerator.generate(emailContent);

        // Send the email
        try {
            await transporter.sendMail({
                from: 'StudyBuddy <',
                to: email,
                subject: 'StudyBuddy Invitation',
                html: emailBody
            });
        } catch (error) {
            return res.status(500).json({ "message": "Internal server error." });
        }
    } catch (error) {
        res.status(500).json({ "message": "Internal server error." });
    }
    res.status(200).json({ "message": "Invite sent successfully." });

    // update group with invite code
}

//router.route('/show/:id')
//.get(groupController.getGroupById)

const getGroupById = async (req, res) => {
    const userId = getUserIdFromToken(req, res);


    if (!req.params.id) {
        return res.status(400).json({ "message": "Missing required fields." });
    }

    const group = await Group.findOne({ _id: req.params.id });
    if (!group) {
        return res.status(404).json({ "message": "Group not found." });
    }

    //check if user is a member in the group or super admin 
    const isMember = group.user_ids.includes(userId);
    const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
    if (!isMember && !isSuperAdmin) {
        return res.status(401).json({ "message": "You are not a member of the group!" });
    }
    const tasks = await Task.find({ group_id: group._id });
    const resources = await Resource.find({ group_id: group._id });
    const admin = await User.findOne({ _id: group.created_by });
    const formattedUsers = await Promise.all(group.user_ids.map(async user => {
        const foundedUser = await User.findOne({ _id: user });
        return {
            nickname: foundedUser.first_name + " " + foundedUser.last_name,
            userId: foundedUser._id
        }
    }
    ))
    const formattedTasks = await Promise.all(tasks.map(async task => {
        //find users first and last name user_assigned to task
        const users_assigned = task.users_assigned;
        const task_users = await Promise.all(users_assigned.map(async user => {
            const user_in_task = await User.findOne({ _id: user }).exec();
            return user_in_task.first_name + " " + user_in_task.last_name;
        }));
        return {
            name: task.title,
            description: task.description,
            deadline: task.due_at,
            done: task.completed,
            taskId: task._id,
            groupId: task.group_id,
            usersAssigned: task_users
        }
    }));
    const formattedResources = resources.map(resource => {
        return {
            title: resource.title,
            link: resource.link,
            description: resource.description,
            resourceId: resource._id
        }
    })
    const formattedGroup = {
        name: group.title,
        subject: group.subject,
        admin: admin.first_name + " " + admin.last_name,
        TaskList: formattedTasks,
        ResourceList: formattedResources,
        groupId: group._id,
        users: formattedUsers,
        adminId: group.created_by
    }
    res.json(formattedGroup);
}

const deleteGroup = async (req, res) => {
    const userId = getUserIdFromToken(req, res);
    if (!userId) {
        return res.status(401).json({ "message": "Login first!" });
    }

    if (!req.params.groupId) {
        return res.status(400).json({ "message": "Missing required fields." });
    }

    const group = await Group.findById(req.params.groupId);
    if (!group) {
        return res.status(404).json({ "message": "Group not found." });
    }

    //check if user is the creator of the group or super admin
    const isCreator = group.created_by.toString() === userId;


    const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
    if (!isCreator && !isSuperAdmin) {
        return res.status(401).json({ "message": "You are not the creator of the group!" });
    }


    try {
        const groups = await Group.deleteOne({ _id: req.params.groupId });
        //delete group from users
        const users = await User.find({ group_ids: req.params.groupId });
        users.forEach(user => {
            const index = user.group_ids.indexOf(req.params.groupId);
            if (index > -1) {
                user.group_ids.splice(index, 1);
                user.save();
            }
        });
        // delete tasks of group
        const tasks = await Task.deleteMany({ group_id: req.params.groupId });
        // delete resources of group
        const resources = await Resource.deleteMany({ group_id: req.params.groupId });
        // delete group from groups invited

        res.status(200).json({ "message": "Deletion is successful!" });
    } catch (error) {
        res.status(404).json({ "message": "Deletion is not successful!" });
    }
}

const getUsersOfGroup = async (req, res) => {
    const userId = getUserIdFromToken(req, res);
    if (!userId) {
        return res.status(401).json({ message: 'Login first!' });
    }
    const group = await Group.findById(req.params.groupId);
    //check if user is a member in the group or super admin
    const isMember = group.user_ids.includes(userId);
    const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });

    if (!isMember && !isSuperAdmin) {
        return res.status(401).json({ message: 'You are not a member of the group!' });
    }


    try {
        const groupId = req.params.groupId;

        const group = await Group.findById(groupId).populate('user_ids');

        if (!group) {
            return res.status(404).json({ message: 'Group not found' });
        }

        res.status(200).json(group.user_ids);
    } catch (error) {
        console.error('Error getting users of group:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

const leaveGroup = async (req, res) => {
    const userId = getUserIdFromToken(req, res);
    if (!userId) {
        return res.status(401).json({ message: 'Login first!' });
    }

    try {
        const group = await Group.findById(req.params.groupId);
        if (!group) {
            return res.status(404).json({ message: 'Group not found' });
        }

        // if user is the creator of the group, delete the group
        if (group.created_by.toString() === userId) {
            return deleteGroup(req, res);
        }

        const index = group.user_ids.indexOf(userId);
        if (index === -1) {
            return res.status(404).json({ message: 'User is not a member of the group' });
        }

        group.user_ids.splice(index, 1);
        await group.save();

        // make tasks of the user unassigned
        const tasks = await Task.find({ group_id: req.params.groupId });
        tasks.forEach(task => {
            const index = task.users_assigned.indexOf(userId);
            if (index > -1) {
                task.users_assigned.splice(index, 1);
                task.save();
            }
        });

        // if task has no users assigned, assign it to the creator of the group
        tasks.forEach(async task => {
            if (task.users_assigned.length === 0) {
                task.users_assigned.push(group.created_by);
                await task.save();
            }
        });

        
        // if task was created by the user, assign it to the creator of the group
        tasks.forEach(async task => {
            if (task.created_by.toString() === userId) {
                task.created_by = group.created_by;
                await task.save();
            }
        });

    } catch (error) {
        console.error('Error leaving group:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}


const removeUserFromGroup = async (req, res) => {
    const userId = getUserIdFromToken(req, res);

    try {
        const group = await Group.findById(req.params.groupId);
        if (!group) {
            return res.status(404).json({ message: 'Group not found' });
        }

        // check if user is the creator of the group or super admin

        const isCreator = group.created_by.toString() === userId;
        const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
        if (!isCreator && !isSuperAdmin) {
            return res.status(401).json({ message: 'You are not the creator of the group!' });
        }


        if (req.params.userId.toString() === userId) {
            return res.status(401).json({ message: 'You cannot remove yourself from the group!' });
        }
        const user = await User.findById(req.params.userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const index = group.user_ids.indexOf(req.params.userId);
        if (index === -1) {
            return res.status(404).json({ message: 'User is not a member of the group' });
        }

        group.user_ids.splice(index, 1);
        await group.save();

        // make tasks of the user unassigned
        const tasks = await Task.find({ group_id: req.params.groupId });
        tasks.forEach(task => {
            const index = task.users_assigned.indexOf(req.params.userId);
            if (index > -1) {
                task.users_assigned.splice(index, 1);
                task.save();
            }
        });

        // if task was created by the user, assign it to the creator of the group
        tasks.forEach(async task => {
            if (task.created_by.toString() === req.params.userId) {
                task.created_by = group.created_by;
                await task.save();
            }
        });

        // if task has no users assigned, assign it to the creator of the group
        tasks.forEach(async task => {
            if (task.users_assigned.length === 0) {
                task.users_assigned.push(group.created_by);
                await task.save();
            }
        });



        

        res.status(200).json({ message: 'User removed from group successfully' });
    } catch (error) {
        console.error('Error removing user from group:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

const updateGroup = async (req, res) => {
    // check if user is a member in the group or super admin
    const userId = getUserIdFromToken(req, res);

    const group = await Group.findById(req.params.id);

    if (!group) {
        return res.status(404).json({ message: 'Group not found' });
    }

    const isMember = group.user_ids.includes(userId);
    const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
    if (!isMember && !isSuperAdmin) {
        return res.status(401).json({ message: 'You are not a member of the group!' });
    }

    try {
        const { title, subject } = req.body;

        if (!title && !subject) {
            return res.status(400).json({ message: 'Either title or subject must be provided' });
        }

        if (title) {
            group.title = title;
        }

        if (subject) {
            group.subject = subject;
        }
        await group.save();

        res.status(200).json({ message: 'Group updated successfully' });
    } catch (error) {
        console.error('Error updating group:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

// give groups of user

const getGroupsOfUser = async (req, res) => {

    const userId = getUserIdFromToken(req, res);

    try {
        const allgroups = await Group.find();
        // find how many groups the user is in
        const groups = allgroups.filter(group => group.user_ids.includes(userId));
        if (!groups) {
            // return res.status(404).json({ "message": "Groups not found." });
            return res.json([]); // frontend request
        }
        // change the format of groups

        const formattedGroups = await Promise.all(groups.map(async group => {
            const tasks = await Task.find({ group_id: group._id });
            const resources = await Resource.find({ group_id: group._id });
            const admin = await User.findOne({ _id: group.created_by });
            const formattedUsers = await Promise.all(group.user_ids.map(async user => {
                const foundedUser = await User.findOne({ _id: user });
                return {
                    nickname: foundedUser.first_name + " " + foundedUser.last_name,
                    userId: foundedUser._id
                }
            }
            ))


            const formattedTasks = await Promise.all(tasks.map(async task => {
                //find users first and last name user_assigned to task
                const users_assigned = task.users_assigned;
                const task_users = await Promise.all(users_assigned.map(async user => {
                    const user_in_task = await User.findOne({ _id: user }).exec();
                    return user_in_task.first_name + " " + user_in_task.last_name;
                }));
                return {
                    name: task.title,
                    description: task.description,
                    deadline: task.due_at,
                    done: task.completed,
                    taskId: task._id,
                    groupId: task.group_id,
                    usersAssigned: task_users
                }
            }));

            const formattedResources = resources.map(resource => {
                return {
                    title: resource.title,
                    link: resource.link,
                    description: resource.description,
                    resourceId: resource._id
                }
            })
            //wait for all tasks to be formatted
            return {
                name: group.title,
                subject: group.subject,
                admin: admin.first_name + " " + admin.last_name,
                TaskList: formattedTasks,
                ResourceList: formattedResources,
                groupId: group._id,
                users: formattedUsers,
                adminId: group.created_by
            }
        }
        ))



        // send howmanygroups and groups
        res.json(formattedGroups);
    } catch (error) {
        res.status(500).json({ "message": "Internal Server Error" });
    }
}


module.exports = {
    getGroups,
    createGroup,
    addUserToGroupByInvitationCode,
    getGroupById,
    deleteGroup,
    getUsersOfGroup,
    removeUserFromGroup,
    updateGroup,
    getGroupsOfUser,
    leaveGroup
}  
