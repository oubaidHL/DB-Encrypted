# TP1 Suricata — Guide d'utilisation Docker

## Architecture

```
192.168.100.0/24  (réseau isolé lab_net)
┌──────────────────────────────────────────────────────────────────┐
│  ids       192.168.100.10   jasonish/suricata:latest  IDS/IPS   │
│  target    192.168.100.20   linuxserver/openssh-server  Cible   │
│  attacker  192.168.100.100  kalilinux/kali-rolling    Attaque   │
└──────────────────────────────────────────────────────────────────┘
```

> **Aucun build requis** — les images sont téléchargées depuis Docker Hub.

---

## 1. Démarrage

```bash
docker compose up -d
docker compose ps
```

Premier lancement : ~500 Mo téléchargés (une seule fois).
Attendre que l'attacker affiche `[*] Attacker ready.` :
```bash
docker compose logs attacker | tail -5
docker compose logs ids      | tail -10
```

---

## 2. Partie 2 — Première écoute (Question 1)

```bash
# Terminal 1 — alertes texte
docker exec ids tail -f /var/log/suricata/fast.log

# Terminal 2 — alertes JSON
docker exec ids tail -f /var/log/suricata/eve.json | python3 -m json.tool

# Terminal 3 — lancer les attaques
docker exec -it attacker bash
attack_scenarios.sh 1        # nmap + curl + ping
```

---

## 3. Partie 3 — Règles personnalisées (Question 2)

Éditer `suricata/rules/local.rules` puis :
```bash
docker compose restart ids
```

```bash
docker exec -it attacker bash
attack_scenarios.sh 2    # Règle A — scan de ports
attack_scenarios.sh 3    # Règle B — brute force SSH (Hydra)
attack_scenarios.sh 3b   # Règle B — boucle simple
attack_scenarios.sh 4    # Règle C — transfert .exe HTTP
```

---

## 4. Partie 4 — Mode IPS (Question 3)

1. Dans `local.rules` : commenter Règle B (alert), décommenter Règle B-IPS (drop)

2. Passer en mode IPS :
```bash
docker exec -it ids bash
iptables -I FORWARD -j NFQUEUE --queue-num 0
iptables -I INPUT   -j NFQUEUE --queue-num 0
iptables -I OUTPUT  -j NFQUEUE --queue-num 0
pkill suricata
suricata -c /etc/suricata/suricata.yaml -q 0 --pidfile /var/run/suricata.pid &
```

3. Relancer l'attaque :
```bash
docker exec -it attacker attack_scenarios.sh 3
```

4. Vérifier le blocage :
```bash
docker exec ids grep "blocked" /var/log/suricata/eve.json
```

---

## 5. Comptes

| Service | User | Password |
|---------|------|----------|
| target (SSH) | root | toor |
