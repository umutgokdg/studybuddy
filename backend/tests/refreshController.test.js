const { handleRefreshToken } = require('../controllers/refreshController');
const User = require('../model/User');
const jwt = require('jsonwebtoken');

jest.mock('../model/User');
jest.mock('jsonwebtoken');

describe('handleRefreshToken', () => {
    let req, res;

    beforeEach(() => {
        req = {
            cookies: {
                jwt: 'validRefreshToken'
            }
        };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn()
        };
        User.findOne = jest.fn();
        jwt.verify = jest.fn();
        jwt.sign = jest.fn();
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should return 401 with error message if jwt cookie is missing', async () => {
        req.cookies.jwt = undefined;

        await handleRefreshToken(req, res);

        expect(res.status).toHaveBeenCalledWith(401);
        expect(res.json).toHaveBeenCalledWith({ message: 'It is not your business!' });
    });

    it('should return 403 with error message if user with the provided refreshToken is not found', async () => {
        User.findOne.mockResolvedValueOnce(null);

        await handleRefreshToken(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ refreshToken: req.cookies.jwt });
        expect(res.status).toHaveBeenCalledWith(403);
        expect(res.json).toHaveBeenCalledWith({ message: 'Token is not valid.' });
    });

    it('should return 403 with error message if the decoded token does not match the user ID', async () => {
        const foundUser = {
            _id: 'valid_user_id'
        };
        User.findOne.mockResolvedValueOnce(foundUser);
        jwt.verify.mockImplementationOnce((token, secret, callback) => {
            const decodedToken = {
                id: 'invalid_user_id'
            };
            callback(null, decodedToken);
        });

        await handleRefreshToken(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ refreshToken: req.cookies.jwt });
        expect(jwt.verify).toHaveBeenCalledWith(
            req.cookies.jwt,
            process.env.REFRESH_TOKEN_SECRET,
            expect.any(Function)
        );
        expect(res.status).toHaveBeenCalledWith(403);
        expect(res.json).toHaveBeenCalledWith({ message: 'User IDs not matched.' });
    });

    it('should generate a new access token and return it', async () => {
        const foundUser = {
            _id: 'valid_user_id'
        };
        User.findOne.mockResolvedValueOnce(foundUser);
        jwt.verify.mockImplementationOnce((token, secret, callback) => {
            const decodedToken = {
                id: 'valid_user_id'
            };
            callback(null, decodedToken);
        });
        jwt.sign.mockReturnValueOnce('newAccessToken');

        await handleRefreshToken(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ refreshToken: req.cookies.jwt });
        expect(jwt.verify).toHaveBeenCalledWith(
            req.cookies.jwt,
            process.env.REFRESH_TOKEN_SECRET,
            expect.any(Function)
        );
        expect(jwt.sign).toHaveBeenCalledWith(
            { id: 'valid_user_id' },
            process.env.ACCESS_TOKEN_SECRET,
            { expiresIn: '10m' }
        );
        expect(res.json).toHaveBeenCalledWith({ accessToken: 'newAccessToken' });
    });
});