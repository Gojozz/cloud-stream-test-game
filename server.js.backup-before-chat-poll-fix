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

  if (
    !YOUTUBE_CLIENT_ID ||
    !YOUTUBE_CLIENT_SECRET ||
    !YOUTUBE_REFRESH_TOKEN
  ) {
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

    console.log("================================");
    console.log("YOUTUBE CHAT DIAGNOSTIC");
    console.log("================================");

    // Identify the channel belonging to this OAuth token
    const channelResponse =
      await youtube.channels.list({
        part: "id,snippet",
        mine: true
      });

    const channel =
      channelResponse.data.items?.[0];

    if (!channel) {
      console.log("YouTube OAuth: NO CHANNEL FOUND");
      setTimeout(startYouTubeChat, 15000);
      return;
    }

    console.log(
      "OAuth Channel:",
      channel.snippet?.title
    );

    console.log(
      "OAuth Channel ID:",
      channel.id
    );

    // First: active broadcasts
    console.log("Searching active broadcasts...");

    const activeResponse =
      await youtube.liveBroadcasts.list({
        part: "id,snippet,status,contentDetails",
        broadcastStatus: "active",
        broadcastType: "all",
        maxResults: 50
      });

    let broadcasts =
      activeResponse.data.items || [];

    console.log(
      `Active broadcasts found: ${broadcasts.length}`
    );

    // Fallback: recent/all broadcasts
    if (!broadcasts.length) {

      console.log(
        "No active broadcast. Searching recent broadcasts..."
      );

      const recentResponse =
        await youtube.liveBroadcasts.list({
          part: "id,snippet,status,contentDetails",
          mine: true,
          broadcastStatus: "all",
          broadcastType: "all",
          maxResults: 50
        });

      broadcasts =
        recentResponse.data.items || [];

      console.log(
        `Broadcasts returned: ${broadcasts.length}`
      );
    }

    // Find a live broadcast that has a Live Chat ID
    let selected = null;

    for (const broadcast of broadcasts) {

      const status =
        broadcast.status?.lifeCycleStatus;

      const channelId =
        broadcast.snippet?.channelId;

      const liveChatId =
        broadcast.snippet?.liveChatId;

      console.log(
        "Broadcast:",
        broadcast.id,
        "| status:",
        status,
        "| channel:",
        channelId || "UNKNOWN",
        "| chat:",
        liveChatId ? "YES" : "NO",
        "| title:",
        broadcast.snippet?.title || ""
      );

      if (
        status === "live" &&
        channelId === channel.id &&
        liveChatId
      ) {
        selected = broadcast;
        break;
      }
    }

    if (!selected) {

      console.log(
        "No active broadcast with Live Chat found."
      );

      console.log(
        "Retrying YouTube Chat in 10 seconds..."
      );

      setTimeout(
        startYouTubeChat,
        10000
      );

      return;
    }

    const liveChatId =
      selected.snippet.liveChatId;

    console.log("================================");
    console.log("ACTIVE BROADCAST FOUND");
    console.log("Broadcast ID:", selected.id);
    console.log(
      "Broadcast Title:",
      selected.snippet?.title
    );
    console.log("Live Chat ID:", liveChatId);
    console.log("================================");

    chatStarted = true;

    startChatStream(
      youtube,
      liveChatId
    );

  } catch (error) {

    console.log(
      "YouTube Chat diagnostic error:"
    );

    console.log(
      error.response?.data ||
      error.message ||
      error
    );

    chatStarted = false;

    setTimeout(
      startYouTubeChat,
      10000
    );
  }
}

/* =========================================================
   CHAT STREAM
========================================================= */

async function startChatStream(
  youtube,
  liveChatId
) {

  try {

    chatStream =
      await youtube.liveChatMessages.streamList({
        liveChatId,
        part: "id,snippet,authorDetails"
      });

    chatStream.on("data", response => {

      const messages =
        response.data.items || [];

      for (const message of messages) {

        const author =
          cleanName(
            message.authorDetails?.displayName ||
            "Viewer"
          );

        const text =
          (
            message.snippet?.displayMessage ||
            ""
          ).trim();

        if (!text) continue;

        console.log(
          `[CHAT] ${author}: ${text}`
        );

        const command =
          text.toLowerCase();

        /* JOIN */

        if (
          command === "join" ||
          command === "!join" ||
          command.includes("join")
        ) {

          addViewerToQueue(author);

          continue;
        }

        /* Simple Luna response */

        if (
          command.includes("luna") ||
          command.includes("love") ||
          command.includes("hello") ||
          command.includes("hi")
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

    });

    chatStream.on("error", error => {

      console.log(
        "YouTube chat stream error:",
        error.message
      );

      chatStarted = false;

      setTimeout(
        startYouTubeChat,
        10000
      );

    });

    chatStream.on("end", () => {

      console.log(
        "YouTube chat stream ended."
      );

      chatStarted = false;

      setTimeout(
        startYouTubeChat,
        5000
      );

    });

  } catch (error) {

    console.log(
      "Chat stream failed:",
      error.response?.data || error.message
    );

    chatStarted = false;

  }
}

/* =========================================================
   PREPARE NEXT RACE
========================================================= */

function prepareNextPlayers() {

  if (!waitingPlayers.length) {
    return;
  }

  const available =
    MAX_PLAYERS - players.length;

  if (available <= 0) {
    return;
  }

  const newcomers =
    waitingPlayers.splice(
      0,
      available
    );

  players.push(...newcomers);

  io.emit("playerUpdate", {
    players
  });

  io.emit("queueUpdate", {
    waiting:
      waitingPlayers.map(p => p.name)
  });

  console.log(
    "Players:",
    players.map(p => p.name).join(", ")
  );
}

/* =========================================================
   RACE
========================================================= */

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

      prepareNextPlayers();

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
