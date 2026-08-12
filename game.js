const socket = io();

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
