const { handleConfirm } = require('../controllers/confirmController');
const User = require('../model/User');

describe('handleConfirm', () => {
    let req, res;

    beforeEach(() => {
        req = {
            params: {
                confirm: 'valid_confirmation_code'
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

    it('should return 400 with error message if confirmation code is missing', async () => {
        req.params.confirm = undefined;

        await handleConfirm(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ message: 'Bad Request. Confirmation is failed.' });
    });

    it('should return 400 with error message if user is not found', async () => {
        User.findOne = jest.fn().mockResolvedValueOnce(null);

        await handleConfirm(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ confirmation_code: req.params.confirm });
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ message: 'Confirmation code is not valid or used already.' });
    });

    it('should update user status to "Active" and return 200 with success message', async () => {
        const userFound = {
            confirmation_code: req.params.confirm,
            save: jest.fn().mockResolvedValueOnce({ status: 'Active' })
        };
        User.findOne = jest.fn().mockResolvedValueOnce(userFound);

        await handleConfirm(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ confirmation_code: req.params.confirm });
        expect(userFound.status).toBe('Active');
        expect(userFound.confirmation_code).toBeNull();
        expect(userFound.save).toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({ message: 'User is confirmed.' });
    });

    it('should return 400 with error message if confirmation code does not match', async () => {
        const userFound = {
            confirmation_code: 'different_confirmation_code'
        };
        User.findOne = jest.fn().mockResolvedValueOnce(userFound);

        await handleConfirm(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ confirmation_code: req.params.confirm });
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ message: 'Bad Request. Confirmation is failed. Try Again' });
    });
});