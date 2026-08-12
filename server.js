const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

const apiKey = process.env.GEMINI_API_KEY || "";
const genAI = new GoogleGenerativeAI(apiKey);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

app.use(express.static('.'));

// Simulasi/Listener Komentar Live
async function generateAiComment(playerName, guessNumber, winNumber) {
    if (!apiKey) {
        return `Komentar dari ${playerName}: Tebak nomor ${guessNumber}! Mari kita lihat hasilnya!`;
    }
    
    try {
        const isWin = guessNumber === winNumber;
        const prompt = `Kamu adalah 'Luna', seorang AI Host Game Show Live Shorts yang seru, heboh, dan gaul. 
        Pemain bernama ${playerName} menebak angka ${guessNumber}. Angka pemenang roda adalah ${winNumber}.
        ${isWin ? 'Pemain menang!' : 'Pemain belum beruntung.'}
        Buat 1 kalimat singkat (maksimal 15 kata) untuk mengomentari momen ini secara langsung dan seru!`;

        const result = await model.generateContent(prompt);
        return result.response.text().trim();
    } catch (e) {
        console.error("Gemini Error:", e.message);
        return `Komentar heboh dari ${playerName} untuk angka ${guessNumber}! Ayo tebak lagi!`;
    }
}

io.on('connection', (socket) => {
    console.log('Client connected to game stream');
});

// Loop Game Otomatis Setiap 20 Detik
setInterval(async () => {
    const targetNumber = Math.floor(Math.random() * 15) + 1;
    const samplePlayers = ["Rizal", "Budi", "Siti", "Agus", "Dewi"];
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
