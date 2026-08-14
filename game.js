const socket = io();

const UI_LANGUAGE = (navigator.language || "en-US").toLowerCase();

const UI_TEXT = {
    en: {
        prompt: "🏁 WANT TO RACE? TYPE IN CHAT!",
        next: "NEXT RACERS",
        waiting: "Waiting for racers..."
    },
    id: {
        prompt: "🏁 MAU IKUT BALAP? KETIK DI CHAT!",
        next: "PEMAIN BERIKUTNYA",
        waiting: "Menunggu pemain..."
    }
};

const langKey = Object.keys(UI_TEXT).find(
    key => UI_LANGUAGE === key || UI_LANGUAGE.startsWith(key + "-")
) || "en";

const ui = UI_TEXT[langKey];

function applyUILanguage() {
    const title = document.getElementById("nextRacersTitle");
    const list = document.getElementById("joinersList");
    if (title) title.innerText = ui.next;
    if (list && (!list.innerText.trim() || list.innerText.includes("Waiting") || list.innerText.includes("Menunggu"))) {
        list.innerText = ui.waiting;
    }
}
applyUILanguage();

const track = document.getElementById("track");
const speech = document.getElementById("aiSpeech");
const winner = document.getElementById("winner");
const winnerName = document.getElementById("winnerName");
const roundLabel = document.getElementById("round");
const countdownText = document.getElementById("countdownText");

const cars = [
    document.getElementById("m1"),
    document.getElementById("m2"),
    document.getElementById("m3"),
    document.getElementById("m4"),
    document.getElementById("m5")
];

// Waypoints (normalized 0-1) based on the new track layout
// Adjusted for the clean single-loop track
const WAYPOINTS = [
    { x: 0.50, y: 0.78 }, // Start / Finish
    { x: 0.38, y: 0.82 },
    { x: 0.22, y: 0.75 },
    { x: 0.15, y: 0.58 },
    { x: 0.18, y: 0.38 },
    { x: 0.28, y: 0.22 },
    { x: 0.45, y: 0.15 },
    { x: 0.62, y: 0.18 },
    { x: 0.78, y: 0.28 },
    { x: 0.85, y: 0.45 },
    { x: 0.82, y: 0.62 },
    { x: 0.70, y: 0.75 },
    { x: 0.58, y: 0.80 }
];

function getTrackSize() {
    return {
        width: track.clientWidth,
        height: track.clientHeight
    };
}

function placeCar(car, progress) {
    // progress: 0 → 1 (around the track)
    const total = WAYPOINTS.length;
    const idx = progress * total;
    const i = Math.floor(idx) % total;
    const t = idx - Math.floor(idx);

    const a = WAYPOINTS[i];
    const b = WAYPOINTS[(i + 1) % total];

    const x = a.x + (b.x - a.x) * t;
    const y = a.y + (b.y - a.y) * t;

    const size = getTrackSize();
    const px = x * size.width - 26;
    const py = y * size.height - 14;

    // Calculate rotation
    const dx = b.x - a.x;
    const dy = b.y - a.y;
    const angle = Math.atan2(dy, dx) * (180 / Math.PI);

    car.style.left = px + "px";
    car.style.top = py + "px";
    car.style.transform = `rotate(${angle}deg)`;
}

function resetCars() {
    cars.forEach((car, i) => {
        placeCar(car, 0.02 * i); // slight offset so they don't overlap at start
    });
}

function showCountdown(number) {
    countdownText.innerText = number || "";
    if (!number) return;
    countdownText.style.opacity = "1";
    setTimeout(() => {
        countdownText.style.opacity = "0";
    }, 700);
}

socket.on("connect", () => {
    speech.innerText = "Luna is online! Type JOIN in the live chat to race!";
});

socket.on("raceStart", data => {
    winner.classList.remove("show");
    roundLabel.innerText = data.round || 1;
    if (data.message) speech.innerText = data.message;
    resetCars();
    showCountdown("GO!");
});

socket.on("raceUpdate", data => {
    if (!data.progress) return;

    data.progress.forEach((p, index) => {
        if (cars[index]) {
            placeCar(cars[index], p);
        }
    });
});

socket.on("aiResponse", data => {
    if (data.speechText) {
        speech.innerText = data.speechText;
    }
    if (data.playerName && typeof data.playerIndex === "number" && cars[data.playerIndex]) {
        cars[data.playerIndex].innerText = data.playerName.substring(0, 7).toUpperCase();
    }
});

socket.on("raceWinner", data => {
    if (!data.playerName) return;
    winnerName.innerText = data.playerName;
    winner.classList.add("show");
});

socket.on("queueUpdate", data => {
    const list = document.getElementById("joinersList");
    if (!list) return;

    const waiting = Array.isArray(data.waiting) ? data.waiting : [];
    if (!waiting.length) {
        list.innerText = ui.waiting;
        return;
    }

    list.innerHTML = waiting
        .slice(0, 8)
        .map(name => `<span class="joiner">👤 ${escapeHtml(name)}</span>`)
        .join("");
});

function escapeHtml(value) {
    return String(value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

socket.on("playerUpdate", data => {
    if (!data.players) return;

    data.players.forEach((player, index) => {
        const element = document.querySelector(`#p${index + 1} .player-name`);
        if (element) element.innerText = player.name;

        if (cars[index]) {
            cars[index].innerText = player.name.substring(0, 7).toUpperCase();
        }
    });
});

window.addEventListener("resize", resetCars);
resetCars();
