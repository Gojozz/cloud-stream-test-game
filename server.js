const express = require("express");
const http = require("http");
const { Server } = require("socket.io");

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
    cors: {
        origin: "*"
    }
});

app.use(express.static("."));

/* =========================
   LUNA AI
========================= */

let model = null;

try {

    const {
        GoogleGenerativeAI
    } = require("@google/generative-ai");

    const key =
        process.env.GEMINI_API_KEY || "";

    if (key) {

        const genAI =
            new GoogleGenerativeAI(key);

        model =
            genAI.getGenerativeModel({
                model: "gemini-1.5-flash"
            });

        console.log("LUNA AI ONLINE");

    } else {

        console.log(
            "GEMINI_API_KEY not found - fallback mode"
        );
    }

} catch (error) {

    console.log(
        "Gemini unavailable:",
        error.message
    );
}

/* =========================
   PLAYERS
========================= */

const defaultPlayers = [
    { name: "Rizal", color: "#ff1744" },
    { name: "Budi", color: "#00e5ff" },
    { name: "Siti", color: "#ffd166" },
    { name: "Agus", color: "#2ecc71" },
    { name: "Dewi", color: "#b86bff" }
];

let players = [...defaultPlayers];

let round = 0;

/* =========================
   COMMENTS
========================= */

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
        Math.floor(
            Math.random() *
            fallbackComments.length
        )
    ];
}

async function lunaComment(event) {

    if (!model)
        return fallbackComment();

    try {

        const prompt = `
You are Luna, an energetic live sports commentator.

Event:
${event}

Rules:
ONE sentence only.
Maximum 14 words.
Exciting.
Family friendly.
Natural English.
Do not mention AI.
Do not use hashtags.
`;

        const result =
            await model.generateContent(prompt);

        const text =
            result.response.text().trim();

        if (text)
            return text;

    } catch (error) {

        console.log(
            "Luna error:",
            error.message
        );
    }

    return fallbackComment();
}

/* =========================
   HELPERS
========================= */

function sleep(ms) {

    return new Promise(
        resolve => setTimeout(resolve, ms)
    );
}

/* =========================
   RACE
========================= */

async function runRace() {

    round++;

    console.log(
        `Starting race ${round}`
    );

    const startText =
        await lunaComment(
            `Round ${round} is starting. Five players are ready.`
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

    let running = true;

    while (running) {

        for (
            let i = 0;
            i < players.length;
            i++
        ) {

            if (
                finished.includes(i)
            ) continue;

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

                const text =
                    await lunaComment(
                        `${player.name} just finished in position ${finished.length}.`
                    );

                io.emit("aiResponse", {
                    speechText: text,
                    playerName: player.name,
                    playerIndex: i
                });

                io.emit("raceWinner", {
                    playerName: player.name,
                    position: finished.length
                });
            }
        }

        io.emit("raceUpdate", {
            positions
        });

        if (
            finished.length >=
            players.length
        ) {
            running = false;
        }

        await sleep(250);
    }

    const winner =
        players[finished[0]];

    const finalText =
        await lunaComment(
            `${winner.name} won round ${round}. Celebrate and invite viewers to join the next race.`
        );

    io.emit("aiResponse", {
        speechText: finalText,
        playerName: winner.name
    });

    console.log(
        `Winner: ${winner.name}`
    );

    await sleep(6000);

    runRace();
}

/* =========================
   SOCKET
========================= */

io.on("connection", socket => {

    console.log(
        "Display connected:",
        socket.id
    );

    socket.emit("playerUpdate", {
        players
    });

    socket.emit("aiResponse", {
        speechText:
            "Welcome to Marble Race Live! Type your name in chat for a chance to race!"
    });
});

/* =========================
   SERVER
========================= */

server.listen(3000, () => {

    console.log("==============================");
    console.log("MARBLE RACE SERVER");
    console.log("PORT: 3000");
    console.log(
        "LUNA:",
        model ? "ONLINE" : "FALLBACK"
    );
    console.log("==============================");

    runRace();
});
