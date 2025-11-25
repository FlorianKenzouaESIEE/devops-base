// Importe le module 'supertest' pour tester les requêtes HTTP
const request = require('supertest');

// Importe l'application Node.js (assurez-vous que le chemin est correct)
// Le chemin './app' suppose que ce fichier app.test.js est dans le même dossier que app.js
const server = require('./app'); 

// Définit un groupe de tests pour l'application
describe('Test de l\'API d\'accueil', () => {
    
    // Teste si l'application répond avec le message attendu et le code HTTP 200
    test('devrait répondre avec le texte "Hello, World!" et un code de statut 200', async () => {
        // Effectue une requête GET sur la route racine ('/')
        const response = await request(server).get('/');

        // 1. Vérifie le code de statut HTTP
        expect(response.statusCode).toBe(200);

        // 2. Vérifie le type de contenu (doit être 'text/plain' comme défini dans app.js)
        expect(response.headers['content-type']).toMatch(/text\/plain/);

        // 3. Vérifie le corps de la réponse.
        // ATTENTION : Ce test va ÉCHOUER car vous avez mis 'DevOps Labs!' dans app.js.
        // L'échec est INTENTIONNEL et prouve que le test fonctionne.
        expect(response.text.trim()).toBe('Hello, World!');
    });

    // Assure que le serveur est fermé après les tests pour libérer le port
    afterAll(() => {
        server.close();
    });
});