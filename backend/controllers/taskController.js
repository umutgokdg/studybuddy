const Group = require('../model/Group');
const User = require('../model/User');
const Task = require('../model/Task');
const { get } = require('mongoose');
const jwt = require('jsonwebtoken');
const PointsEnum = require('../enums/pointsEnum');


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

const createIndividualTask = async (req, res) => {

    try {
        const userId = getUserIdFromToken(req, res);
        if (!req?.body?.title || !req?.body?.description) {
            return res.status(400).json({ "message": "Missing required fields." });
        }
        var parsedDeadline = null;
        if (req.body.deadline) {
            parsedDeadline = new Date(req.body.deadline);
        }
        else { }

        const title = req.body.title;
        const description = req.body.description;


        const newTask = new Task({
            title: title,
            description: description,
            due_at: parsedDeadline,
            created_by: userId,
            users_assigned: [userId]
        });
        const savedTask = await newTask.save();

        res.status(200).json(savedTask);
    } catch (error) {
        console.error('Error creating task:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

const createGroupTask = async (req, res) => {
    try {
        const userId = getUserIdFromToken(req, res);



        // check if user is a member of the group or super admin  be aware user_ids is array
        const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } }).exec();
        const isMember = await Group.findOne({ _id: req.params.groupId, user_ids: userId }).exec();
        if (!isSuperAdmin && !isMember) {
            return res.status(401).json({ message: 'Unauthorized' });
        }

        const { groupId } = req.params;
        if (!req?.body?.title || !req?.body?.description) {
            return res.status(400).json({ "message": "Missing required fields." });
        }
        var parsedDeadline = null;
        if (req.body.deadline) {
            parsedDeadline = new Date(req.body.deadline);
        }
        else { }

        const title = req.body.title;
        const description = req.body.description;


        const newTask = new Task({
            title: title,
            description: description,
            created_by: userId,
            group_id: groupId,
            due_at: parsedDeadline,
        });
        const savedTask = await newTask.save();

        const group = await Group.findById(groupId);
        if (!group) {
            return res.status(404).json({ message: 'Group not found' });
        }

        group.task_ids.push(savedTask._id);

        await group.save();

        res.status(200).json(savedTask);
    } catch (error) {
        console.error('Error creating task:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

const assignUsersToTask = async (req, res) => {
    try {
        const emails = req.body.emails;
        const taskId = req.params.taskId;
        if (!req?.body?.emails) {
            return res.status(400).json({ "message": "Missing required fields." });
        }

        // find user ids from emails
        const userIdsTemp = await User.find({ email: emails }).exec();
        const userIds = userIdsTemp.map(user => user._id);

        if (userIds.length !== emails.length) {
            return res.status(400).json({ message: 'No users found with the given emails' });
        }

        const task = await Task.findById(taskId);
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        // check if groupId is null
        if (!task.group_id) {
            return res.status(400).json({ message: 'Task is not a group task' });
        }

        const group = await Group.findById(task.group_id);
        // check if users are wanted to be assigned to the task are members of the group dont use .every() because it will return true if the array is empty
        const AllMember = userIds.every(userId => group.user_ids.includes(userId));
        if (!AllMember) {
            return res.status(400).json({ message: "Users must be members of the group" });
        }

        // check if users are already assigned to the task
        const alreadyAssigned = userIds.every(userId => task.users_assigned.includes(userId));
        if (alreadyAssigned) {
            return res.status(400).json({ message: "Users are already assigned to the task" });
        }



        res.status(200).json(updatedTask);
    } catch (error) {
        console.error('Error assigning users to task:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

const updateTaskDueDate = async (req, res) => {
    try {
        const { taskId } = req.params;
        if (!req?.body?.newDueDate) {
            return res.status(400).json({ "message": "Missing required fields." });
        }

        const { newDueDate } = req.body;

        const updatedTask = await Task.findByIdAndUpdate(taskId, { due_at: new Date(newDueDate) }, { new: true });
        updatedTask.updated_at = Date.now();
        await updatedTask.save();

        if (!updatedTask) {
            return res.status(404).json({ message: 'Task not found' });
        }

        res.status(200).json(updatedTask);
    } catch (error) {
        console.error('Error updating task due date:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

const editTask = async (req, res) => {
    try {

        const taskId = req.params.taskId;
        const task =  await Task.findById(taskId);
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        if (req.body.title) {
            task.title = req.body.title;
            task.updated_at = Date.now();

        }
        if (req.body.description) {
            task.description = req.body.description;
            task.updated_at = Date.now();

        }
        if (req.body.deadline) {
            task.due_at = req.body.deadline;
            task.updated_at = Date.now();

        }

        if(req.body.emails) {
            const emails = req.body.emails;
            // find user ids from emails
            const userIdsTemp = await User.find({ email: emails }).exec();
            const userIds = userIdsTemp.map(user => user._id);
            if (userIds.length !== emails.length) {
                return res.status(400).json({ message: 'No users found with the given emails' });
            }
            if (!task) {
                return res.status(404).json({ message: 'Task not found' });
            }
            
            // check if groupId is null
            if (!task.group_id) {
                return res.status(400).json({ message: 'Task is not a group task' });
            }
    
            const group = await Group.findById(task.group_id);
            // check if users are wanted to be assigned to the task are members of the group dont use .every() because it will return true if the array is empty
            const AllMember = userIds.every(userId => group.user_ids.includes(userId));
            if (!AllMember) {
                return res.status(400).json({ message: "Users must be members of the group" });
            }
            // chan
            //assign user_assigned
            //overwrite the old user_assigned array
            task.users_assigned = userIds;

        
            // wait for the awaits to finish
        }        //wait for the task to save
        await task.save();
        return res.status(200).json(task);


    } catch (error) {
        console.error('Error editing task:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }

}

const deleteTask = async (req, res) => {
    try {
        const { taskId } = req.params;
        // check if user is a member of the group or super admin  be aware user_ids is array
        const userId = getUserIdFromToken(req, res);
        const task = await Task.findById(taskId);
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }
        const group = await Group.findById(task.group_id);
        if (!group) {
            // it is an individual task
            if (task.created_by.toString() !== userId.toString()) {
                return res.status(401).json({ message: 'Unauthorized' });
            }

            const deletedTask = await Task.findByIdAndDelete(taskId);                

        } else {
            // it is a group task
            const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } }).exec();
            const isMember =  group.user_ids.includes(userId);
            if (!isSuperAdmin && !isMember) {
                return res.status(401).json({ message: 'Unauthorized' });
            }


            const deletedTask = await Task.findByIdAndDelete(taskId);

        if (!deletedTask) {
            return res.status(404).json({ message: 'Task not found' });
        }
    }
        res.status(200).json({ message: 'Task deleted successfully' });
    } catch (error) {
        console.error('Error deleting task:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

const getUserTasks = async (req, res) => {
    try {

        const userId = getUserIdFromToken(req, res);

        const alltasks = await Task.find().exec();
        const tasks = alltasks.filter(task => task.users_assigned.includes(userId));
        if (tasks.length === 0) {
            // return res.status(400).json({ message: 'No tasks found for this user' });
            return res.status(200).json([]); // frontend expects an empty array
        }
        const formattedTasks = tasks.map(async task => {
            if (!task.group_id) {
                return {
                    name: task.title,
                    description: task.description,
                    deadline: task.due_at,
                    done: task.completed,
                    taskId: task._id,
                    groupId: null,
                    groupName: null
                }
            }
            const group = await Group.findById(task.group_id);

            return {
                name: task.title,
                description: task.description,
                deadline: task.due_at,
                done: task.completed,
                taskId: task._id,
                groupId: group._id,
                groupName: group.title,
            }
        });
        // wait for all the promises to resolve
        const resolvedTasks = await Promise.all(formattedTasks);

        res.status(200).json(resolvedTasks);
    } catch (error) {
        console.error('Error getting user tasks:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}


const getGroupTasks = async (req, res) => {
    try {
        const { groupId } = req.params;

        const tasks = await Task.find({ group_id: groupId });

        res.status(200).json(tasks);
    } catch (error) {
        console.error('Error getting group tasks:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

const getClosestTasks = async (req, res) => {
    try {
        const userId = getUserIdFromToken(req, res);

        const tasks = await Task.find({ users_assigned: userId })
            .sort({ due_at: 1 })    //sort in ascenging order
            .limit(3);              //limit to 3 results


        // find each group of the tasks and add the group name to the task object

        const formattedTasks = tasks.map(async task => {
            if (!task.group_id) {
                return {
                    name: task.title,
                    description: task.description,
                    deadline: task.due_at,
                    done: task.completed,
                    taskId: task._id,
                    groupId: null,
                    groupName: null
                }
            }

            const group = await Group.findById(task.group_id);
            const groupTitle = group.title;
            const groupId = group._id;
            return {
                name: task.title,
                description: task.description,
                deadline: task.due_at,
                done: task.completed,
                taskId: task._id,
                groupId: group._id,
                groupName: group.title
            }
        });
        // wait for all the promises to resolve
        const resolvedTasks = await Promise.all(formattedTasks);
        res.status(200).json(resolvedTasks);
    } catch (error) {
        console.error('Error getting closest tasks:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

const markTaskAsCompleted = async (req, res) => {
    try {
        const { taskId } = req.params;

        const task = await Task.findById(taskId);

        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        task.completed = !task.completed; // Toggle the completion status

        if (task.completed) {
            const user = await User.findById(task.created_by);
            user.awardPoints(PointsEnum.COMPLETE_TASK);
            await user.save();
        }
        else {
            const user = await User.findById(task.created_by);
            user.deductPoints(PointsEnum.COMPLETE_TASK);
            await user.save();
        }

        await task.save();

        res.status(200).json(task.completed);
    } catch (error) {
        console.error('Error marking task as completed:', error.message);
        res.status(500).json({ message: 'Internal Server Error' });
    }
}

module.exports = {
    createIndividualTask,
    createGroupTask,
    assignUsersToTask,
    updateTaskDueDate,
    getClosestTasks,
    deleteTask,
    editTask,
    getUserTasks,
    getGroupTasks,
    markTaskAsCompleted
}