const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

app.use(express.static('.'));

// Cek dan Load Gemini secara aman tanpa bikin crash jika gagal
let model = null;
try {
    const { GoogleGenerativeAI } = require('@google/generative-ai');
    const apiKey = process.env.GEMINI_API_KEY || "";
    if (apiKey) {
        const genAI = new GoogleGenerativeAI(apiKey);
        model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
        console.log("Gemini AI successfully initialized!");
    }
} catch (e) {
    console.log("Gemini AI SDK not available, falling back to smart template host.");
}

async function generateAiComment(playerName, guessNumber, winNumber) {
    const isWin = guessNumber === winNumber;
    
    // Jika Gemini AI Siap & Key Tersedia
    if (model) {
        try {
            const prompt = `Kamu adalah 'Luna', AI Host Game Show Live Shorts yang heboh. 
            Pemain: ${playerName}, Tebakan: ${guessNumber}, Angka Menang: ${winNumber}.
            Status: ${isWin ? 'Menang' : 'Kalah'}.
            Buat 1 kalimat komentar singkat, seru, dan gaul (maksimal 12 kata)!`;

            const result = await model.generateContent(prompt);
            return result.response.text().trim();
        } catch (e) {
            console.error("Gemini API Error:", e.message);
        }
    }
    
    // Fallback respon otomatis jika AI offline/error
    const comments = [
        `Tebakan angka ${guessNumber} dari ${playerName}! Ayo kita lihat apakah hoki!`,
        `Roda makin kencang! Mampukah ${playerName} menang di angka ${guessNumber}?`,
        `Tulis tebakanmu di chat sekarang! ${playerName} menjagokan angka ${guessNumber}!`,
        `Sensasional! Apakah angka ${winNumber} jadi milik ${playerName}?`
    ];
    return comments[Math.floor(Math.random() * comments.length)];
}

io.on('connection', (socket) => {
    console.log('Stream display connected to Game Server');
});

// Loop Game Otomatis Setiap 20 Detik
setInterval(async () => {
    const targetNumber = Math.floor(Math.random() * 15) + 1;
    const samplePlayers = ["Rizal_Gamer", "Budi_07", "Siti_Charming", "Agus_Racer", "Dewi_Spin"];
    const randomPlayer = samplePlayers[Math.floor(Math.random() * samplePlayers.length)];
    const randomGuess = Math.floor(Math.random() * 15) + 1;

    const speechText = await generateAiComment(randomPlayer, randomGuess, targetNumber);

    io.emit('aiResponse', {
        playerName: randomPlayer,
        guessNumber: randomGuess,
        targetNumber: targetNumber,
        speechText: speechText
    });
}, 20000);

server.listen(3000, () => {
    console.log('AI Game Server running on port 3000');
});
