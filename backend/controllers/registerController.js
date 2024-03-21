const User = require('../model/User');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const Mailgen = require('mailgen');

const handleNewUser = async (req, res) => {
    try {
        const { firstname, lastname, email, password } = req.body;
        if (!firstname || !lastname || !email || !password) {
            return res.status(400).json({ "message": "Missing required fields." });
        }

        const emailExtension = email.split("@")[1];

        if (emailExtension !== "itu.edu.tr") {
            return res.status(400).json({ "message": "Please use your ITU email address." });
        }
        const duplicate = await User.findOne({ email: email });

        if (duplicate) {
            return res.status(409).json({ "message": "Email already registered." });
        }


        const confirmationCode = Math.floor(100000 + Math.random() * 900000);
        // Create a nodemailer transporter
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: 'studybuddy.blg411@gmail.com',
                pass: 'uzmwgzrjmceiohuw'
            }
        });

        // Create a Mailgen instance
        const mailGenerator = new Mailgen({
            theme: 'default',
            product: {
                name: 'StudyBuddy',
                link: 'https://www.studybuddy.com'
            }
        });

        // Prepare the email content
        const emailContent = {
            body: {
                name: `${firstname} ${lastname}`,
                intro: 'Welcome to StudyBuddy! We\'re very excited to have you on board.',
                action: {
                    instructions: 'To get started with StudyBuddy, please click here:',
                    button: {
                        color: '#22BC66', // Optional action button color
                        text: 'Confirm your account',
                        link: `http://165.227.134.202:3500/confirm/${confirmationCode.toString()}`
                    }
                },
                outro: 'Need help, or have questions? Just reply to this email, we\'d love to help.'
            }
        };

        // Generate an HTML email using Mailgen
        const emailBody = mailGenerator.generate(emailContent);

        // Send the email
        try {
            await transporter.sendMail({
                from: 'StudyBuddy <',
                to: email,
                subject: 'StudyBuddy Registration Confirmation',
                html: emailBody
            });
        } catch (err) {
            console.error('Failed to send confirmation code:', err);
        }        // Inform user to check their email for the confirmation code
        res.status(200).json({ "message": "Please check your email for the confirmation code to complete your registration." });

        const hashed_pwd = await bcrypt.hash(password, 10);
        const newUser = await User.create({
            "first_name": firstname,
            "last_name": lastname,
            "email": email,
            "hashed_pwd": hashed_pwd,
            "confirmation_code": confirmationCode
        });
    } catch (err) {
        res.status(500).json({ "message": err.message });
    }
}


module.exports = { handleNewUser };

