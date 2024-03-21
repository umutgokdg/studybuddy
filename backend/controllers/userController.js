const User = require('../model/User');
const Group = require('../model/Group');
const Task = require('../model/Task');
const Resource = require('../model/Resource');
const logouter = require('../controllers/logoutController');
const jwt = require('jsonwebtoken');
const BadgeEnum = {
    'Novice': {
        'points': 0,
        'name': 'Novice'
    },
    'Rookie': {
        'points': 50,
        'name': 'Rookie'
    },
    'Beginner': {
        'points': 150,
        'name': 'Beginner'
    },
    'Intermediate': {
        'points': 300,
        'name': 'Intermediate'
    },
    'Advanced': {
        'points': 500,
        'name': 'Advanced'
    },
    'Expert': {
        'points': 750,
        'name': 'Expert'
    },
    'Professional': {
        'points': 1000,
        'name': 'Professional'
    }
    
};

const getUserIdFromToken = (req, res) => {
    try {
        const authHeader = req.headers.authorization || req.headers.Authorization;
        if (!authHeader?.startsWith('Bearer ')) {
            const error = new Error('Unauthorized Bereared');
            error.statusCode = 401;
            throw error;
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
        return decoded.id;
    } catch (error) {
        // Handle invalid or expired token
        return res.status(401).json({ "message": "Unauthorized. Tokened" });
    }
};


const getUsers = async (req, res) => {
    const users = await User.find();
    if(!users) {
        return res.status(404).json({ "message": "Users not found." });
    }
    res.json(users);
}

const getUserById = async (req, res) => {
    const userId = getUserIdFromToken(req, res);
    if(!userId) {
        return res.status(400).json({ "message": "Bad request." });
    }
    const user = await User.findOne({ _id: userId }).exec();
    if(!user) {
        return res.status(404).json({ "message": "User not found." });
    }
    res.json(user);
}

const getProfile = async (req, res) => {
    const userId = getUserIdFromToken(req, res);
    if(!userId) {
        return res.status(400).json({ "message": "Bad request." });
    }

    const foundedUser = await User.findOne({ _id: userId }).exec();
    if(!foundedUser) {
        return res.status(404).json({ "message": "User not found." });
    }

    try {  
        achievedTasks = [];
        activeGroups = [];
        //find tasks that user is member of
        const tasks = await Task.find().exec();
        tasks.forEach(task => {
            if(task.users_assigned.includes(userId)) {
                if(task.completed) {
                    achievedTasks.push(task);
                }
            }
        });

        //find groups that user is member of
        const groups = await Group.find().exec();
        groups.forEach(group => {
            if(group.user_ids.includes(userId)) {
                activeGroups.push(group);
            }
        });

        // const BadgeEnum = {
        //     'Novice': {
        //         'points': 0,
        //         'name': 'Novice'
        //     },
        //     'Rookie': {
        //         'points': 50,
        //         'name': 'Rookie'
        //     },
        //     'Beginner': {
        //         'points': 150,
        //         'name': 'Beginner'
        //     }
        // };

        //find index of current badge by comparing with badgeenum

        let currentBadgeIndex = 0;
        for (let i = 0; i < Object.keys(BadgeEnum).length; i++) {
            if(foundedUser.points >= Object.values(BadgeEnum)[i].points) {
                currentBadgeIndex = i;
            }
        }
        //find next badge
        let nextBadgeIndex = currentBadgeIndex + 1;
        if(nextBadgeIndex >= Object.keys(BadgeEnum).length) {
            nextBadgeIndex = currentBadgeIndex;
        }

        //find next badge points
        let nextBadgePoints = Object.values(BadgeEnum)[nextBadgeIndex].points - foundedUser.points;
        const toNextBadgePoints = nextBadgePoints;
        const user = {
            //concatenate name and surname in nickname
            nickname: foundedUser.first_name + " " + foundedUser.last_name,
            badgeStatistics : {
                currentPoints: foundedUser.points,
                toNextBadgePoints: toNextBadgePoints,
            },
            achievedTasks: achievedTasks.length,
            activeGroups: activeGroups.length,
            createDate: foundedUser.created_at,
        }
        res.json(user);
    } catch (error) {
        console.log(error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

const updateUser = async (req, res) => {
    const userId = getUserIdFromToken(req, res);
    const user = await User.findOne({ _id: userId }).exec();
    if(!user) {
        return res.status(404).json({ "message": "User not found." });
    }
    if(req.body.first_name) {
        user.first_name = req.body.first_name;
    }

    if(req.body.last_name) {
        user.last_name = req.body.last_name;
    }
    
    if(req.body.password) {
        user.password = req.body.password;
    }
    user.save();
    res.json(user);
}

const deleteUser = async (req, res) => {
    const userId = getUserIdFromToken(req, res);


    const user = await User.deleteOne({ _id: userId }).exec();
    

    //find groups that user is member of
    const groups = await Group.find({ user_ids: userId }).exec();

    // if user is creator of group, delete group and all tasks and resources related to that group
    groups.forEach(group => {
        if(group.creator_id == userId) {
            Group.deleteOne({ _id: group._id }).exec();
            Task.deleteMany({ group_id: group._id }).exec();
            Resource.deleteMany({ group_id: group._id }).exec();
        }
    });
    //delete user from groups
    groups.forEach(group => {
        const index = group.user_ids.indexOf(userId);
        if (index > -1) {
            group.user_ids.splice(index, 1);
            group.save();
        }
    });
    //delete user from groups
    const invitedGroups = await Group.find({ invited_user_ids: userId }).exec();
    invitedGroups.forEach(group => {
        const index = group.invited_user_ids.indexOf(userId);
        if (index > -1) {
            group.invited_user_ids.splice(index, 1);
            group.save();
        }
    });

    //find tasks that user is member of
    const tasks = await Task.find({ users_assigned: userId }).exec();
    //delete user from tasks
    tasks.forEach(task => {
        const index = task.users_assigned.indexOf(userId);
        if (index > -1) {
            task.users_assigned.splice(index, 1);
            task.save();
        }
    });

    //if task has not a group, delete task
    const tasks2 = await Task.find({ group_id: null }).exec();
    tasks2.forEach(task => {
        if(task.users_assigned.length == 0) {
            Task.deleteOne({ _id: task._id }).exec();
        }
    });

    // if group has not a user, delete group and all tasks and resources related to that group
    const groups2 = await Group.find().exec();
    groups2.forEach(group => {
        if(group.user_ids.length == 0) {
            Group.deleteOne({ _id: group._id }).exec();
            Task.deleteMany({ group_id: group._id }).exec();
            Resource.deleteMany({ group_id: group._id }).exec();
        }
    });

    // task oluşturan user silinirse, task silinir
    const tasks3 = await Task.find({ creator_id: userId }).exec();
    tasks3.forEach(task => {
        Task.deleteOne({ _id: task._id }).exec();
    });

    // resource oluşturan user silinirse, resource silinir
    const resources = await Resource.find({ creator_id: userId }).exec();
    resources.forEach(resource => {
        Resource.deleteOne({ _id: resource._id }).exec();
    });


    logouter.handleLogout(req, res);
}


module.exports = {
    getUsers,
    getUserById,
    updateUser,
    deleteUser,
    getProfile
}