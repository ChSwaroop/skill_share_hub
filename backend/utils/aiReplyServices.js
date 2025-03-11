const axios = require('axios');

const openaiApiKey = process.env.OPENAI_API_KEY; // Set this in your .env file

// Function to generate an AI-powered reply using OpenAI's API
async function generateAiReply(prompt) {
    try {
        const response = await axios.post(
            'https://api.openai.com/v1/completions',
            {
                model: 'text-davinci-003', // Adjust the model if needed
                prompt,
                max_tokens: 150,           // Define the max length of the response
                temperature: 0.7,          // Creativity level of the response
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${openaiApiKey}`
                }
            }
        );

        const aiReply = response.data.choices[0].text.trim();
        return aiReply;
    } catch (error) {
        console.error('Error generating AI reply:', error);
        throw new Error('Could not generate AI reply');
    }
}

module.exports = {
    generateAiReply
};
