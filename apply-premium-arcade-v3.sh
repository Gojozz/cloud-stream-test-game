#!/data/data/com.termux/files/usr/bin/bash
set -e
cd "$HOME/cloud-stream-test"

cp game.js game.js.backup-before-premium-v3
cp style.css style.css.backup-before-premium-v3

cat >> style.css <<'CSS'

/* PREMIUM ARCADE RACING V3 — SHORTS 9:16 */

body{
  background:
    radial-gradient(circle at 50% 8%,rgba(62,205,255,.20),transparent 28%),
    radial-gradient(circle at 50% 90%,rgba(255,185,40,.08),transparent 24%),
    #03070b;
}

.track{
  border:1px solid rgba(255,255,255,.10);
  border-radius:22px;
  background:
    radial-gradient(ellipse at 50% 18%,rgba(255,255,255,.08),transparent 22%),
    repeating-linear-gradient(135deg,rgba(255,255,255,.025) 0 3px,transparent 3px 11px),
    linear-gradient(145deg,#176f43 0%,#0b452b 52%,#06331f 100%);
  box-shadow:inset 0 0 80px rgba(0,0,0,.55),0 18px 55px rgba(0,0,0,.55);
}

.track::before{
  opacity:.18;
  background-image:radial-gradient(circle,rgba(255,255,255,.32) 0 1px,transparent 1.5px);
  background-size:18px 18px;
}

.circuit-road{
  stroke:#090c10;
  stroke-width:126;
  filter:drop-shadow(0 12px 8px rgba(0,0,0,.58));
}

.circuit-center{
  stroke:rgba(255,255,255,.58);
  stroke-width:2.5;
  stroke-dasharray:18 17;
}

.marble{
  width:54px;
  height:34px;
  border-radius:14px 14px 10px 10px;
  padding-top:20px;
  font-size:7px;
  letter-spacing:.7px;
  transform-origin:center;
  border:1.5px solid rgba(255,255,255,.88);
  box-shadow:0 9px 12px rgba(0,0,0,.58),0 0 13px rgba(255,255,255,.14),
    inset 0 4px 6px rgba(255,255,255,.45),inset 0 -8px 9px rgba(0,0,0,.38);
}

.marble::before{
  left:10px;
  right:10px;
  top:4px;
  height:15px;
  border-radius:8px 8px 5px 5px;
  background:linear-gradient(90deg,#080d13,#60798a,#101820);
  box-shadow:inset 0 2px 4px rgba(255,255,255,.3);
}

.marble::after{
  left:5px;
  right:5px;
  bottom:-5px;
  height:5px;
  background:linear-gradient(90deg,transparent 0 12%,rgba(255,255,255,.9) 12% 24%,
    transparent 24% 76%,rgba(255,255,255,.9) 76% 88%,transparent 88%);
  filter:blur(1.5px);
  opacity:.65;
}

#track .marble:nth-of-type(2){background:linear-gradient(150deg,#ff5964,#d50920 58%,#72000d)}
#track .marble:nth-of-type(3){background:linear-gradient(150deg,#55edff,#0095c7 58%,#00506f)}
#track .marble:nth-of-type(4){background:linear-gradient(150deg,#fff083,#e6a719 58%,#805500)}
#track .marble:nth-of-type(5){background:linear-gradient(150deg,#63ff9d,#13aa59 58%,#07552d)}
#track .marble:nth-of-type(6){background:linear-gradient(150deg,#e19cff,#8d39d0 58%,#46126f)}

.player{
  min-height:44px;
  border-radius:13px;
  background:linear-gradient(145deg,rgba(25,35,48,.94),rgba(6,11,17,.96));
  border:1px solid rgba(255,255,255,.13);
  box-shadow:0 7px 18px rgba(0,0,0,.32),inset 0 1px rgba(255,255,255,.12);
}

.joiners{
  position:relative;
  border-radius:18px;
  background:linear-gradient(145deg,rgba(13,24,35,.97),rgba(3,9,14,.98));
  border:1px solid rgba(65,221,255,.22);
  box-shadow:0 12px 30px rgba(0,0,0,.4),inset 0 1px rgba(255,255,255,.09);
}

.joiners::before{
  content:"LIVE";
  position:absolute;
  top:9px;
  right:11px;
  padding:3px 7px;
  border-radius:999px;
  font-size:7px;
  font-weight:1000;
  letter-spacing:1px;
  color:white;
  background:#d71920;
  box-shadow:0 0 12px rgba(215,25,32,.55);
}

.joiners-title{
  color:#43e5ff;
  letter-spacing:1px;
  text-transform:uppercase;
  text-shadow:0 0 12px rgba(67,229,255,.35);
}

.countdown{
  z-index:20;
  font-weight:1000;
  letter-spacing:4px;
  text-shadow:0 0 18px rgba(69,226,255,.85),0 5px 14px rgba(0,0,0,.8);
}

.finish-label{
  font-weight:1000;
  letter-spacing:4px;
  text-shadow:0 2px 4px #000,0 0 12px rgba(255,255,255,.35);
}

.winner{
  border-radius:22px;
  background:radial-gradient(circle at 50% 25%,rgba(255,213,74,.22),transparent 40%),rgba(5,9,14,.88);
  border:1px solid rgba(255,213,74,.35);
  box-shadow:0 20px 60px rgba(0,0,0,.65),inset 0 1px rgba(255,255,255,.12);
  backdrop-filter:blur(12px);
}

.winner-name{
  color:#fff;
  text-shadow:0 0 12px rgba(255,213,74,.8),0 4px 10px #000;
}

.ai{
  border-radius:18px;
  border:1px solid rgba(69,226,255,.18);
  background:linear-gradient(145deg,rgba(14,25,37,.98),rgba(3,9,14,.98));
  box-shadow:0 14px 34px rgba(0,0,0,.42),inset 0 1px rgba(255,255,255,.08);
}

.ai-status{
  color:#55e7ff;
  text-shadow:0 0 8px rgba(69,226,255,.45);
}

.footer{
  border-top:1px solid rgba(255,255,255,.08);
  background:linear-gradient(90deg,rgba(6,13,20,.95),rgba(11,20,29,.92));
  box-shadow:0 -8px 25px rgba(0,0,0,.22);
}

@media(max-width:700px){
  .track{border-radius:18px}
  .circuit-road{stroke-width:104}
  .marble{width:46px;height:30px;font-size:6px;padding-top:17px}
}
CSS

node --check game.js
node --check server.js
echo "PREMIUM ARCADE V3 APPLIED"
git diff --stat
