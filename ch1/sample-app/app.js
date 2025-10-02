// app.js

const express = require('express');
const app = express();
const port = process.env.PORT || 3000; // Render fournit automatiquement un PORT

app.get('/', (req, res) => {
  res.send('Bienvenue sur mon app déployée avec Render ! 🎉');
});

app.listen(port, () => {
  console.log(`Serveur démarré sur http://localhost:${port}`);
});
