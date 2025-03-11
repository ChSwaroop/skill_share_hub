const Community = require('../models/Community'); // Import the Community model

// Create a new community
exports.createCommunity = async (req, res) => {
  const { name, description, creatorId } = req.body;

  try {
    const newCommunity = new Community({
      name,
      description,
      creatorId,
      members: [creatorId], // Automatically add creator as a member
    });

    await newCommunity.save();
    res.status(201).json({ message: 'Community created successfully', community: newCommunity });
  } catch (error) {
    console.error('Error creating community:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get community details
exports.getCommunity = async (req, res) => {
  const { communityId } = req.params;

  try {
    const community = await Community.findById(communityId).populate('members', 'name'); // Populate member details

    if (!community) {
      return res.status(404).json({ message: 'Community not found' });
    }

    res.json(community);
  } catch (error) {
    console.error('Error fetching community:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Add a member to a community
exports.addMember = async (req, res) => {
  const { communityId } = req.params;
  const { userId } = req.body;

  try {
    const community = await Community.findById(communityId);

    if (!community) {
      return res.status(404).json({ message: 'Community not found' });
    }

    if (!community.members.includes(userId)) {
      community.members.push(userId);
      await community.save();
      res.json({ message: 'Member added successfully', community });
    } else {
      res.status(400).json({ message: 'User is already a member of this community' });
    }
  } catch (error) {
    console.error('Error adding member:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete a community
exports.deleteCommunity = async (req, res) => {
  const { communityId } = req.params;

  try {
    const deletedCommunity = await Community.findByIdAndDelete(communityId);

    if (!deletedCommunity) {
      return res.status(404).json({ message: 'Community not found' });
    }

    res.json({ message: 'Community deleted successfully' });
  } catch (error) {
    console.error('Error deleting community:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
