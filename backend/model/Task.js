const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const tasksSchema = new Schema({
    title: {
        type: String,
        required: true
    },

    description: {
        type: String
    },

    completed: {
        type: Boolean,
        default: false
    },

    created_at: {
        type: Date,
        default: Date.now()
    },

    created_by: {
        type: Schema.Types.ObjectId,
        ref: 'User'
    },

    group_id: {
        type: Schema.Types.ObjectId,
        ref: 'Group',
    },

    due_at: {
        type: Date,
        default: null
    },
    
    users_assigned: [{
        type: Schema.Types.ObjectId,
        ref: 'User'
    }]
});

module.exports = mongoose.model('Task', tasksSchema);