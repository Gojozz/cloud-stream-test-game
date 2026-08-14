#!/data/data/com.termux/files/usr/bin/bash
set -e
cd "$HOME/cloud-stream-test"

cp game.js game.js.backup-before-circuit-final
cp style.css style.css.backup-before-circuit-final

python - <<'PY'
from pathlib import Path
import re

p = Path("game.js")
s = p.read_text()

start = s.index("function resetMarbles()")
end = s.index("\nfunction showCountdown", start)

new_block = r'''
function resetMarbles() {
    marbles.forEach((car, i) => {
        car.style.setProperty("--lane", i - 2);
        car.style.setProperty("--depth-scale", "1");
    });
    resetRaceCamera();
}

/* 2D TOP-DOWN RACING CIRCUIT */

let circuitReady = false;

const circuitPoints = [
    [80, 70],
    [w => w - 80, 70],
    [w => w - 80, 210],
    [w => w * 0.48, 210],
    [w => w * 0.48, 365],
    [80, 365],
    [80, 540],
    [w => w - 80, 540],
    [w => w - 80, 680]
];

function pv(v, w) {
    return typeof v === "function" ? v(w) : v;
}

function getCircuitPoint(progress, lane) {
    const w = track.clientWidth || 900;
    const h = track.clientHeight || 720;
    const pts = circuitPoints.map(([x,y]) => [
        pv(x,w),
        Math.min(pv(y,w), h - 45)
    ]);

    let total = 0;
    const lengths = [];
    for (let i=1; i<pts.length; i++) {
        const dx=pts[i][0]-pts[i-1][0];
        const dy=pts[i][1]-pts[i-1][1];
        const len=Math.hypot(dx,dy);
        lengths.push(len);
        total += len;
    }

    const target=Math.max(0,Math.min(1,progress))*total;
    let travelled=0;

    for (let i=1; i<pts.length; i++) {
        const len=lengths[i-1];
        if (travelled+len >= target) {
            const t=len ? (target-travelled)/len : 0;
            const x=pts[i-1][0]+(pts[i][0]-pts[i-1][0])*t;
            const y=pts[i-1][1]+(pts[i][1]-pts[i-1][1])*t;
            const dx=pts[i][0]-pts[i-1][0];
            const dy=pts[i][1]-pts[i-1][1];
            const mag=Math.hypot(dx,dy)||1;
            const sideX=-dy/mag;
            const sideY=dx/mag;
            const offset=lane*17;

            return {
                x:x+sideX*offset,
                y:y+sideY*offset,
                angle:Math.atan2(dy,dx)*180/Math.PI
            };
        }
        travelled += len;
    }

    const last=pts[pts.length-1];
    return {x:last[0],y:last[1],angle:0};
}

function createCircuit() {
    if (circuitReady || !track) return;

    const old=track.querySelector(".circuit-svg");
    if (old) old.remove();

    const NS="http://www.w3.org/2000/svg";
    const svg=document.createElementNS(NS,"svg");
    svg.classList.add("circuit-svg");
    svg.setAttribute("aria-hidden","true");

    const w=track.clientWidth||900;
    const h=track.clientHeight||720;
    svg.setAttribute("viewBox",`0 0 ${w} ${h}`);
    svg.setAttribute("preserveAspectRatio","none");

    const endY=Math.min(680,h-45);
    const d=[
        "M 80 70",
        `L ${w-80} 70`,
        `L ${w-80} 210`,
        `L ${w*0.48} 210`,
        `L ${w*0.48} 365`,
        "L 80 365",
        "L 80 540",
        `L ${w-80} 540`,
        `L ${w-80} ${endY}`
    ].join(" ");

    const road=document.createElementNS(NS,"path");
    road.setAttribute("d",d);
    road.setAttribute("class","circuit-road");

    const center=document.createElementNS(NS,"path");
    center.setAttribute("d",d);
    center.setAttribute("class","circuit-center");

    svg.appendChild(road);
    svg.appendChild(center);

    const finish=document.createElementNS(NS,"path");
    finish.setAttribute("d",`M ${w-105} ${endY-28} L ${w-105} ${endY+28}`);
    finish.setAttribute("class","circuit-finish");
    svg.appendChild(finish);

    track.insertBefore(svg,track.firstChild);
    circuitReady=true;
}

function resetRaceCamera() {
    track.style.setProperty("--camera-y","0px");
    createCircuit();

    marbles.forEach((car,i)=>{
        const p=getCircuitPoint(0,i-2);
        car.style.left=`${p.x-24}px`;
        car.style.top=`${p.y-17}px`;
        car.style.transform=`rotate(${p.angle}deg)`;
    });
}

function updateRaceCamera(positions) {
    if (!positions || !positions.length) return;

    createCircuit();

    positions.forEach((position,index)=>{
        const car=marbles[index];
        if (!car) return;

        const progress=(position-35)/(690-35);
        const p=getCircuitPoint(progress,index-2);

        car.style.left=`${p.x-24}px`;
        car.style.top=`${p.y-17}px`;
        car.style.transform=`rotate(${p.angle}deg)`;
    });
}

window.addEventListener("resize",()=>{
    circuitReady=false;
    resetMarbles();
});
'''

s=s[:start]+new_block+s[end:]
p.write_text(s)

p=Path("style.css")
s=p.read_text()

m=re.search(r'/\* MARBLES \*/.*?(?=\n/\*|\Z)',s,re.S)

css=r'''
/* TOP-DOWN RACING CARS */

.track {
    position: relative;
    overflow: hidden;
    background:
        radial-gradient(circle at 20% 20%, rgba(255,255,255,.08), transparent 28%),
        linear-gradient(135deg,#23833f 0%,#17652f 50%,#0f5127 100%);
}

.circuit-svg {
    position:absolute;
    inset:0;
    width:100%;
    height:100%;
    z-index:1;
    pointer-events:none;
}

.circuit-road {
    fill:none;
    stroke:rgba(20,20,20,.72);
    stroke-width:104;
    stroke-linecap:round;
    stroke-linejoin:round;
}

.circuit-center {
    fill:none;
    stroke:rgba(255,255,255,.62);
    stroke-width:3;
    stroke-dasharray:18 15;
    stroke-linecap:round;
}

.circuit-finish {
    fill:none;
    stroke:white;
    stroke-width:12;
    stroke-dasharray:8 8;
}

.marble {
    position:absolute;
    width:48px;
    height:34px;
    border-radius:14px 14px 10px 10px;
    z-index:8;
    display:flex;
    align-items:flex-start;
    justify-content:center;
    padding-top:7px;
    box-sizing:border-box;
    color:white;
    font-size:8px;
    font-weight:900;
    letter-spacing:.4px;
    text-shadow:0 1px 2px #000;
    border:2px solid rgba(255,255,255,.9);
    box-shadow:
        0 5px 8px rgba(0,0,0,.45),
        inset 0 3px 4px rgba(255,255,255,.45),
        inset 0 -5px 6px rgba(0,0,0,.25);
    transition:
        left .12s linear,
        top .12s linear,
        transform .12s linear;
}

.marble::before {
    content:"";
    position:absolute;
    left:9px;
    right:9px;
    top:5px;
    height:15px;
    border-radius:7px 7px 5px 5px;
    background:rgba(30,40,55,.78);
    border:1px solid rgba(255,255,255,.35);
    z-index:-1;
}

.marble::after {
    content:"";
    position:absolute;
    left:4px;
    right:4px;
    bottom:-3px;
    height:6px;
    border-radius:50%;
    background:rgba(0,0,0,.35);
    filter:blur(2px);
    z-index:-2;
}

#track .marble:nth-of-type(2){background:#e53935}
#track .marble:nth-of-type(3){background:#00a9c7}
#track .marble:nth-of-type(4){background:#e4ae00}
#track .marble:nth-of-type(5){background:#27ae60}
#track .marble:nth-of-type(6){background:#8e44ad}

.finish-label{z-index:6}
'''

if m:
    s=s[:m.start()]+css+s[m.end():]
else:
    s+="\n"+css+"\n"

p.write_text(s)
print("Circuit 2D visual patch applied.")
PY

node --check server.js
node --check game.js
echo "DONE"
git diff --stat
