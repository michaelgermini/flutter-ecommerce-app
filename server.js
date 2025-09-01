const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

// Servir les fichiers statiques du dossier build/web
app.use(express.static(path.join(__dirname, 'build/web')));

// Route par défaut pour servir index.html
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web/index.html'));
});

// Démarrer le serveur
app.listen(port, '127.0.0.1', () => {
  console.log(`Serveur Flutter Web démarré sur http://127.0.0.1:${port}`);
  console.log(`Ouverture automatique dans le navigateur...`);
});
