const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const groupSchema = new Schema({
    title: {
        type: String,
        required: true
    },

    subject: {
        type: String,
        required: true
    },

    resource_ids: [{
        type: Schema.Types.ObjectId,
        ref: 'Resource'
    }],

    task_ids: [{
        type: Schema.Types.ObjectId,
        ref: 'Task'
    }],

    created_at: {
        type: Date,
        default: Date.now()
    },

    created_by: {
        type: Schema.Types.ObjectId,
        ref: 'User'
    },

    user_ids: [{
        type: Schema.Types.ObjectId,
        ref: 'User',
    }],

    invited_user_ids: [{
        type: Schema.Types.ObjectId,
        ref: 'User',
    }]
});

module.exports = mongoose.model('Group', groupSchema);