const Resource = require('../model/Resource');
const jwt = require('jsonwebtoken');
const Group = require('../model/Group');
const User = require('../model/User');
const bcrypt = require('bcrypt');
const PointsEnum = require('../enums/pointsEnum');

const getUserIdFromToken = (req, res) => {
    try {
        const authHeader = req.headers.authorization || req.headers.Authorization;
        if (!authHeader?.startsWith('Bearer ')) {
            const error = new Error('Unauthorized Bereared');
            error.statusCode = 401;
            throw error;
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
        return decoded.id;
    } catch (error) {
        // Handle invalid or expired token
        return res.status(401).json({ "message": "Unauthorized. Tokened" });
    }
};

const getResources = async (req, res) => {
    const userId = getUserIdFromToken(req, res);
    // is user super admin or member of a group
    const group = await Group.findOne({ _id: req.params.group_id });
    const isMember = group.user_ids.includes(userId);


    const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
    if (!isMember && !isSuperAdmin) {
        return res.status(401).json({ "message": "Unauthorized, not member of group" });
    }

    const resources = await Resource.find({ group_id: req.params.group_id });
    if (!resources) {
        return res.status(404).json({ "message": "Resources not found." });
    }
    res.json(resources);
}

const createResource = async (req, res) => {
    if (!req?.body?.title || !req?.body?.link) {
        return res.status(400).json({ "message": "Missing required fields." });
    }

    const duplicate = await Resource.findOne({ title: req.body.title, link: req.body.link });

    if (duplicate) {
        return res.status(409).json({ "message": "Resource already exists." });
    }
    try {

        const userId = getUserIdFromToken(req, res);
        // user_ids is array and should include user id
        const group = await Group.findOne({ _id: req.params.group_id });
        const isMember = group.user_ids.includes(userId);
        const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
        if (!isMember && !isSuperAdmin) {
            return res.status(401).json({ "message": "Unauthorized, not member of group" });
        }
        const description = req.body.description || "";

        const resource = await Resource.create({
            title: req.body.title,
            link: req.body.link,
            uploaded_by: userId,
            uploaded_at: Date.now(),
            description: description,
            group_id: req.params.group_id

        });
        const foundedGroup = group;
        foundedGroup.resource_ids.push(resource._id);
        foundedGroup.save();

        const user = await User.findById(userId);
        user.awardPoints(PointsEnum.UPLOAD_RESOURCE);
        await user.save();

        res.status(200).json(resource);
    } catch (error) {
        res.status(500).json({ "message": "Internal server error. SADS" });
    }
}

const getResourceById = async (req, res) => {
    // user should be member of group or super admin
    const userId = getUserIdFromToken(req, res);

    // is user super admin or member of a group
    const groupId = Resource.findOne({ _id: req.params.id }).group_id;
    const group = await Group.findOne({ _id: groupId });
    const isMember = group.user_ids.includes(userId);
    const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
    if (!isMember && !isSuperAdmin) {
        return res.status(401).json({ "message": "Unauthorized, not member of group" });
    }

    if (!req.params.id) {
        return res.status(400).json({ "message": "Bad request." });
    }
    const resource = await Resource.findOne({ _id: req.params.id });
    if (!resource) {
        return res.status(404).json({ "message": "Resource not found." });
    }
    res.json(resource);
}

const updateResource = async (req, res) => {

    // user should be member of group or super admin
    const userId = getUserIdFromToken(req, res);
    const groupId = Resource.findOne({ _id: req.params.id }).group_id;
    const group = await Group.findOne({ _id: groupId });
    const isMember = group.user_ids.includes(userId);
    const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
    if (!isMember && !isSuperAdmin) {
        return res.status(401).json({ "message": "Unauthorized, not member of group" });
    }

    if (!req.body.title && !req.body.link && !req.body.description) {
        return res.status(400).json({ "message": "Bad request." });
    }

    const resource = await Resource.findOne({ _id: req.params.id });
    if (!resource) {
        return res.status(404).json({ "message": "Resource not found." });
    }
    if (req.body.title) {
        resource.title = req.body.title;
    }
    if (req.body.link) {
        resource.link = req.body.link;
    }
    if (req.body.description) {
        resource.description = req.body.description;
    }
    resource.uploaded_at = Date.now();
    resource.uploaded_by = getUserIdFromToken(req, res);
    resource.save();
    res.json(resource);
}

const deleteResource = async (req, res) => {
    // user should be creator of resource or super admin
    const userId = getUserIdFromToken(req, res);
    const isCreator = await Resource.findOne({ _id: req.params.id, uploaded_by: userId });
    const isSuperAdmin = await User.findOne({ _id: userId, roles: { Student: 2001, Super_Admin: 5050 } });
    if (!isCreator && !isSuperAdmin) {
        return res.status(401).json({ "message": "Unauthorized, not creator of resource" });
    }

    const resource = await Resource.deleteOne({ _id: req.params.id });
    if (!resource) {
        return res.status(404).json({ "message": "Resource not found." });
    }
    //delete resource from group
    const foundedGroup = await Group.findOne({ _id: req.params.group_id });
    const index = foundedGroup.resource_ids.indexOf(req.params.id);
    if (index > -1) {
        foundedGroup.resource_ids.splice(index, 1);
        foundedGroup.save();
    }
    else {
        return res.status(404).json({ "message": "Resource not found in group." });
    }

    res.json(resource);
}

module.exports = {
    getResources,
    createResource,
    getResourceById,
    updateResource,
    deleteResource
}