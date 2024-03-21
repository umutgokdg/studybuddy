const { handleLogin } = require('../controllers/loginController');
const User = require('../model/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

jest.mock('../model/User');
jest.mock('bcrypt');
jest.mock('jsonwebtoken');

describe('handleLogin', () => {
    let req, res;

    beforeEach(() => {
        req = {
            body: {
                email: 'test@example.com',
                password: 'password123'
            }
        };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn(),
            cookie: jest.fn()
        };
        User.findOne = jest.fn();
        bcrypt.compare = jest.fn();
        jwt.sign = jest.fn();
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should return 400 with error message if email or password is missing', async () => {
        req.body.email = undefined;

        await handleLogin(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ message: 'Missing required fields.' });
    });

    it('should return 401 with error message if user is not found', async () => {
        User.findOne.mockResolvedValueOnce(null);

        await handleLogin(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ email: req.body.email });
        expect(res.status).toHaveBeenCalledWith(401);
        expect(res.json).toHaveBeenCalledWith({ message: 'User not found.' });
    });

    it('should return 400 with error message if user is not confirmed', async () => {
        const userFound = {
            status: 'Inactive'
        };
        User.findOne.mockResolvedValueOnce(userFound);

        await handleLogin(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ email: req.body.email });
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ message: 'User is not confirmed.' });
    });

    it('should return 401 with error message if password is not correct', async () => {
        const userFound = {
            status: 'Active',
            hashed_pwd: 'hashedPassword'
        };
        User.findOne.mockResolvedValueOnce(userFound);
        bcrypt.compare.mockResolvedValueOnce(false);

        await handleLogin(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ email: req.body.email });
        expect(bcrypt.compare).toHaveBeenCalledWith(req.body.password, userFound.hashed_pwd);
        expect(res.status).toHaveBeenCalledWith(401);
        expect(res.json).toHaveBeenCalledWith({ message: 'Password is not correct.' });
    });

    it('should generate access token, refresh token, and return access token if password is correct', async () => {
        const userFound = {
            _id: 'valid_user_id',
            status: 'Active',
            hashed_pwd: 'hashedPassword',
            save: jest.fn()
        };
        User.findOne.mockResolvedValueOnce(userFound);
        bcrypt.compare.mockResolvedValueOnce(true);
        jwt.sign.mockReturnValueOnce('validAccessToken');
        jwt.sign.mockReturnValueOnce('validRefreshToken');

        await handleLogin(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ email: req.body.email });
        expect(bcrypt.compare).toHaveBeenCalledWith(req.body.password, userFound.hashed_pwd);
        expect(jwt.sign).toHaveBeenCalledWith(
            { id: userFound._id },
            process.env.ACCESS_TOKEN_SECRET,
            { expiresIn: '10m' }
        );
        expect(jwt.sign).toHaveBeenCalledWith(
            { id: userFound._id },
            process.env.REFRESH_TOKEN_SECRET,
            { expiresIn: '4h' }
        );
        expect(userFound.refreshToken).toBe('validRefreshToken');
        expect(userFound.save).toHaveBeenCalled();
        expect(res.cookie).toHaveBeenCalledWith('jwt', 'validRefreshToken', {
            httpOnly: true,
            sameSite: 'none',
            maxAge: 4 * 60 * 60 * 1000
        });
        expect(res.json).toHaveBeenCalledWith({ accessToken: 'validAccessToken' });
    });
});