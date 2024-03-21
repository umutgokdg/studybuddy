const { createIndividualTask, createGroupTask, getUserIdFromToken } = require('../controllers/taskController');
const Task = require('../model/Task');
const User = require('../model/User');
const Group = require('../model/Group');



describe('createIndividualTask', () => {
    let req, res;


    beforeEach(() => {
        req = {
            body: {
                title: 'Sample Task',
                description: 'Sample Description',
                deadline: '2022-12-31'
            }
        };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn()
        };
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should return 400 with error message if required fields are missing', async () => {
        req.body.title = undefined;

        await createIndividualTask(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ message: 'Missing required fields.' });
    });

    it('should create a new task and return 200 with the saved task', async () => {
        const userId = 'sampleUserId';
        const newTask = {
            title: req.body.title,
            description: req.body.description,
            due_at: new Date(req.body.deadline),
            created_by: userId,
            users_assigned: [userId]
        };
        Task.prototype.save = jest.fn().mockResolvedValueOnce(newTask);

        await createIndividualTask(req, res);

        expect(Task.prototype.save).toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(newTask);
    });

    it('should handle errors and return 500 with error message', async () => {
        const errorMessage = 'Sample error message';
        console.error = jest.fn();
        Task.prototype.save = jest.fn().mockRejectedValueOnce(new Error(errorMessage));

        await createIndividualTask(req, res);

        expect(console.error).toHaveBeenCalledWith('Error creating task:', errorMessage);
        expect(res.status).toHaveBeenCalledWith(500);
        expect(res.json).toHaveBeenCalledWith({ message: 'Internal Server Error' });
    });
});

