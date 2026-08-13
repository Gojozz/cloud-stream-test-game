const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const { google } = require("googleapis");
const Groq = require("groq-sdk");

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: { origin: "*" }
});

app.use(express.static("."));

/* =========================================================
   LUNA AI
========================================================= */

let groq = null;

try {
  const key = process.env.GROQ_API_KEY || "";

  if (key) {
    groq = new Groq({
      apiKey: key
    });

    console.log("LUNA AI ONLINE - GROQ");
  } else {
    console.log("GROQ_API_KEY not found - fallback mode");
  }

} catch (error) {
  console.log("Groq unavailable:", error.message);
}

/* =========================================================
   PLAYERS
========================================================= */

const defaultPlayers = [
  { name: "Rizal", color: "#ff1744" },
  { name: "Budi", color: "#00e5ff" },
  { name: "Siti", color: "#ffd166" },
  { name: "Agus", color: "#2ecc71" },
  { name: "Dewi", color: "#b86bff" }
];

const COLORS = [
  "#ff1744",
  "#00e5ff",
  "#ffd166",
  "#2ecc71",
  "#b86bff",
  "#ff7a00",
  "#ff4fd8",
  "#7c4dff"
];

const MAX_PLAYERS = 5;

let players = [...defaultPlayers];
let waitingPlayers = [];

let round = 0;
let raceRunning = false;
let chatStarted = false;
let chatStream = null;

let lastLunaCall = 0;
const LUNA_COOLDOWN = 8000;

/* =========================================================
   HELPERS
========================================================= */

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function cleanName(name) {
  if (!name) return "";

  return String(name)
    .replace(/[<>]/g, "")
    .replace(/\s+/g, " ")
    .trim()
    .substring(0, 16);
}

function wantsToJoin(text) {
  if (!text) return false;

  const t = text
    .toLowerCase()
    .normalize("NFKC")
    .replace(/[!?.,;:()[\]{}"'`🔥🎮🏁❤️👍😂🤣]/g, " ")
    .replace(/\s+/g, " ")
    .trim();

  // Exact / very clear commands
  const exact = [
    "join",
    "!join",
    "ikut",
    "gabung",
    "join me",
    "pick me",
    "i'm in",
    "im in",
    "count me in",
    "let me play",
    "i want to play",
    "can i play",
    "i want to join",
    "aku ikut",
    "saya ikut",
    "mau ikut",
    "mau gabung",
    "ikut dong",
    "aku mau ikut",
    "saya mau ikut",

    // Spanish
    "me uno",
    "quiero jugar",
    "quiero participar",
    "yo también",

    // Portuguese
    "quero jogar",
    "quero participar",
    "eu também",

    // French
    "je participe",
    "je veux jouer",
    "moi aussi",

    // German
    "ich bin dabei",
    "ich will spielen",
    "ich auch",

    // Vietnamese
    "tham gia",
    "cho toi choi",
    "tôi cũng",

    // Malay
    "nak join",
    "saya ikut",
    "nak masuk",
    "saya nak ikut",

    // Filipino
    "join ako",
    "ako rin",

    // Thai
    "เข้าร่วม",
    "ขอเล่น",
    "เอาด้วย",
    "อยากเล่น",
    "ขอร่วมด้วย",

    // Chinese
    "参加",
    "我要参加",
    "我也要",
    "我要玩",
    "想参加",

    // Japanese
    "参加したい",
    "参加する",
    "やりたい",
    "私も",

    // Korean
    "참여",
    "저도요",
    "같이요",
    "참여하고 싶어요",

    // Arabic
    "أريد المشاركة",
    "أريد أن ألعب",
    "أنا أيضا",
    "شارك",

    // Russian
    "я участвую",
    "я тоже",
    "хочу играть"
  ];

  if (exact.includes(t)) return true;

  // Common phrases where the intent is very clear
  const patterns = [
    /\bi\s*(want|wanna)\s*(to\s*)?(join|play|race)\b/,
    /\b(let|allow)\s+me\s+(to\s+)?(join|play|race)\b/,
    /\bcount\s+me\s+in\b/,
    /\bpick\s+me\b/,
    /\bjoin\s+me\b/,
    /\baku\s+(mau\s+)?(ikut|gabung|main)\b/,
    /\bsaya\s+(mau\s+)?(ikut|gabung|main)\b/,
    /参加.*比赛/,
    /我要.*(参加|玩)/,
    /أريد.*(المشاركة|ألعب)/
  ];

  return patterns.some(re => re.test(t));
}

function alreadyExists(name) {
  const lower = name.toLowerCase();

  return (
    players.some(p => p.name.toLowerCase() === lower) ||
    waitingPlayers.some(p => p.name.toLowerCase() === lower)
  );
}

function addViewerToQueue(name) {
  name = cleanName(name);

  if (!name) return false;
  if (alreadyExists(name)) return false;
  if (waitingPlayers.length >= 20) return false;

  const color =
    COLORS[
      (players.length + waitingPlayers.length) % COLORS.length
    ];

  waitingPlayers.push({
    name,
    color
  });

  console.log(`JOIN: ${name}`);

  io.emit("queueUpdate", {
    waiting: waitingPlayers.map(p => p.name)
  });

  io.emit("aiResponse", {
    speechText:
      `${name} joined the next Marble Race! Good luck!`
  });

  return true;
}

/* =========================================================
   LUNA
========================================================= */

const fallbackComments = [
  "The race is heating up!",
  "Look at that speed!",
  "Anything can happen now!",
  "The finish line is getting closer!",
  "What an incredible battle!",
  "Someone is making a huge comeback!"
];

function fallbackComment() {
  return fallbackComments[
    Math.floor(Math.random() * fallbackComments.length)
  ];
}

async function lunaComment(event, force = false) {

  const now = Date.now();

  if (!force && now - lastLunaCall < LUNA_COOLDOWN) {
    return fallbackComment();
  }

  lastLunaCall = now;

  if (!groq) {
    return fallbackComment();
  }

  try {

    const completion = await groq.chat.completions.create({
      model: "llama-3.1-8b-instant",

      messages: [
        {
          role: "system",
          content:
            "You are Luna, an energetic and friendly live Marble Race host. " +
            "Always respond in natural English. " +
            "One short sentence only. Maximum 14 words. " +
            "Family friendly. Exciting. Never mention AI."
        },
        {
          role: "user",
          content: event
        }
      ],

      temperature: 0.8,
      max_tokens: 30
    });

    const text =
      completion.choices?.[0]?.message?.content?.trim();

    if (text) {
      console.log("LUNA:", text);
      return text;
    }

  } catch (error) {

    console.log(
      "Luna/Groq error:",
      error?.message || error
    );
  }

  return fallbackComment();
}

/* =========================================================
   YOUTUBE CHAT
========================================================= */


async function startYouTubeChat() {
  if (chatStarted) return;

  const {
    YOUTUBE_CLIENT_ID,
    YOUTUBE_CLIENT_SECRET,
    YOUTUBE_REFRESH_TOKEN
  } = process.env;

  if (!YOUTUBE_CLIENT_ID || !YOUTUBE_CLIENT_SECRET || !YOUTUBE_REFRESH_TOKEN) {
    console.log("YouTube Chat: OAuth secrets missing");
    return;
  }

  try {
    const auth = new google.auth.OAuth2(
      YOUTUBE_CLIENT_ID,
      YOUTUBE_CLIENT_SECRET
    );

    auth.setCredentials({
      refresh_token: YOUTUBE_REFRESH_TOKEN
    });

    const youtube = google.youtube({
      version: "v3",
      auth
    });

    const r = await youtube.liveBroadcasts.list({
      part: "id,snippet,status",
      broadcastStatus: "active",
      broadcastType: "all",
      maxResults: 10
    });

    const live = (r.data.items || []).find(
      b => b.snippet?.liveChatId
    );

    if (!live) {
      console.log("YouTube Chat: active broadcast/chat belum ditemukan");
      setTimeout(startYouTubeChat, 10000);
      return;
    }

    const liveChatId = live.snippet.liveChatId;

    console.log("================================");
    console.log("YOUTUBE LIVE CHAT CONNECTED");
    console.log("Broadcast:", live.snippet.title);
    console.log("Live Chat ID:", liveChatId);
    console.log("================================");

    chatStarted = true;
    pollYouTubeChat(youtube, liveChatId, "");
  } catch (error) {
    console.log(
      "YouTube Chat error:",
      error.response?.data || error.message
    );

    chatStarted = false;
    setTimeout(startYouTubeChat, 10000);
  }
}

async function pollYouTubeChat(youtube, liveChatId, pageToken) {
  try {
    const r = await youtube.liveChatMessages.list({
      liveChatId,
      part: "id,snippet,authorDetails",
      pageToken: pageToken || undefined,
      maxResults: 200
    });

    for (const m of r.data.items || []) {
      const author = cleanName(
        m.authorDetails?.displayName || "Viewer"
      );

      const text = (
        m.snippet?.displayMessage || ""
      ).trim();

      if (!text) continue;

      console.log(`[CHAT] ${author}: ${text}`);

      if (wantsToJoin(text)) {
        addViewerToQueue(author);
        continue;
      }

      if (
        command.includes("luna") ||
        command.includes("hello") ||
        command.includes("hi") ||
        command.includes("love")
      ) {
        lunaComment(
          `${author} says: "${text}". Respond warmly to this viewer.`,
          true
        ).then(response => {
          io.emit("aiResponse", {
            speechText: response
          });
        });
      }
    }

    const nextToken = r.data.nextPageToken || "";

    setTimeout(
      () => pollYouTubeChat(youtube, liveChatId, nextToken),
      3000
    );

  } catch (error) {
    console.log(
      "YouTube Chat polling error:",
      error.response?.data || error.message
    );

    chatStarted = false;
    setTimeout(startYouTubeChat, 10000);
  }
}

/* =========================================================
   PREPARE NEXT RACE
========================================================= */

function prepareNextPlayers(lastFinishedIndex) {

  if (!waitingPlayers.length) {
    return;
  }

  const newcomer = waitingPlayers.shift();

  if (!newcomer) {
    return;
  }

  const replaced = players[lastFinishedIndex];

  if (typeof lastFinishedIndex === "number" && replaced) {
    players.splice(lastFinishedIndex, 1, newcomer);
  } else {
    players[players.length - 1] = newcomer;
  }

  io.emit("playerUpdate", {
    players
  });

  io.emit("queueUpdate", {
    waiting: waitingPlayers.map(p => p.name)
  });

  console.log(
    `PLAYER ROTATION: ${replaced?.name || "none"} -> ${newcomer.name}`
  );

  console.log(
    "Players:",
    players.map(p => p.name).join(", ")
  );
}

async function runRace() {

  if (raceRunning) return;

  raceRunning = true;

  while (true) {

    round++;

    console.log(
      `Starting race ${round}`
    );

    const startText =
      await lunaComment(
        `Round ${round} is starting. ${players.length} players are ready.`,
        true
      );

    io.emit("raceStart", {
      round,
      message: startText
    });

    await sleep(2000);

    const positions =
      players.map(() => 35);

    const finished = [];

    const finishPosition = 690;

    while (
      finished.length <
      players.length
    ) {

      for (
        let i = 0;
        i < players.length;
        i++
      ) {

        if (finished.includes(i)) {
          continue;
        }

        positions[i] +=
          8 + Math.random() * 16;

        if (
          positions[i] >=
          finishPosition
        ) {

          positions[i] =
            finishPosition;

          finished.push(i);

          const player =
            players[i];

          io.emit("raceWinner", {
            playerName: player.name,
            position: finished.length
          });

          if (
            finished.length === 1
          ) {

            const text =
              await lunaComment(
                `${player.name} just won round ${round}! Celebrate the winner.`,
                true
              );

            io.emit("aiResponse", {
              speechText: text,
              playerName: player.name,
              playerIndex: i
            });
          }
        }
      }

      io.emit("raceUpdate", {
        positions
      });

      await sleep(100);
    }

    const winner =
      players[finished[0]];

    const finalText =
      await lunaComment(
        `${winner.name} won round ${round}. Invite viewers to join the next race.`,
        true
      );

    io.emit("aiResponse", {
      speechText: finalText,
      playerName: winner.name
    });

    console.log(
      `Winner: ${winner.name}`
    );

    await sleep(4000);

    /*
      Remove the old default/player pool only when
      viewers are waiting.

      This allows YouTube viewers to gradually
      enter the race without suddenly replacing
      everyone.
    */

    if (waitingPlayers.length > 0) {

      prepareNextPlayers(finished[finished.length - 1]);

    }

    await sleep(2000);
  }
}

/* =========================================================
   SOCKET.IO
========================================================= */

io.on("connection", socket => {

  console.log(
    "Display connected:",
    socket.id
  );

  socket.emit("playerUpdate", {
    players
  });

  socket.emit("queueUpdate", {
    waiting:
      waitingPlayers.map(p => p.name)
  });

  socket.emit("aiResponse", {
    speechText:
      "Welcome to Marble Race Live! Type JOIN in chat to race!"
  });

});

/* =========================================================
   SERVER
========================================================= */

server.listen(3000, () => {

  console.log("==============================");
  console.log("MARBLE RACE SERVER");
  console.log("PORT: 3000");
  console.log(
    "LUNA:",
    groq ? "GROQ ONLINE" : "FALLBACK"
  );
  console.log("==============================");

  startYouTubeChat();

  runRace();
});
