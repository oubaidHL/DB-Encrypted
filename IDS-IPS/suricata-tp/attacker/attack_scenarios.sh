#!/usr/bin/env bash
# =============================================================
# attack_scenarios.sh — Scripts d'attaque pour TP1 Suricata
# Cible : 192.168.100.20
# =============================================================

TARGET="192.168.100.20"

print_banner() {
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║  TP1 Suricata — Scénarios d'attaque          ║"
    echo "║  Cible : $TARGET                    ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
}

scenario_1_nmap() {
    echo "[SCENARIO 1] Scan de ports Nmap (Partie 2)"
    echo "-------------------------------------------"
    echo "[*] Scan de version..."
    nmap -sV "$TARGET"
    echo ""
    echo "[*] Requête HTTP..."
    curl -s "http://$TARGET" | head -5 || echo "(pas de réponse HTTP)"
    echo ""
    echo "[*] Ping x10..."
    ping -c 10 "$TARGET"
    echo ""
    echo "[OK] Scénario 1 terminé. Vérifiez fast.log sur le container ids."
}

scenario_2_portscan_rule() {
    echo "[SCENARIO 2] Déclenchement Règle A — Scan rapide (20+ SYN en 5s)"
    echo "------------------------------------------------------------------"
    nmap -sS --min-rate 50 -p 1-100 "$TARGET"
    echo "[OK] Scénario 2 terminé."
}

scenario_3_bruteforce_ssh() {
    echo "[SCENARIO 3] Brute force SSH — Règle B (Partie 3 & 4)"
    echo "------------------------------------------------------"
    echo "[*] Lancement Hydra sur ssh://$TARGET avec wordlist courte..."
    hydra -l root -P /usr/share/wordlists/ssh_short.txt \
          -t 4 -V "ssh://$TARGET"
    echo "[OK] Scénario 3 terminé."
}

scenario_3b_simple_bruteforce() {
    echo "[SCENARIO 3b] Brute force SSH simple (boucle bash, sans Hydra)"
    echo "----------------------------------------------------------------"
    for i in {1..10}; do
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
            mauvaismdp@"$TARGET" 2>/dev/null
        echo "  Tentative $i vers $TARGET:22"
        sleep 1
    done
    echo "[OK] Scénario 3b terminé."
}

scenario_4_exe_transfer() {
    echo "[SCENARIO 4] Transfert fichier .exe via HTTP — Règle C"
    echo "-------------------------------------------------------"
    echo "[*] Requête HTTP avec URI .exe..."
    curl -v "http://$TARGET/malware.exe" 2>&1 | head -20 || true
    curl -v "http://$TARGET/update.EXE" 2>&1 | head -20 || true
    echo "[OK] Scénario 4 terminé."
}

all_scenarios() {
    scenario_1_nmap
    sleep 2
    scenario_2_portscan_rule
    sleep 2
    scenario_3_bruteforce_ssh
    sleep 2
    scenario_4_exe_transfer
}

print_banner

case "${1:-menu}" in
    1) scenario_1_nmap ;;
    2) scenario_2_portscan_rule ;;
    3) scenario_3_bruteforce_ssh ;;
    3b) scenario_3b_simple_bruteforce ;;
    4) scenario_4_exe_transfer ;;
    all) all_scenarios ;;
    *)
        echo "Usage: $0 [1|2|3|3b|4|all]"
        echo ""
        echo "  1   — Scan Nmap + curl + ping  (Partie 2 — Question 1)"
        echo "  2   — Scan rapide SYN          (Règle A)"
        echo "  3   — Brute force SSH Hydra    (Règle B + IPS Partie 4)"
        echo "  3b  — Brute force SSH boucle   (alternative sans Hydra)"
        echo "  4   — Transfert .exe HTTP      (Règle C)"
        echo "  all — Tous les scénarios"
        echo ""
        ;;
esac
