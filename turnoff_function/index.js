const { google } = require('googleapis');
const { GoogleAuth } = require('google-auth-library'); // Corrección aquí


exports.stopCloudSQLInstance = async (req, res) => {
    try {
        res.status(200).send('Función ejecutada con éxito.');
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Error interno del servidor');
    }
};
