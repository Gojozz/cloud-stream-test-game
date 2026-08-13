const socket = io();

const UI_LANGUAGE = (
    navigator.language ||
    "en-US"
).toLowerCase();

const UI_TEXT = {
    en: {
        prompt: "🏁 WANT TO RACE? TYPE IN CHAT!",
        next: "👥 NEXT RACERS",
        waiting: "Waiting for racers..."
    },
    id: {
        prompt: "🏁 MAU IKUT BALAP? KETIK DI CHAT!",
        next: "👥 PEMAIN BERIKUTNYA",
        waiting: "Menunggu pemain..."
    },
    es: {
        prompt: "🏁 ¿QUIERES COMPETIR? ¡ESCRIBE EN EL CHAT!",
        next: "👥 PRÓXIMOS CORREDORES",
        waiting: "Esperando corredores..."
    },
    pt: {
        prompt: "🏁 QUER CORRER? ESCREVA NO CHAT!",
        next: "👥 PRÓXIMOS CORREDORES",
        waiting: "Aguardando corredores..."
    },
    fr: {
        prompt: "🏁 ENVIE DE COURIR ? ÉCRIVEZ DANS LE CHAT !",
        next: "👥 PROCHAINS COUREURS",
        waiting: "En attente de coureurs..."
    },
    de: {
        prompt: "🏁 DU WILLST MITMACHEN? SCHREIB IN DEN CHAT!",
        next: "👥 NÄCHSTE RENNER",
        waiting: "Warten auf Rennfahrer..."
    },
    th: {
        prompt: "🏁 อยากแข่งไหม? พิมพ์ในแชท!",
        next: "👥 ผู้เข้าแข่งขันถัดไป",
        waiting: "กำลังรอผู้เล่น..."
    },
    zh: {
        prompt: "🏁 想参加比赛？在聊天中输入！",
        next: "👥 下一批选手",
        waiting: "等待选手..."
    },
    ja: {
        prompt: "🏁 レースに参加？チャットに入力！",
        next: "👥 次のレーサー",
        waiting: "レーサーを待っています..."
    },
    ko: {
        prompt: "🏁 레이스에 참가하려면 채팅에 입력하세요!",
        next: "👥 다음 레이서",
        waiting: "선수를 기다리는 중..."
    },
    ar: {
        prompt: "🏁 تريد المشاركة؟ اكتب في الدردشة!",
        next: "👥 المتسابقون القادمون",
        waiting: "في انتظار المتسابقين..."
    },
    ru: {
        prompt: "🏁 ХОЧЕШЬ УЧАСТВОВАТЬ? НАПИШИ В ЧАТ!",
        next: "👥 СЛЕДУЮЩИЕ ГОНЩИКИ",
        waiting: "Ждём участников..."
    },
    vi: {
        prompt: "🏁 MUỐN ĐUA? HÃY NHẮN TRONG CHAT!",
        next: "👥 NGƯỜI ĐUA TIẾP THEO",
        waiting: "Đang chờ người chơi..."
    },
    ms: {
        prompt: "🏁 NAK BERLUMBA? TAIP DALAM CHAT!",
        next: "👥 PEMAIN SETERUSNYA",
        waiting: "Menunggu pemain..."
    },
    fil: {
        prompt: "🏁 GUSTO MONG SUMALI? MAG-TYPE SA CHAT!",
        next: "👥 SUSUNOD NA RACERS",
        waiting: "Naghihintay ng racers..."
    }
};

const langKey =
    Object.keys(UI_TEXT).find(
        key => UI_LANGUAGE === key || UI_LANGUAGE.startsWith(key + "-")
    ) || "en";

const ui = UI_TEXT[langKey];

function applyUILanguage() {
    const prompt = document.getElementById("joinPrompt");
    const title = document.getElementById("nextRacersTitle");
    const list = document.getElementById("joinersList");

    if (prompt) prompt.innerText = ui.prompt;
    if (title) title.innerText = ui.next;

    if (
        list &&
        (!list.innerText.trim() ||
         list.innerText.trim() === "Waiting for racers..." ||
         list.innerText.trim() === "Waiting for JOIN...")
    ) {
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

const marbles = [
    document.getElementById("m1"),
    document.getElementById("m2"),
    document.getElementById("m3"),
    document.getElementById("m4"),
    document.getElementById("m5")
];

function resetMarbles() {

    const width = track.clientWidth;
    const laneWidth = width / marbles.length;

    marbles.forEach((marble, i) => {

        marble.style.left =
            (laneWidth * i + laneWidth / 2 - 29) + "px";

        marble.style.top = "35px";
    });
}

function showCountdown(number) {

    countdownText.innerText = number;

    if (!number) {
        countdownText.innerText = "";
        return;
    }

    countdownText.style.opacity = "1";

    setTimeout(() => {
        countdownText.style.opacity = "0";
    }, 600);
}

socket.on("connect", () => {

    speech.innerText =
        "Luna is online! Type your name in the live chat for a chance to race!";
});

socket.on("raceStart", data => {

    winner.classList.remove("show");

    roundLabel.innerText =
        data.round || 1;

    if (data.message) {
        speech.innerText = data.message;
    }

    resetMarbles();

    showCountdown("GO!");
});

socket.on("raceUpdate", data => {

    if (!data.positions) return;

    data.positions.forEach((position, index) => {

        if (!marbles[index]) return;

        marbles[index].style.top =
            position + "px";
    });
});

socket.on("aiResponse", data => {

    if (data.speechText) {
        speech.innerText =
            data.speechText;
    }

    if (data.playerName) {

        const index =
            data.playerIndex;

        if (
            typeof index === "number" &&
            marbles[index]
        ) {
            marbles[index].innerText =
                data.playerName
                    .substring(0, 7)
                    .toUpperCase();
        }
    }
});

socket.on("raceWinner", data => {

    if (!data.playerName) return;

    winnerName.innerText =
        data.playerName;

    winner.classList.add("show");
});

socket.on("queueUpdate", data => {
    const list = document.getElementById("joinersList");

    if (!list) return;

    const waiting = Array.isArray(data.waiting)
        ? data.waiting
        : [];

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

        const element =
            document.querySelector(
                `#p${index + 1} .player-name`
            );

        if (element) {
            element.innerText =
                player.name;
        }

        if (marbles[index]) {

            marbles[index].innerText =
                player.name
                    .substring(0, 7)
                    .toUpperCase();
        }
    });
});

window.addEventListener("resize", resetMarbles);

resetMarbles();
