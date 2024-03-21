const { handleJoin } = require('../controllers/joinController');
const Group = require('../model/Group');
const User = require('../model/User');
const jwt = require('jsonwebtoken');

jest.mock('jsonwebtoken');

describe('handleJoin', () => {
    let req, res;

    beforeEach(() => {
        req = {
            params: {
                join: 'valid_join_token'
            }
        };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn()
        };
        updateOneSpy = jest.spyOn(Group, 'updateOne');
        updateOneSpy.mockImplementation(() => Promise.resolve());
    });

    afterEach(() => {
        jest.clearAllMocks();
        updateOneSpy.mockRestore();
    });

    it('should return 400 with error message if join token is missing', async () => {
        req.params.join = undefined;

        await handleJoin(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ message: 'Missing required fields.' });
    });

    it('should return 401 with error message if join token is invalid', async () => {
        jwt.verify.mockImplementation(() => {
            throw new Error();
        });

        await handleJoin(req, res);

        expect(jwt.verify).toHaveBeenCalledWith(
            req.params.join,
            process.env.ACCESS_TOKEN_SECRET
        );
        expect(res.status).toHaveBeenCalledWith(401);
        expect(res.json).toHaveBeenCalledWith({ message: 'Unauthorized, jwt' });
    });

    it('should return 409 with error message if user is already in the group', async () => {
        const decoded = {
            groupId: 'valid_group_id',
            userId: 'valid_user_id'
        };
        jwt.verify.mockReturnValue(decoded);
        const foundedGroup = {
            user_ids: [decoded.userId],
            invited_user_ids: []
        };
        Group.findOne = jest.fn().mockResolvedValueOnce(foundedGroup);
        User.findOne = jest.fn().mockResolvedValueOnce({ _id: decoded.userId });

        await handleJoin(req, res);

        expect(Group.findOne).toHaveBeenCalledWith({ _id: decoded.groupId });
        expect(User.findOne).toHaveBeenCalledWith({ _id: decoded.userId });
        expect(res.status).toHaveBeenCalledWith(409);
        expect(res.json).toHaveBeenCalledWith({ message: 'User already in group.' });
    });

    it('should return 409 with error message if user is not invited to the group', async () => {
        const decoded = {
            groupId: 'valid_group_id',
            userId: 'valid_user_id'
        };
        jwt.verify.mockReturnValue(decoded);
        const foundedGroup = {
            user_ids: [],
            invited_user_ids: []
        };
        Group.findOne = jest.fn().mockResolvedValueOnce(foundedGroup);
        User.findOne = jest.fn().mockResolvedValueOnce({ _id: decoded.userId });

        await handleJoin(req, res);

        expect(Group.findOne).toHaveBeenCalledWith({ _id: decoded.groupId });
        expect(User.findOne).toHaveBeenCalledWith({ _id: decoded.userId });
        expect(res.status).toHaveBeenCalledWith(409);
        expect(res.json).toHaveBeenCalledWith({ message: 'User is not invited to group.' });
    });

    it('should update group and return "ok" if user is invited and not already in the group', async () => {
        const decoded = {
            groupId: 'valid_group_id',
            userId: 'valid_user_id'
        };
        jwt.verify.mockReturnValue(decoded);
        const foundedGroup = {
            user_ids: [],
            invited_user_ids: [decoded.userId],
            save: jest.fn()
        };
        Group.findOne = jest.fn().mockResolvedValueOnce(foundedGroup);
        User.findOne = jest.fn().mockResolvedValueOnce({ _id: decoded.userId });

        await handleJoin(req, res);

        expect(Group.findOne).toHaveBeenCalledWith({ _id: decoded.groupId });
        expect(User.findOne).toHaveBeenCalledWith({ _id: decoded.userId });
        expect(foundedGroup.user_ids).toContain(decoded.userId);
        expect(Group.updateOne).toHaveBeenCalledWith(
            { _id: decoded.groupId },
            { $pull: { invited_user_ids: decoded.userId } }
        );
        expect(foundedGroup.save).toHaveBeenCalled();
        expect(res.json).toHaveBeenCalledWith('ok');
    });
});