const mongoose = require('mongoose');
const PointsEnum = require('../enums/pointsEnum');
const Schema = mongoose.Schema;

const userSchema = new Schema({
    first_name: {
        type: String,
        required: true
    },

    last_name: {
        type: String,
        required: true
    },

    email: {
        type: String,
        required: true,
        unique: true
    },

    hashed_pwd: {
        type: String,
        required: true
    },

    roles: {
        Student: {
            type: Number,
            default: 2001
        },
        Super_Admin: {
            type: Number
        }
    },

    points: {
        type: Number,
        default: 0
    },

    badge: {
        type: String,
        default: 'Novice'
    },

    created_at: {
        type: Date,
        default: Date.now()
    },

    refreshToken: {
        type: String
    },

    status: {
        type: String,
        enum: ['Pending', 'Active', 'Inactive'],
        default: 'Pending'
    },

    confirmation_code: {
        type: String,
    },

    individual_tasks: [{
        type: Schema.Types.ObjectId,
        ref: 'Task',
        default: null
    }],

});

userSchema.methods.assignBadge = function () {
    if (this.points >= 1000) {
        this.badge = 'Professional';
    } else if (this.points >= 750) {
        this.badge = 'Expert';
    } else if (this.points >= 500) {
        this.badge = 'Advanced';
    } else if (this.points >= 300) {
        this.badge = 'Intermediate';
    } else if (this.points >= 150) {
        this.badge = 'Beginner';
    } else if (this.points >= 50) {
        this.badge = 'Rookie';
    } else {
        this.badge = 'Novice';
    }
}

userSchema.methods.awardPoints = function (points) {
    this.points += points;
    this.assignBadge();
}

userSchema.methods.deductPoints = function (points) {
    this.points -= points;
    this.assignBadge();
}

module.exports = mongoose.model('User', userSchema);