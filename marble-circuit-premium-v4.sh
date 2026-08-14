#!/data/data/com.termux/files/usr/bin/bash
set -e
cd "$HOME/cloud-stream-test"

cp index.html index.backup-before-circuit-v4.html
cp game.js game.js.backup-before-circuit-v4
cp style.css style.css.backup-before-circuit-v4

python - <<'PY'
from pathlib import Path
import re

p = Path("index.html")
s = p.read_text()

new_track = r"""
<section class="track" id="track">
  <div class="race-hud">
    <div class="hud-live">● LIVE</div>
    <div class="hud-title">CAR RACE</div>
    <div class="hud-subtitle">2D LIVE • MARBLE RACE</div>
  </div>
  <div class="race-layout">
    <aside class="race-panel leaderboard-panel">
      <div class="panel-title">RANKING</div>
      <div class="rank-row"><b>1</b><span class="rank-dot r1"></span><span id="rank1">RIZ</span></div>
      <div class="rank-row"><b>2</b><span class="rank-dot r2"></span><span id="rank2">BUD</span></div>
      <div class="rank-row"><b>3</b><span class="rank-dot r3"></span><span id="rank3">SIT</span></div>
      <div class="rank-row"><b>4</b><span class="rank-dot r4"></span><span id="rank4">AGU</span></div>
      <div class="rank-row"><b>5</b><span class="rank-dot r5"></span><span id="rank5">DEW</span></div>
    </aside>

    <div class="circuit-stage">
      <svg class="circuit-svg" viewBox="0 0 720 1120" preserveAspectRatio="xMidYMid meet">
        <defs>
          <filter id="roadShadow"><feGaussianBlur stdDeviation="12"/></filter>
          <linearGradient id="grassGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stop-color="#1f7c45"/>
            <stop offset="1" stop-color="#0b3d25"/>
          </linearGradient>
        </defs>
        <rect width="720" height="1120" fill="url(#grassGrad)"/>
        <g class="decor">
          <circle cx="70" cy="170" r="30"/><circle cx="640" cy="235" r="34"/>
          <circle cx="100" cy="550" r="35"/><circle cx="615" cy="720" r="30"/>
          <circle cx="90" cy="930" r="36"/><circle cx="625" cy="980" r="28"/>
          <circle cx="355" cy="205" r="22"/><circle cx="355" cy="780" r="28"/>
        </g>
        <path class="road-shadow" d="M365 1040 C175 1010 150 900 300 835 C470 760 590 700 530 590 C470 480 180 555 170 420 C160 285 300 220 500 255 C650 280 655 150 500 90"/>
        <path class="road-outer" d="M365 1040 C175 1010 150 900 300 835 C470 760 590 700 530 590 C470 480 180 555 170 420 C160 285 300 220 500 255 C650 280 655 150 500 90"/>
        <path class="road-inner" d="M365 1040 C175 1010 150 900 300 835 C470 760 590 700 530 590 C470 480 180 555 170 420 C160 285 300 220 500 255 C650 280 655 150 500 90"/>
        <path id="racePath" class="race-path" d="M365 1040 C175 1010 150 900 300 835 C470 760 590 700 530 590 C470 480 180 555 170 420 C160 285 300 220 500 255 C650 280 655 150 500 90"/>
        <path class="curb-path" d="M365 1040 C175 1010 150 900 300 835 C470 760 590 700 530 590 C470 480 180 555 170 420 C160 285 300 220 500 255 C650 280 655 150 500 90"/>
        <g class="stands">
          <rect x="18" y="285" width="105" height="95" rx="12"/>
          <rect x="500" y="700" width="190" height="105" rx="12"/>
          <rect x="20" y="875" width="120" height="100" rx="12"/>
        </g>
        <g class="finish-gate">
          <rect x="265" y="1005" width="200" height="28" rx="4"/>
          <text x="365" y="1026" text-anchor="middle">FINISH</text>
        </g>
        <g class="start-gate">
          <rect x="465" y="65" width="105" height="25" rx="5"/>
          <text x="517" y="84" text-anchor="middle">START</text>
        </g>
      </svg>

      <div class="car" id="m1"><span>RIZ</span><i></i></div>
      <div class="car" id="m2"><span>BUD</span><i></i></div>
      <div class="car" id="m3"><span>SIT</span><i></i></div>
      <div class="car" id="m4"><span>AGU</span><i></i></div>
      <div class="car" id="m5"><span>DEW</span><i></i></div>
      <div class="countdown"><span id="countdownText"></span></div>
      <div class="winner" id="winner">
        <div class="winner-small">🏆 WINNER</div>
        <div class="winner-name" id="winnerName">---</div>
      </div>
    </div>

    <aside class="race-panel times-panel">
      <div class="panel-title">LAP TIMES</div>
      <div class="time-row"><b>1</b><span id="time1">RIZAL</span><strong>--:--</strong></div>
      <div class="time-row"><b>2</b><span id="time2">BUDI</span><strong>--:--</strong></div>
      <div class="time-row"><b>3</b><span id="time3">SITI</span><strong>--:--</strong></div>
      <div class="time-row"><b>4</b><span id="time4">AGUS</span><strong>--:--</strong></div>
      <div class="time-row"><b>5</b><span id="time5">DEWI</span><strong>--:--</strong></div>
    </aside>
  </div>
</section>
"""

s = re.sub(r'<section class="track" id="track">.*?</section>', new_track, s, count=1, flags=re.S)
p.write_text(s)

p = Path("game.js")
s = p.read_text()
start = s.index("function resetMarbles()")
end = s.index("\nfunction showCountdown", start)

replacement = r"""let circuitPath = null;
let circuitLength = 1;
const circuitFinish = 690;

function initCircuit() {
    circuitPath = document.getElementById("racePath");
    if (circuitPath) circuitLength = circuitPath.getTotalLength() || 1;
}

function resetMarbles() {
    if (!circuitPath) initCircuit();
    updateCircuitPositions(marbles.map(() => 35));
}

function updateCircuitPositions(positions) {
    if (!circuitPath) initCircuit();
    if (!circuitPath || !positions) return;

    positions.forEach((position, index) => {
        const car = marbles[index];
        if (!car) return;

        const progress = Math.max(0, Math.min(1, position / circuitFinish));
        const point = circuitPath.getPointAtLength(progress * circuitLength);
        const p2 = circuitPath.getPointAtLength(
            Math.min(circuitLength, progress * circuitLength + 3)
        );
        const angle = Math.atan2(p2.y - point.y, p2.x - point.x) * 180 / Math.PI;

        car.style.left = point.x + "px";
        car.style.top = point.y + "px";
        car.style.setProperty("--car-rotate", angle.toFixed(1) + "deg");
    });
}

window.addEventListener("resize", () => {
    if (circuitPath) updateCircuitPositions(marbles.map(() => 35));
});
"""

s = s[:start] + replacement + s[end:]

old = """socket.on("raceUpdate", data => {

    if (!data.positions) return;

    updateRaceCamera(data.positions);
});"""
new = """socket.on("raceUpdate", data => {
    if (!data.positions) return;
    updateCircuitPositions(data.positions);
});"""
s = s.replace(old, new)

if 'socket.on("playerUpdate"' not in s:
    insert_at = s.find('socket.on("aiResponse"')
    block = """socket.on("playerUpdate", data => {
    if (!data.players) return;

    data.players.forEach((player, i) => {
        if (!marbles[i]) return;
        const shortName = (player.name || "PLAYER").substring(0, 8).toUpperCase();
        const label = marbles[i].querySelector("span");
        if (label) label.innerText = shortName;

        const rank = document.getElementById("rank" + (i + 1));
        if (rank) rank.innerText = shortName;

        const time = document.getElementById("time" + (i + 1));
        if (time) time.innerText = shortName;
    });
});

"""
    s = s[:insert_at] + block + s[insert_at:]

s += '\nwindow.addEventListener("load", () => { initCircuit(); resetMarbles(); });\n'
p.write_text(s)

p = Path("style.css")
s = p.read_text()
s += r"""
/* PREMIUM CAR CIRCUIT V4 */
.track{position:relative;overflow:hidden;background:#06130c;border:2px solid rgba(255,255,255,.1);border-radius:24px;box-shadow:0 20px 70px rgba(0,0,0,.55),inset 0 0 90px rgba(0,0,0,.5)}
.track::after{content:"";position:absolute;inset:0;pointer-events:none;background:radial-gradient(circle at 50% 45%,transparent 45%,rgba(0,0,0,.48));z-index:2}
.race-hud{position:absolute;top:12px;left:50%;transform:translateX(-50%);z-index:20;text-align:center;pointer-events:none}
.hud-live{display:inline-block;background:#e51b2a;color:#fff;border-radius:999px;padding:5px 13px;font-size:11px;font-weight:1000;letter-spacing:1px;box-shadow:0 0 18px rgba(229,27,42,.65)}
.hud-title{margin-top:3px;color:#fff;font-size:34px;line-height:.95;font-weight:1000;letter-spacing:-1px;text-shadow:0 4px 0 #10151c,0 0 18px rgba(255,255,255,.25)}
.hud-subtitle{font-size:9px;font-weight:900;color:#54e4ff;letter-spacing:2px}
.race-layout{position:absolute;inset:0;z-index:10;display:block}
.circuit-stage{position:absolute;left:16%;right:16%;top:92px;bottom:16px}
.circuit-svg{position:absolute;inset:0;width:100%;height:100%;display:block}
.road-shadow{fill:none;stroke:#000;stroke-width:124;opacity:.48;filter:url(#roadShadow)}
.road-outer{fill:none;stroke:#c8c8c8;stroke-width:116}
.road-inner{fill:none;stroke:#272b2f;stroke-width:104}
.race-path{fill:none;stroke:#73777a;stroke-width:2.2;stroke-dasharray:18 17;opacity:.72}
.curb-path{fill:none;stroke:#fff;stroke-width:116;stroke-dasharray:18 18;stroke-linecap:butt;opacity:.95}
.stands rect{fill:#151d25;stroke:#71808c;stroke-width:2;opacity:.9}
.finish-gate rect,.start-gate rect{fill:#090d12;stroke:#fff;stroke-width:2}
.finish-gate text,.start-gate text{fill:#fff;font:900 18px Arial;letter-spacing:3px}
.car{position:absolute;width:42px;height:66px;z-index:30;transform:translate(-50%,-50%) rotate(var(--car-rotate,0deg));border-radius:15px 15px 11px 11px;border:2px solid rgba(255,255,255,.9);box-shadow:0 8px 15px rgba(0,0,0,.65),inset 0 5px 7px rgba(255,255,255,.45),inset 0 -8px 10px rgba(0,0,0,.45);display:flex;justify-content:center;align-items:flex-end;padding-bottom:7px;color:#fff;font:1000 8px Arial;letter-spacing:.6px;text-shadow:0 2px 3px #000;will-change:left,top,transform}
.car::before{content:"";position:absolute;left:7px;right:7px;top:7px;height:23px;border-radius:9px 9px 6px 6px;background:linear-gradient(90deg,#101820,#9caeba,#17222c);border:1px solid rgba(255,255,255,.35)}
.car::after{content:"";position:absolute;left:-5px;right:-5px;bottom:8px;height:8px;background:linear-gradient(90deg,#111 0 19%,transparent 19% 81%,#111 81%)}
.car i{position:absolute;left:11px;right:11px;bottom:20px;height:3px;background:rgba(255,255,255,.65);border-radius:9px}
#m1{background:linear-gradient(#ff606b,#b9081a)}#m2{background:linear-gradient(#55eaff,#007fae)}#m3{background:linear-gradient(#a5ef48,#2e9f16)}#m4{background:linear-gradient(#ffe95b,#d49300)}#m5{background:linear-gradient(#ff7adf,#9b1987)}
.race-panel{position:absolute;top:92px;width:145px;padding:10px;border-radius:15px;background:rgba(5,10,15,.91);border:1px solid rgba(255,255,255,.18);box-shadow:0 14px 35px rgba(0,0,0,.5);backdrop-filter:blur(8px)}
.leaderboard-panel{left:10px}.times-panel{right:10px}
.panel-title{color:#ffd84b;font-size:12px;font-weight:1000;letter-spacing:1px;margin-bottom:7px}
.rank-row,.time-row{display:grid;grid-template-columns:20px 1fr auto;align-items:center;gap:5px;min-height:29px;border-bottom:1px solid rgba(255,255,255,.07);color:#fff;font-size:9px;font-weight:900}
.rank-row b{font-size:12px}.rank-dot{width:12px;height:12px;border-radius:50%;border:1px solid #fff}.r1{background:#e52235}.r2{background:#0eb9e7}.r3{background:#66d52d}.r4{background:#f1b522}.r5{background:#e747c8}
.time-row{grid-template-columns:15px 1fr auto;font-size:8px}.time-row strong{color:#ffd84b}
@media(max-width:700px){.circuit-stage{left:2%;right:2%;top:85px}.race-panel{width:104px;padding:7px}.leaderboard-panel{left:5px}.times-panel{right:5px}.hud-title{font-size:27px}.hud-subtitle{font-size:7px}.car{width:34px;height:53px;font-size:6px}}
"""
p.write_text(s)
PY

node --check game.js
node --check server.js
echo "PREMIUM CAR CIRCUIT V4 APPLIED"
git diff --stat
