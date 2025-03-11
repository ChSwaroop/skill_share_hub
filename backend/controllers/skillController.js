const Skill = require('../models/skillProgress'); // Import the Skill model

// Add a new skill for a user
exports.addSkill = async (req, res) => {
  const { userId, skillName, progressStatus, level } = req.body;

  try {
    const newSkill = new Skill({
      userId, // Assuming you have a userId to associate the skill with a user
      skillName,
      progressStatus,
      level,
    });

    await newSkill.save();
    res.status(201).json({ message: 'Skill added successfully', skill: newSkill });
  } catch (error) {
    console.error('Error adding skill:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get all skills for a user
exports.getUserSkills = async (req, res) => {
  const userId = req.params.userId;

  try {
    const skills = await Skill.find({ userId });
    res.json(skills);
  } catch (error) {
    console.error('Error fetching user skills:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Update skill progress
exports.updateSkillProgress = async (req, res) => {
  const { skillId } = req.params;
  const { progressStatus, level } = req.body;

  try {
    const updatedSkill = await Skill.findByIdAndUpdate(
      skillId,
      { progressStatus, level, updatedAt: Date.now() },
      { new: true }
    );

    if (!updatedSkill) {
      return res.status(404).json({ message: 'Skill not found' });
    }

    res.json({ message: 'Skill updated successfully', skill: updatedSkill });
  } catch (error) {
    console.error('Error updating skill:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete a skill
exports.deleteSkill = async (req, res) => {
  const { skillId } = req.params;

  try {
    const deletedSkill = await Skill.findByIdAndDelete(skillId);

    if (!deletedSkill) {
      return res.status(404).json({ message: 'Skill not found' });
    }

    res.json({ message: 'Skill deleted successfully' });
  } catch (error) {
    console.error('Error deleting skill:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
