const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

// Inisialisasi Gemini AI (Masukkan API Key kamu nanti di sini atau via Environment Variable)
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "GEMINI_API_KEY_KAMU";
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

app.use(express.static(__dirname));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Fungsi Simulasi/Logika AI Merespons Chat
async function handleUserChat(username, message) {
  try {
    const prompt = `Kamu adalah LUNA, Host AI interaktif untuk Live Game Show 'SUPER SPIN'.
Penonton bernama '${username}' mengirim pesan: "${message}".
Tugasmu:
1. Jawab pesan mereka secara singkat, seru, ceria, dan interaktif (maksimal 15 kata).
2. Jika mereka menebak angka 1-15, semangati mereka.
3. Tentukan satu angka pemenang acak antara 1 sampai 15.

Format respons WAJIB JSON:
{"speechText": "Jawaban kamu di sini", "targetNumber": 7}`;

    const result = await model.generateContent(prompt);
    const responseText = result.response.text();
    
    // Clean & Parse JSON
    const cleanJson = responseText.replace(/```json|```/g, '').trim();
    const data = JSON.parse(cleanJson);

    // Kirim ke tampilan browser
    io.emit('aiResponse', {
      speechText: data.speechText,
      targetNumber: data.targetNumber || Math.floor(Math.random() * 15) + 1
    });

  } catch (err) {
    console.error("AI Error:", err);
    // Fallback jika API Key belum dipasang / error
    const targetNum = Math.floor(Math.random() * 15) + 1;
    io.emit('aiResponse', {
      speechText: `Halo ${username}! Taruhan kamu diproses, mari kita putar ke angka ${targetNum}!`,
      targetNumber: targetNum
    });
  }
}

io.on('connection', (socket) => {
  console.log('⚡ Browser terhubung ke Server AI');

  // Loop simulasi pemicu AI setiap 12 detik (untuk tes live streaming)
  const autoLoop = setInterval(() => {
    const dummyUsers = ['Budi', 'Rian', 'Siti', 'Agus', 'Dewi'];
    const randomUser = dummyUsers[Math.floor(Math.random() * dummyUsers.length)];
    const randomGuess = Math.floor(Math.random() * 15) + 1;
    
    handleUserChat(randomUser, `Saya tebak angka ${randomGuess} min!`);
  }, 12000);

  socket.on('disconnect', () => {
    clearInterval(autoLoop);
    console.log('❌ Browser terputus');
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Server AI berjalan di http://localhost:${PORT}`);
});
