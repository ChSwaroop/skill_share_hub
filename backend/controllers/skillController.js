const mongoose = require('mongoose');
const Skill = require('../models/user')

// Controller methods for skills
// const skillController = {
// Create a new skill
exports.createSkill = async (req, res) => {
    console.log('Controller: createSkill - Request received:', JSON.stringify(req.body));
    try {
        const skill = new Skill({
            name: req.body.name,
            category: req.body.category,
            description: req.body.description
        });

        console.log('Attempting to save new skill:', skill);
        const newSkill = await skill.save();
        console.log('Skill created successfully with ID:', newSkill._id);
        res.status(201).json(newSkill);
    } catch (error) {
        console.error('Error creating skill:', error);
        // Handle unique constraint violation
        if (error.code === 11000) {
            console.warn('Duplicate skill name detected:', req.body.name);
            return res.status(400).json({ message: 'A skill with this name already exists' });
        }
        res.status(400).json({ message: error.message });
    }
}

// Get all skills
exports.getAllSkills = async (req, res) => {
    console.log('Controller: getAllSkills - Request received with query:', JSON.stringify(req.query));
    try {
        // Support filtering by category
        const filter = {};
        if (req.query.category) {
            filter.category = req.query.category;
            console.log('Filtering skills by category:', req.query.category);
        }

        const skills = await Skill.find(filter);
        console.log(`Retrieved ${skills.length} skills`);
        res.json(skills);
    } catch (error) {
        console.error('Error fetching skills:', error);
        res.status(500).json({ message: error.message });
    }
}

// Get a skill by ID
exports.getSkillById = async (req, res) => {
    console.log('Controller: getSkillById - Request for skill with ID:', req.params.id);
    try {
        const skill = await Skill.findById(req.params.id);
        if (!skill) {
            console.warn('Skill not found with ID:', req.params.id);
            return res.status(404).json({ message: 'Skill not found' });
        }
        console.log('Retrieved skill:', skill);
        res.json(skill);
    } catch (error) {
        console.error('Error fetching skill by ID:', error);
        res.status(500).json({ message: error.message });
    }
}

// Search skills by name
exports.searchSkillsByName = async (req, res) => {
    console.log('Controller: searchSkillsByName - Searching for skills with name pattern:', req.params.name);
    try {
        const skills = await Skill.find({
            name: { $regex: req.params.name, $options: 'i' }
        });
        console.log(`Found ${skills.length} skills matching search pattern`);
        res.json(skills);
    } catch (error) {
        console.error('Error searching skills by name:', error);
        res.status(500).json({ message: error.message });
    }
}

// Update a skill
exports.updateSkill = async (req, res) => {
    console.log('Controller: updateSkill - Request to update skill ID:', req.params.id);
    console.log('Update data:', JSON.stringify(req.body));
    try {
        const updatedSkill = await Skill.findByIdAndUpdate(
            req.params.id,
            {
                name: req.body.name,
                category: req.body.category,
                description: req.body.description
            },
            { new: true, runValidators: true }
        );

        if (!updatedSkill) {
            console.warn('Attempted to update non-existent skill with ID:', req.params.id);
            return res.status(404).json({ message: 'Skill not found' });
        }

        console.log('Skill updated successfully:', updatedSkill);
        res.json(updatedSkill);
    } catch (error) {
        console.error('Error updating skill:', error);
        // Handle unique constraint violation on update
        if (error.code === 11000) {
            console.warn('Duplicate skill name detected on update:', req.body.name);
            return res.status(400).json({ message: 'A skill with this name already exists' });
        }
        res.status(400).json({ message: error.message });
    }
}

// Delete a skill
exports.deleteSkill = async (req, res) => {
    console.log('Controller: deleteSkill - Request to delete skill ID:', req.params.id);
    try {
        const skill = await Skill.findByIdAndDelete(req.params.id);

        if (!skill) {
            console.warn('Attempted to delete non-existent skill with ID:', req.params.id);
            return res.status(404).json({ message: 'Skill not found' });
        }

        console.log('Skill deleted successfully:', skill);
        res.json({ message: 'Skill deleted successfully' });
    } catch (error) {
        console.error('Error deleting skill:', error);
        res.status(500).json({ message: error.message });
    }
}