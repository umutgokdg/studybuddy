const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const resourceSchema = new Schema({
    title: {
        type: String,
        required: true
    },

    description: {
        type: String
    },

    link: {
        type: String,
        required: true
    },

    uploaded_at: {
        type: Date,
        default: Date.now()
    },

    uploaded_by: {
        type: Schema.Types.ObjectId,
        ref: 'User'
    },

    group_id: {
        type: Schema.Types.ObjectId,
        ref: 'Group'
    }
});

module.exports = mongoose.model('Resource', resourceSchema);