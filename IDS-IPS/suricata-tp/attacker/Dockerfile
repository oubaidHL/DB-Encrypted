FROM kalilinux/kali-last-release

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nmap hydra curl wget iputils-ping \
        iproute2 openssh-client netcat-openbsd python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/wordlists && \
    printf 'password\n123456\nadmin\nroot\ntoor\npassword123\nqwerty\nletmein\nwelcome\nmonkey\ndragon\nmaster\n12345678\npass\ntest\nabc123\nchangeme\nlinux\ndebian\nsecure\n' \
    > /usr/share/wordlists/ssh_short.txt

COPY attack_scenarios.sh /usr/local/bin/attack_scenarios.sh
RUN chmod +x /usr/local/bin/attack_scenarios.sh

CMD ["tail", "-f", "/dev/null"]
