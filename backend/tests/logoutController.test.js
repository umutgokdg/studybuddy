const { handleLogout } = require('../controllers/logoutController');
const User = require('../model/User');

jest.mock('../model/User');

describe('handleLogout', () => {
    let req, res;

    beforeEach(() => {
        req = {
            cookies: {
                jwt: 'validRefreshToken'
            }
        };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn(),
            clearCookie: jest.fn()
        };
        User.findOne = jest.fn();
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should return 200 with error message if no cookie is found', async () => {
        req.cookies.jwt = undefined;

        await handleLogout(req, res);

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({ message: 'No cookie found.' });
    });

    it('should return 200 with error message if no user is found', async () => {
        User.findOne.mockResolvedValueOnce(null);

        await handleLogout(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ refreshToken: req.cookies.jwt });
        expect(res.clearCookie).toHaveBeenCalledWith('jwt', { httpOnly: true, sameSite: 'None' });
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({ message: 'No user found.' });
    });

    it('should clear refresh token, clear cookie, and return success message if user is found', async () => {
        const userFound = {
            refreshToken: 'validRefreshToken',
            save: jest.fn()
        };
        User.findOne.mockResolvedValueOnce(userFound);

        await handleLogout(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ refreshToken: req.cookies.jwt });
        expect(userFound.refreshToken).toBe('');
        expect(userFound.save).toHaveBeenCalled();
        expect(res.clearCookie).toHaveBeenCalledWith('jwt', { httpOnly: true, sameSite: 'None' });
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({ message: 'Logout successful.' });
    });
});