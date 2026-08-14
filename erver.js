[1mdiff --git a/server.js b/server.js[m
[1mindex e97476d..47e7063 100644[m
[1m--- a/server.js[m
[1m+++ b/server.js[m
[36m@@ -476,32 +476,23 @@[m [mfunction prepareNextPlayers() {[m
     return;[m
   }[m
 [m
[31m-  const available =[m
[31m-    MAX_PLAYERS - players.length;[m
[31m-[m
[31m-  if (available <= 0) {[m
[31m-    return;[m
[31m-  }[m
[31m-[m
[31m-  const newcomers =[m
[31m-    waitingPlayers.splice([m
[31m-      0,[m
[31m-      available[m
[31m-    );[m
[32m+[m[32m  const newcomers = waitingPlayers.splice([m
[32m+[m[32m    0,[m
[32m+[m[32m    MAX_PLAYERS[m
[32m+[m[32m  );[m
 [m
[31m-  players.push(...newcomers);[m
[32m+[m[32m  players = newcomers;[m
 [m
   io.emit("playerUpdate", {[m
     players[m
   });[m
 [m
   io.emit("queueUpdate", {[m
[31m-    waiting:[m
[31m-      waitingPlayers.map(p => p.name)[m
[32m+[m[32m    waiting: waitingPlayers.map(p => p.name)[m
   });[m
 [m
   console.log([m
[31m-    "Players:",[m
[32m+[m[32m    "NEXT RACE PLAYERS:",[m
     players.map(p => p.name).join(", ")[m
   );[m
 }[m
