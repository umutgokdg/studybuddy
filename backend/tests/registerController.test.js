// HATALI

const { handleNewUser } = require('../controllers/registerController');
const User = require('../model/User');

jest.mock('../model/User');

describe('handleNewUser', () => {
    let req, res;

    beforeEach(() => {
        req = {
            body: {
                firstname: 'John',
                lastname: 'Doe',
                email: 'johndoe@itu.edu.tr',
                password: 'password123'
            }
        };
        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn()
        };
        findOneSpy = jest.spyOn(User, 'findOne');
        User.findOne = jest.fn();
        User.create = jest.fn();
    });

    afterEach(() => {
        jest.clearAllMocks();
        findOneSpy.mockRestore();
    });

    it('should return 400 with error message if any required field is missing', async () => {
        req.body.firstname = '';

        await handleNewUser(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ message: 'Missing required fields.' });
    });

    it('should return 400 with error message if email is not from ITU', async () => {
        req.body.email = 'johndoe@gmail.com';

        await handleNewUser(req, res);

        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith({ message: 'Please use your ITU email address.' });
    });

    it('should return 409 with error message if email is already registered', async () => {
        User.findOne.mockResolvedValueOnce({ email: req.body.email });

        await handleNewUser(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ email: req.body.email });
        expect(res.status).toHaveBeenCalledWith(409);
        expect(res.json).toHaveBeenCalledWith({ message: 'Email already registered.' });
    });

    it('should send confirmation code email and return success message if user is created', async () => {
        const confirmationCode = 123456;
        const hashedPwd = 'hashedPassword';
        User.findOne.mockResolvedValueOnce(null);
        User.create.mockResolvedValueOnce({});

        await handleNewUser(req, res);

        expect(User.findOne).toHaveBeenCalledWith({ email: req.body.email });
        expect(User.create).toHaveBeenCalledWith(expect.objectContaining({
            first_name: req.body.firstname,
            last_name: req.body.lastname,
            email: req.body.email,
            hashed_pwd: expect.any(String),
            confirmation_code: expect.any(Number)
        }));
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({ message: 'Please check your email for the confirmation code to complete your registration.' });
    });
});