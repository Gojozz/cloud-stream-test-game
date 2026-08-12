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

let model = null;

try {

    const { GoogleGenerativeAI } =
        require("@google/generative-ai");

    const apiKey =
        process.env.GEMINI_API_KEY || "";

    if (apiKey) {

        const genAI =
            new GoogleGenerativeAI(apiKey);

        model =
            genAI.getGenerativeModel({
                model: "gemini-1.5-flash"
            });

        console.log("================================");
        console.log("LUNA AI: GEMINI INITIALIZED");
        console.log("================================");

    } else {

        console.log("LUNA AI: GEMINI_API_KEY NOT FOUND");

    }

} catch (error) {

    console.log(
        "Gemini SDK unavailable:",
        error.message
    );

}

const players = [
    {
        name: "Rizal",
        color: "#ff1744"
    },
    {
        name: "Budi",
        color: "#00e5ff"
    },
    {
        name: "Siti",
        color: "#ffd166"
    },
    {
        name: "Agus",
        color: "#2ecc71"
    },
    {
        name: "Dewi",
        color: "#b86bff"
    }
];

let round = 0;

function randomComment() {

    const comments = [
        "The marbles are flying! This race is getting wild!",
        "What a battle! Nobody is giving up!",
        "Look at that speed! This could go either way!",
        "The finish line is getting closer!",
        "This race is absolutely insane!",
        "Someone is about to make a huge comeback!"
    ];

    return comments[
        Math.floor(Math.random() * comments.length)
    ];
}

async function lunaComment(event) {

    if (!model) {

        console.log(
            "LUNA AI: using fallback commentary"
        );

        return randomComment();
    }

    try {

        const prompt = `
You are Luna, an energetic AI host for a global YouTube LIVE Marble Race.

Event:
${event}

Rules:
- Write exactly ONE short sentence.
- Maximum 16 words.
- Exciting, natural, family-friendly.
- Speak like a live sports commentator.
- Do not mention AI.
- Do not use hashtags.
- Do not explain anything.
`;

        const result =
            await model.generateContent(prompt);

        const text =
            result.response
                .text()
                .trim();

        if (text) {

            console.log(
                "LUNA AI:",
                text
            );

            return text;
        }

    } catch (error) {

        console.error(
            "LUNA GEMINI ERROR:",
            error.message
        );
    }

    return randomComment();
}

function sleep(ms) {
    return new Promise(
        resolve => setTimeout(resolve, ms)
    );
}

async function runRace() {

    round++;

    console.log(
        `Starting Marble Race #${round}`
    );

    const startComment =
        await lunaComment(
            `Round ${round} is about to begin. Five marbles are waiting at the starting line.`
        );

    io.emit("raceStart", {
        round,
        message: startComment
    });

    await sleep(4000);

    const positions =
        players.map(() => 0);

    const finished = [];

    let raceRunning = true;

    while (raceRunning) {

        for (
            let i = 0;
            i < players.length;
            i++
        ) {

            if (finished.includes(i))
                continue;

            const boost =
                8 + Math.random() * 18;

            positions[i] += boost;

            if (positions[i] >= 690) {

                positions[i] = 690;

                finished.push(i);

                const player =
                    players[i];

                const comment =
                    await lunaComment(
                        `${player.name}'s marble just reached the finish line in position ${finished.length}.`
                    );

                io.emit("aiResponse", {
                    speechText: comment,
                    playerName: player.name
                });

                io.emit("raceWinner", {
                    playerName: player.name,
                    position: finished.length
                });

                if (finished.length === 1) {

                    console.log(
                        `Winner Round ${round}: ${player.name}`
                    );
                }
            }
        }

        io.emit("raceUpdate", {
            positions
        });

        if (
            finished.length >=
            players.length
        ) {

            raceRunning = false;
        }

        await sleep(350);
    }

    const winner =
        players[finished[0]];

    const finalComment =
        await lunaComment(
            `${winner.name} won Marble Race round ${round}. Celebrate the winner and tease the next race.`
        );

    io.emit("aiResponse", {
        speechText: finalComment,
        playerName: winner.name
    });

    console.log(
        `Race #${round} finished.`
    );

    await sleep(7000);

    runRace();
}

io.on("connection", socket => {

    console.log(
        "Marble display connected:",
        socket.id
    );

    socket.emit("aiResponse", {
        speechText:
            "Welcome to Marble Race Live! Get ready for the next battle!"
    });
});

server.listen(3000, () => {

    console.log(
        "================================"
    );

    console.log(
        "MARBLE GAME SERVER RUNNING"
    );

    console.log(
        "PORT: 3000"
    );

    console.log(
        "GEMINI:",
        model ? "ONLINE" : "OFFLINE"
    );

    console.log(
        "================================"
    );

    runRace();
});
