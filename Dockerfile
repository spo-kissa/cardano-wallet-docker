FROM ubuntu:jammy

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN <<'EOF'

apt-get update

apt-get install -y bash jq nano tmux vim wget curl

mkdir -p $HOME/git && cd $HOME/git
curl -SL https://github.com/IntersectMBO/cardano-node/releases/download/10.5.1/cardano-node-10.5.1-linux.tar.gz \
 | tar -zxC $HOME/git ./bin/cardano-cli
mv $HOME/git/bin/cardano-cli /usr/local/bin/cardano-cli
cardano-cli version
sleep 5

curl -SL https://github.com/IntersectMBO/cardano-addresses/releases/download/4.0.1/cardano-address-4.0.1-linux.tar.gz \
 | tar -zxC $HOME/git cardano-address
mv $HOME/git/cardano-address /usr/local/bin/cardano-address
cardano-address version
sleep 5

cd $HOME

EOF

COPY create.sh /usr/local/bin/create.sh
RUN chmod +755 /usr/local/bin/create.sh

USER root
WORKDIR /root


ENTRYPOINT ["tail", "-F", "/dev/null"]
