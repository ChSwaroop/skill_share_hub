const express = require('express');
const router = express.Router();
const skillController = require('../controllers/skillController'); // Adjust path as needed

// CREATE - Add a new skill
router.post('/', skillController.createSkill);

// READ - Get all skills
router.get('/', skillController.getAllSkills);

// READ - Search skills by name
// Note: This route must be defined before the /:id route to avoid conflicts
router.get('/search/:name', skillController.searchSkillsByName);

// READ - Get a specific skill by ID
router.get('/:id', skillController.getSkillById);

// UPDATE - Update a skill
router.put('/:id', skillController.updateSkill);

// DELETE - Delete a skill
router.delete('/:id', skillController.deleteSkill);

module.exports = router;