#!/data/data/com.termux/files/usr/bin/bash
set -e
cd "$HOME/cloud-stream-test"

cp game.js game.js.backup-before-premium-v2
cp style.css style.css.backup-before-premium-v2

cat >> style.css <<'CSS'

/* =========================================================
   PREMIUM SHORTS 9:16 - ARCADE RACING VISUAL V2
   Visual layer only. Server/JOIN/QUEUE logic untouched.
========================================================= */

:root{
  --neon:#43e5ff;
  --gold:#ffd54a;
  --glass:rgba(8,15,24,.82);
}

body{
  background:
    radial-gradient(circle at 50% 10%,rgba(61,190,255,.14),transparent 32%),
    linear-gradient(180deg,#06101a,#020609);
}

.track{
  position:relative;
  overflow:hidden;
  isolation:isolate;
  background:
    radial-gradient(circle at 18% 24%,rgba(255,255,255,.08),transparent 13%),
    radial-gradient(circle at 80% 72%,rgba(0,0,0,.28),transparent 25%),
    repeating-linear-gradient(35deg,rgba(255,255,255,.018) 0 2px,transparent 2px 9px),
    linear-gradient(135deg,#176b3e,#0b4328);
  box-shadow:inset 0 0 55px rgba(0,0,0,.48),0 15px 40px rgba(0,0,0,.35);
}

.track::before{
  content:"";
  position:absolute;
  inset:0;
  z-index:0;
  opacity:.22;
  background-image:radial-gradient(circle,rgba(255,255,255,.25) 0 1px,transparent 1.5px);
  background-size:22px 22px;
  pointer-events:none;
}

.circuit-svg{
  position:absolute;
  inset:0;
  width:100%;
  height:100%;
  z-index:1;
  pointer-events:none;
}

.circuit-road{
  fill:none;
  stroke:#090d11;
  stroke-width:112;
  stroke-linecap:round;
  stroke-linejoin:round;
  filter:drop-shadow(0 8px 6px rgba(0,0,0,.58));
}

.circuit-center{
  fill:none;
  stroke:rgba(255,255,255,.62);
  stroke-width:3;
  stroke-dasharray:22 18;
}

.circuit-finish{
  fill:none;
  stroke:white;
  stroke-width:16;
  stroke-dasharray:10 10;
  filter:drop-shadow(0 0 6px rgba(255,255,255,.5));
}

.marble{
  position:absolute;
  width:50px;
  height:32px;
  border-radius:13px 13px 9px 9px;
  box-sizing:border-box;
  z-index:8;
  display:flex;
  align-items:flex-start;
  justify-content:center;
  padding-top:7px;
  color:#fff;
  font-size:7px;
  font-weight:1000;
  letter-spacing:.5px;
  text-shadow:0 1px 3px #000;
  border:2px solid rgba(255,255,255,.92);
  box-shadow:
    0 7px 9px rgba(0,0,0,.5),
    0 0 10px rgba(255,255,255,.12),
    inset 0 4px 5px rgba(255,255,255,.48),
    inset 0 -7px 7px rgba(0,0,0,.3);
  transition:left .12s linear,top .12s linear,transform .12s linear;
}

.marble::before{
  content:"";
  position:absolute;
  left:9px;
  right:9px;
  top:5px;
  height:14px;
  border-radius:7px 7px 4px 4px;
  background:linear-gradient(90deg,#111820,#526879,#10161d);
  border:1px solid rgba(255,255,255,.35);
  box-shadow:inset 0 2px 3px rgba(255,255,255,.2);
}

.marble::after{
  content:"";
  position:absolute;
  left:-3px;
  right:-3px;
  bottom:-6px;
  height:8px;
  border-radius:50%;
  background:rgba(0,0,0,.42);
  filter:blur(3px);
  z-index:-1;
}

#track .marble:nth-of-type(2){background:linear-gradient(145deg,#ff5a5f,#a50012)}
#track .marble:nth-of-type(3){background:linear-gradient(145deg,#40edff,#006f99)}
#track .marble:nth-of-type(4){background:linear-gradient(145deg,#ffe36a,#b87900)}
#track .marble:nth-of-type(5){background:linear-gradient(145deg,#4ff58c,#087d43)}
#track .marble:nth-of-type(6){background:linear-gradient(145deg,#d68cff,#6322a4)}

.player{
  position:relative;
  overflow:hidden;
  border-radius:14px;
  border:1px solid rgba(255,255,255,.12);
  background:linear-gradient(135deg,rgba(255,255,255,.10),rgba(255,255,255,.025));
  box-shadow:0 7px 20px rgba(0,0,0,.25),inset 0 1px rgba(255,255,255,.12);
  backdrop-filter:blur(8px);
}

.player::after{
  content:"";
  position:absolute;
  inset:0;
  background:linear-gradient(110deg,transparent 35%,rgba(255,255,255,.07) 50%,transparent 65%);
  transform:translateX(-120%);
  animation:cardShine 5s infinite;
}

@keyframes cardShine{
  0%,65%{transform:translateX(-120%)}
  85%,100%{transform:translateX(120%)}
}

.joiners{
  border-radius:16px;
  background:linear-gradient(135deg,rgba(17,25,35,.95),rgba(7,12,18,.94));
  border:1px solid rgba(67,229,255,.18);
  box-shadow:0 10px 28px rgba(0,0,0,.32),inset 0 1px rgba(255,255,255,.08);
}

.joiners-title{
  color:var(--neon);
  text-shadow:0 0 12px rgba(67,229,255,.35);
  font-weight:1000;
}

.joiner{
  display:inline-block;
  margin:3px;
  padding:5px 9px;
  border-radius:999px;
  background:rgba(255,255,255,.08);
  border:1px solid rgba(255,255,255,.1);
  box-shadow:0 3px 8px rgba(0,0,0,.2);
  animation:joinPop .35s ease-out;
}

@keyframes joinPop{
  from{opacity:0;transform:scale(.75) translateY(5px)}
  to{opacity:1;transform:scale(1) translateY(0)}
}

.winner-name{
  text-shadow:0 0 10px rgba(255,213,74,.7),0 3px 8px #000;
  font-weight:1000;
}

.countdown{
  z-index:20;
  text-shadow:0 0 25px rgba(67,229,255,.75),0 4px 10px #000;
}

.ai{
  border:1px solid rgba(67,229,255,.14);
  background:linear-gradient(135deg,rgba(16,25,36,.97),rgba(5,10,16,.97));
  box-shadow:0 12px 30px rgba(0,0,0,.3);
}

@media(max-width:700px){
  .marble{
    width:44px;
    height:29px;
    font-size:6.5px;
    padding-top:6px;
  }
  .circuit-road{stroke-width:94}
  .circuit-center{stroke-width:2.5;stroke-dasharray:18 15}
}
CSS

node --check game.js
node --check server.js

echo "PREMIUM V2 APPLIED"
git diff --stat
