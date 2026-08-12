const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

// API Key Gemini
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "YOUR_GEMINI_API_KEY";
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

app.use(express.static(__dirname));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Fungsi AI Merespons Pesan Live Chat
async function processLiveChat(username, userMessage) {
  try {
    const prompt = `Kamu adalah LUNA, Host AI cantik & seru untuk Game Show 'SUPER SPIN' di YouTube Live.
Penonton bernama '${username}' mengirim pesan: "${userMessage}".
Tugasmu:
1. Sapa '${username}' dan respon pesannya secara ramah, singkat, dan heboh (maksimal 12 kata).
2. Tentukan satu angka keberuntungan antara 1 sampai 15 untuk memutar roda spin.

Format Jawaban WAJIB JSON persis seperti ini:
{"speechText": "Halo Budi! Semoga angka 7 membawa hoki!", "targetNumber": 7}`;

    const result = await model.generateContent(prompt);
    const responseText = result.response.text();
    
    const cleanJson = responseText.replace(/```json|```/g, '').trim();
    const data = JSON.parse(cleanJson);

    // Kirim hasil ke tampilan browser
    io.emit('aiResponse', {
      speechText: data.speechText,
      targetNumber: data.targetNumber || Math.floor(Math.random() * 15) + 1
    });

  } catch (err) {
    console.error("AI Error / Fallback:", err.message);
    const randomNum = Math.floor(Math.random() * 15) + 1;
    io.emit('aiResponse', {
      speechText: `Terima kasih ${username}! Mari kita putar rodanya ke angka ${randomNum}!`,
      targetNumber: randomNum
    });
  }
}

io.on('connection', (socket) => {
  console.log('⚡ Browser Game Terhubung ke Server AI');

  // Loop Otomatis Simulasi Respon Chat (Setiap 15 Detik) 
  // Biar layar tidak sepi jika chat sedang lengang
  const autoChatLoop = setInterval(() => {
    const dummyNames = ['Rian', 'Budi', 'Siti', 'Agus', 'Dewi', 'Eko'];
    const randomName = dummyNames[Math.floor(Math.random() * dummyNames.length)];
    const randomGuess = Math.floor(Math.random() * 15) + 1;
    
    processLiveChat(randomName, `Saya pasang angka ${randomGuess} min!`);
  }, 15000);

  socket.on('disconnect', () => {
    clearInterval(autoChatLoop);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Server AI berjalan di http://localhost:${PORT}`);
});
