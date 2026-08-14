from pathlib import Path
import zipfile
script = r"""#!/data/data/com.termux/files/usr/bin/bash
set -e
cd "$HOME/cloud-stream-test"
TS=$(date +%Y%m%d-%H%M%S)
cp index.html "index.backup-before-v5-$TS.html"
cp game.js "game.js.backup-before-v5-$TS"
cp style.css "style.css.backup-before-v5-$TS"

python - <<'PY'
from pathlib import Path
import re

p=Path("index.html"); s=p.read_text()
track=r"""
<section class="track pro-race" id="track">
<div class="race-skyline"></div>
<div class="race-topbar"><div class="live-pill"><span></span> LIVE</div><div class="race-brand"><strong>CAR<span>RACE</span></strong><small>2D LIVE • JOIN THE RACE</small></div><div class="viewer-pill">👥 <b id="viewerCount">LIVE</b></div></div>
<aside class="pro-board board-left"><div class="board-head"><span>POS</span><span>DRIVER</span></div>
<div class="driver-row"><b>1</b><i class="car-dot dot-red"></i><strong id="rank1">RIZAL</strong></div><div class="driver-row"><b>2</b><i class="car-dot dot-blue"></i><strong id="rank2">BUDI</strong></div><div class="driver-row"><b>3</b><i class="car-dot dot-green"></i><strong id="rank3">SITI</strong></div><div class="driver-row"><b>4</b><i class="car-dot dot-yellow"></i><strong id="rank4">AGUS</strong></div><div class="driver-row"><b>5</b><i class="car-dot dot-pink"></i><strong id="rank5">DEWI</strong></div></aside>
<aside class="pro-board board-right"><div class="board-title">LAP TIMES</div><div class="lap-row"><b>1</b><span id="time1">RIZAL</span><em>--:--.--</em></div><div class="lap-row"><b>2</b><span id="time2">BUDI</span><em>--:--.--</em></div><div class="lap-row"><b>3</b><span id="time3">SITI</span><em>--:--.--</em></div><div class="lap-row"><b>4</b><span id="time4">AGUS</span><em>--:--.--</em></div><div class="lap-row"><b>5</b><span id="time5">DEWI</span><em>--:--.--</em></div></aside>
<div class="circuit-wrap"><div class="track-glow"></div>
<svg class="pro-circuit" viewBox="0 0 720 1120" preserveAspectRatio="xMidYMid meet">
<defs><linearGradient id="grass" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#23864a"/><stop offset=".5" stop-color="#176338"/><stop offset="1" stop-color="#0c3b27"/></linearGradient><linearGradient id="asphalt" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#3c4147"/><stop offset=".5" stop-color="#24292f"/><stop offset="1" stop-color="#171b20"/></linearGradient><pattern id="gridGrass" width="34" height="34" patternUnits="userSpaceOnUse"><path d="M34 0H0V34" fill="none" stroke="#fff" stroke-opacity=".035"/></pattern><filter id="softShadow"><feGaussianBlur stdDeviation="14"/></filter></defs>
<rect width="720" height="1120" fill="url(#grass)"/><rect width="720" height="1120" fill="url(#gridGrass)"/>
<g class="infield"><ellipse cx="360" cy="250" rx="92" ry="58"/><ellipse cx="370" cy="650" rx="105" ry="70"/><ellipse cx="260" cy="900" rx="72" ry="48"/></g>
<g class="trees"><g transform="translate(70 180)"><circle r="24"/><circle cx="18" cy="8" r="17"/><rect x="-3" y="20" width="6" height="18"/></g><g transform="translate(640 235)"><circle r="27"/><circle cx="-18" cy="8" r="17"/><rect x="-3" y="22" width="6" height="18"/></g><g transform="translate(85 610)"><circle r="25"/><circle cx="18" cy="8" r="16"/><rect x="-3" y="21" width="6" height="18"/></g><g transform="translate(625 760)"><circle r="28"/><circle cx="-18" cy="10" r="18"/><rect x="-3" y="23" width="6" height="18"/></g><g transform="translate(80 960)"><circle r="28"/><circle cx="20" cy="8" r="17"/><rect x="-3" y="24" width="6" height="18"/></g><g transform="translate(635 1010)"><circle r="24"/><circle cx="-17" cy="8" r="16"/><rect x="-3" y="21" width="6" height="18"/></g></g>
<path class="road-shadow" d="M360 1050 C170 1020 145 900 300 835 C480 760 590 690 520 575 C455 470 180 555 165 420 C150 285 300 215 505 255 C650 282 660 155 505 85"/>
<path class="road-border" d="M360 1050 C170 1020 145 900 300 835 C480 760 590 690 520 575 C455 470 180 555 165 420 C150 285 300 215 505 255 C650 282 660 155 505 85"/>
<path class="road" d="M360 1050 C170 1020 145 900 300 835 C480 760 590 690 520 575 C455 470 180 555 165 420 C150 285 300 215 505 255 C650 282 660 155 505 85"/>
<path class="lane-center" d="M360 1050 C170 1020 145 900 300 835 C480 760 590 690 520 575 C455 470 180 555 165 420 C150 285 300 215 505 255 C650 282 660 155 505 85"/>
<path class="curb curb-red" d="M360 1050 C170 1020 145 900 300 835 C480 760 590 690 520 575 C455 470 180 555 165 420 C150 285 300 215 505 255 C650 282 660 155 505 85"/>
<path class="curb curb-white" d="M360 1050 C170 1020 145 900 300 835 C480 760 590 690 520 575 C455 470 180 555 165 420 C150 285 300 215 505 255 C650 282 660 155 505 85"/>
<path id="racePath" class="race-path" d="M360 1050 C170 1020 145 900 300 835 C480 760 590 690 520 575 C455 470 180 555 165 420 C150 285 300 215 505 255 C650 282 660 155 505 85"/>
<g class="grandstand"><g transform="translate(20 305)"><rect width="105" height="74" rx="8"/><path d="M8 18h89M8 35h89M8 52h89"/></g><g transform="translate(515 690)"><rect width="175" height="82" rx="8"/><path d="M10 20h155M10 39h155M10 58h155"/></g><g transform="translate(18 870)"><rect width="118" height="82" rx="8"/><path d="M8 20h102M8 40h102M8 60h102"/></g></g>
<g class="billboard"><rect x="560" y="440" width="105" height="30" rx="4"/><text x="612" y="461">SPEED UP!</text></g><g class="billboard"><rect x="42" y="735" width="105" height="30" rx="4"/><text x="94" y="756">GO! GO! GO!</text></g>
<g class="finish-banner"><rect x="245" y="1000" width="230" height="35" rx="4"/><text x="360" y="1025" text-anchor="middle">🏁 FINISH</text></g>
</svg>
<div class="race-car car-red" id="m1"><span>RIZ</span><i></i></div><div class="race-car car-blue" id="m2"><span>BUD</span><i></i></div><div class="race-car car-green" id="m3"><span>SIT</span><i></i></div><div class="race-car car-yellow" id="m4"><span>AGU</span><i></i></div><div class="race-car car-pink" id="m5"><span>DEW</span><i></i></div>
<div class="position-badge badge1">1</div><div class="position-badge badge2">2</div><div class="position-badge badge3">3</div><div class="position-badge badge4">4</div><div class="position-badge badge5">5</div>
<div class="countdown"><span id="countdownText"></span></div><div class="winner pro-winner" id="winner"><div class="winner-small">🏆 RACE WINNER</div><div class="winner-name" id="winnerName">---</div></div>
</div>
<div class="join-banner"><div class="join-icon">👤</div><div><strong>JOIN THE RACE!</strong><span>Type your name in chat to race next.</span></div></div>
<div class="queue-mini"><b>👥 NEXT RACERS</b><span id="joinersList">Waiting for racers...</span></div>
</section>
"""
s2=re.sub(r'<section class="track" id="track">.*?</section>',track,s,count=1,flags=re.S)
if s2==s: raise SystemExit("TRACK_SECTION_NOT_FOUND")
p.write_text(s2)

p=Path("game.js"); s=p.read_text(); start=s.find("function resetMarbles()"); end=s.find("\nfunction showCountdown",start)
if start<0 or end<0: raise SystemExit("GAMEJS_POSITION_BLOCK_NOT_FOUND")
block="""let circuitPath = null;
let circuitLength = 1;
const SERVER_FINISH = 690;

function initCircuit() {
    circuitPath = document.getElementById("racePath");
    if (circuitPath) circuitLength = circuitPath.getTotalLength() || 1;
}
function resetMarbles() {
    if (!circuitPath) initCircuit();
    updateCircuitPositions([35,35,35,35,35]);
}
function updateCircuitPositions(positions) {
    if (!circuitPath || !positions) return;
    positions.forEach((position,index)=>{
        const car=marbles[index]; if(!car) return;
        const progress=Math.max(0,Math.min(1,position/SERVER_FINISH));
        const len=progress*circuitLength;
        const point=circuitPath.getPointAtLength(len);
        const next=circuitPath.getPointAtLength(Math.min(circuitLength,len+2.5));
        const angle=Math.atan2(next.y-point.y,next.x-point.x)*180/Math.PI;
        car.style.left=point.x+"px"; car.style.top=point.y+"px";
        car.style.setProperty("--car-rotate",angle.toFixed(2)+"deg");
        const badge=document.querySelector(".badge"+(index+1));
        if(badge){badge.style.left=point.x+"px";badge.style.top=(point.y-37)+"px";}
    });
}
function refreshDriverLabels(players) {
    if(!players) return;
    players.forEach((player,i)=>{
        if(!marbles[i]) return;
        const name=(player.name||"PLAYER").substring(0,8).toUpperCase();
        const label=marbles[i].querySelector("span"); if(label) label.innerText=name;
        const rank=document.getElementById("rank"+(i+1)); if(rank) rank.innerText=name;
        const time=document.getElementById("time"+(i+1)); if(time) time.innerText=name;
    });
}
"""
s=s[:start]+block+s[end:]
s=re.sub(r'socket\.on\("raceUpdate", data => \{.*?\n\}\);',"""socket.on("raceUpdate", data => {
    if (!data.positions) return;
    updateCircuitPositions(data.positions);
});""",s,count=1,flags=re.S)
if 'socket.on("playerUpdate"' in s:
    s=re.sub(r'socket\.on\("playerUpdate".*?\n\}\);',"""socket.on("playerUpdate", data => {
    refreshDriverLabels(data.players);
});""",s,count=1,flags=re.S)
else:
    idx=s.find('socket.on("aiResponse"')
    if idx>=0: s=s[:idx]+"""socket.on("playerUpdate", data => {
    refreshDriverLabels(data.players);
});

"""+s[idx:]
s+='\\nwindow.addEventListener("load",()=>{initCircuit();resetMarbles();});\\n'
p.write_text(s)

p=Path("style.css"); s=p.read_text()
s+=r"""
/* CAR RACE PRO V5 */
.track.pro-race{position:relative!important;overflow:hidden!important;width:100%!important;min-height:920px;border-radius:28px!important;border:1px solid rgba(255,255,255,.12)!important;background:#07150f!important;box-shadow:0 25px 80px rgba(0,0,0,.62),inset 0 0 80px rgba(0,0,0,.45)!important;isolation:isolate}
.track.pro-race:before{content:"";position:absolute;inset:0;z-index:0;background:radial-gradient(circle at 50% 28%,rgba(33,130,74,.28),transparent 38%),linear-gradient(180deg,#0b2130 0,#07150f 28%,#06110c 100%)}
.race-skyline{position:absolute;inset:0;z-index:0;opacity:.35;background-image:radial-gradient(circle,rgba(255,255,255,.18) 1px,transparent 1px);background-size:28px 28px;mask-image:linear-gradient(#000,transparent 68%)}
.race-topbar{position:absolute;left:14px;right:14px;top:12px;height:74px;z-index:40;display:flex;align-items:center;justify-content:space-between;pointer-events:none}.live-pill{background:linear-gradient(#ff4050,#d90d20);border:2px solid rgba(255,255,255,.18);box-shadow:0 0 25px rgba(255,32,54,.5);padding:6px 12px;border-radius:999px;color:#fff;font:1000 11px Arial;letter-spacing:1px}.live-pill span{display:inline-block;width:7px;height:7px;border-radius:50%;background:#fff;box-shadow:0 0 8px #fff;margin-right:5px}.race-brand{text-align:center}.race-brand strong{display:block;color:#fff;font:1000 39px/34px Arial,sans-serif;letter-spacing:-2px;text-shadow:0 4px 0 #111,0 0 18px rgba(255,255,255,.2)}.race-brand strong span{color:#ffd51e}.race-brand small{display:block;color:#5be5ff;font:1000 8px Arial;letter-spacing:2.2px;margin-top:5px}.viewer-pill{background:rgba(5,9,14,.92);border:1px solid rgba(255,255,255,.2);padding:8px 10px;border-radius:12px;color:#fff;font:900 11px Arial;box-shadow:0 8px 25px rgba(0,0,0,.35)}
.pro-board{position:absolute;z-index:42;top:92px;width:145px;border-radius:15px;background:rgba(5,10,15,.93);border:1px solid rgba(255,255,255,.18);box-shadow:0 15px 40px rgba(0,0,0,.5);backdrop-filter:blur(10px);overflow:hidden}.board-left{left:10px}.board-right{right:10px}.board-head,.board-title{height:28px;padding:8px 9px 0;color:#ffd84a;font:1000 10px Arial;letter-spacing:1px}.board-head{display:grid;grid-template-columns:26px 1fr;color:#aeb8c4}.driver-row{height:36px;display:grid;grid-template-columns:20px 16px 1fr;align-items:center;gap:5px;padding:0 9px;color:#fff;font:900 9px Arial;border-top:1px solid rgba(255,255,255,.06)}.driver-row>b{font-size:13px}.car-dot{width:12px;height:12px;border-radius:50%;border:1px solid #fff;box-shadow:0 0 7px currentColor}.dot-red{background:#f52c42}.dot-blue{background:#19c9ef}.dot-green{background:#62d936}.dot-yellow{background:#ffd33e}.dot-pink{background:#ec4fd2}.lap-row{display:grid;grid-template-columns:14px 1fr auto;gap:4px;align-items:center;height:32px;padding:0 8px;color:#fff;font:800 8px Arial;border-top:1px solid rgba(255,255,255,.06)}.lap-row b{color:#ffd84a}.lap-row em{font-style:normal;color:#8e9aa6;font-size:7px}
.circuit-wrap{position:absolute;z-index:15;left:8%;right:8%;top:82px;bottom:18px;overflow:hidden;border-radius:20px;background:#123d29;box-shadow:0 0 0 1px rgba(255,255,255,.08),0 20px 60px rgba(0,0,0,.55)}.track-glow{position:absolute;inset:0;z-index:1;pointer-events:none;background:radial-gradient(ellipse at 50% 42%,rgba(49,255,143,.13),transparent 54%)}.pro-circuit{position:absolute;inset:0;width:100%;height:100%;z-index:2}.pro-circuit .infield ellipse{fill:#2a7542;stroke:#59a55d;stroke-width:2;opacity:.7}.pro-circuit .trees circle{fill:#2f9b4d;stroke:#83d86e;stroke-width:2}.pro-circuit .trees rect{fill:#6b432b}.road-shadow{fill:none;stroke:#000;stroke-width:132;opacity:.5;filter:url(#softShadow)}.road-border{fill:none;stroke:#d8d8d8;stroke-width:122}.road{fill:none;stroke:url(#asphalt);stroke-width:108}.lane-center{fill:none;stroke:#fff;stroke-opacity:.17;stroke-width:2;stroke-dasharray:18 20}.curb{fill:none;stroke-width:122;stroke-dasharray:18 18;stroke-linecap:butt;opacity:.95}.curb-red{stroke:#df2830}.curb-white{stroke:#fff;stroke-dashoffset:18}.race-path{fill:none;stroke:transparent;stroke-width:2}.grandstand rect{fill:#101822;stroke:#8895a0;stroke-width:2}.grandstand path{stroke:#d0d7dc;stroke-width:2;opacity:.55}.billboard rect{fill:#e72d32;stroke:#fff;stroke-width:2}.billboard text{fill:#fff;font:1000 14px Arial;letter-spacing:1px}.finish-banner rect{fill:#090d12;stroke:#fff;stroke-width:2}.finish-banner text{fill:#fff;font:1000 19px Arial;letter-spacing:2px}
.race-car{position:absolute;z-index:30;width:34px;height:58px;transform:translate(-50%,-50%) rotate(var(--car-rotate,0deg));border-radius:13px 13px 9px 9px;border:2px solid rgba(255,255,255,.92);box-shadow:0 8px 13px rgba(0,0,0,.7),inset 0 5px 7px rgba(255,255,255,.48),inset 0 -9px 10px rgba(0,0,0,.45);transition:left .14s linear,top .14s linear,transform .14s linear;display:flex;align-items:flex-end;justify-content:center;padding-bottom:5px;color:#fff;font:1000 7px Arial;text-shadow:0 2px 3px #000;will-change:left,top}.race-car:before{content:"";position:absolute;left:6px;right:6px;top:6px;height:22px;border-radius:8px 8px 5px 5px;background:linear-gradient(90deg,#0d151b,#bdc9d1,#162027);border:1px solid rgba(255,255,255,.35)}.race-car:after{content:"";position:absolute;left:-5px;right:-5px;bottom:7px;height:8px;background:linear-gradient(90deg,#080b0d 0 18%,transparent 18% 82%,#080b0d 82%);border-radius:3px}.race-car i{position:absolute;left:10px;right:10px;bottom:17px;height:3px;background:rgba(255,255,255,.65);border-radius:5px}.car-red{background:linear-gradient(#ff5a67,#b5071a)}.car-blue{background:linear-gradient(#54e7ff,#0081b0)}.car-green{background:linear-gradient(#9cef55,#26971b)}.car-yellow{background:linear-gradient(#ffe65a,#c98700)}.car-pink{background:linear-gradient(#ff80df,#9c1788)}
.position-badge{position:absolute;z-index:35;width:23px;height:23px;margin:-11px 0 0 -11px;border-radius:50%;display:grid;place-items:center;color:#fff;font:1000 12px Arial;border:2px solid #fff;box-shadow:0 4px 10px rgba(0,0,0,.5);pointer-events:none;transition:left .14s linear,top .14s linear}.badge1{background:#e62a3d}.badge2{background:#159bc8}.badge3{background:#3db52b}.badge4{background:#df9c13}.badge5{background:#d535b9}.countdown{position:absolute;inset:0;z-index:60;display:grid;place-items:center;pointer-events:none}.countdown span{font:1000 70px Arial;color:#fff;text-shadow:0 5px 0 #111,0 0 35px #21e6ff}.pro-winner{position:absolute;z-index:70;left:50%;top:47%;transform:translate(-50%,-50%) scale(.92);min-width:210px;padding:15px 25px;text-align:center;background:rgba(4,8,12,.94);border:2px solid #ffd34a;border-radius:17px;box-shadow:0 0 35px rgba(255,202,40,.25);opacity:0;pointer-events:none;transition:.25s}.pro-winner.show{opacity:1;transform:translate(-50%,-50%) scale(1)}.winner-small{color:#5ce5ff;font:1000 9px Arial;letter-spacing:2px}.winner-name{margin-top:4px;color:#fff;font:1000 26px Arial;text-shadow:0 0 14px rgba(255,216,70,.5)}.join-banner{position:absolute;z-index:45;left:12px;bottom:13px;display:flex;gap:8px;align-items:center;padding:8px 11px;border-radius:12px;background:rgba(6,10,14,.92);border:1px solid rgba(255,255,255,.17);box-shadow:0 8px 25px rgba(0,0,0,.4)}.join-icon{font-size:18px}.join-banner strong{display:block;color:#ffd83f;font:1000 9px Arial;letter-spacing:.7px}.join-banner span{display:block;color:#fff;font:700 8px Arial;margin-top:2px}.queue-mini{position:absolute;z-index:45;right:12px;bottom:13px;width:145px;padding:8px;border-radius:11px;background:rgba(6,10,14,.9);border:1px solid rgba(65,224,255,.28);color:#fff;font:700 8px Arial}.queue-mini b{display:block;color:#4fe2ff;font-size:9px;margin-bottom:3px}.queue-mini span{color:#aeb7c0}
@media(max-width:700px){.track.pro-race{min-height:900px;border-radius:22px!important}.race-topbar{top:8px}.race-brand strong{font-size:28px;line-height:27px}.race-brand small{font-size:6px;letter-spacing:1.4px}.live-pill{font-size:9px;padding:5px 9px}.viewer-pill{font-size:9px;padding:6px 8px}.pro-board{top:83px;width:101px}.board-left{left:6px}.board-right{right:6px}.board-head,.board-title{font-size:8px;padding:7px 6px 0}.driver-row{height:31px;font-size:7px;grid-template-columns:16px 13px 1fr;padding:0 6px}.driver-row>b{font-size:10px}.car-dot{width:10px;height:10px}.lap-row{height:28px;font-size:7px;padding:0 5px}.lap-row em{font-size:6px}.circuit-wrap{left:3%;right:3%;top:75px;bottom:12px}.race-car{width:30px;height:51px;font-size:6px}.race-car:before{height:19px}.position-badge{width:20px;height:20px;font-size:10px}.join-banner{left:7px;bottom:8px}.queue-mini{right:7px;bottom:8px;width:115px}.join-banner span,.queue-mini span{font-size:7px}.pro-winner{min-width:185px;padding:12px 18px}.winner-name{font-size:22px}}
"""
p.write_text(s)
print("CAR RACE PRO V5 APPLIED")
PY

node --check game.js
node --check server.js
echo "=== CHANGED ==="
git diff --stat
echo "Backup files created: $TS"
echo "DO NOT PUSH YET — test localhost first."
"""
path=Path("/mnt/data/apply-car-race-pro-v5.sh"); path.write_text(script); path.chmod(0o755)
zip_path=Path("/mnt/data/car-race-pro-v5.zip")
with zipfile.ZipFile(zip_path,"w",zipfile.ZIP_DEFLATED) as z:z.write(path,path.name)
print(path.stat().st_size, zip_path.stat().st_size)