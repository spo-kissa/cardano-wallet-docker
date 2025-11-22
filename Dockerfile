FROM debian:bookworm-slim AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN <<'EOF'
set -eux

	apt-get update

	apt-get install -y jq curl

	mkdir -p /out

	mkdir -p $HOME/git && cd $HOME/git
	curl -SL https://github.com/IntersectMBO/cardano-node/releases/download/10.5.1/cardano-node-10.5.1-linux.tar.gz \
	 | tar -zxC $HOME/git ./bin/cardano-cli
	mv $HOME/git/bin/cardano-cli /out/cardano-cli

	/out/cardano-cli version


	# x64
	if [ "$TARGETARCH" = "amd64" ]; then

		curl -SL https://github.com/IntersectMBO/cardano-addresses/releases/download/4.0.1/cardano-address-4.0.1-linux.tar.gz \
		 | tar -zxC $HOME/git cardano-address
		mv $HOME/git/cardano-address /out/cardano-address

	# arm64
	elif [ "$TARGETARCH" = "arm64" ]; then

		apt-get install -y git build-essential curl libffi-dev libffi8 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5 pkg-config zlib1g-dev libgmp-dev

		mkdir -p $HOME/git && cd $HOME/git
		git clone https://github.com/IntersectMBO/cardano-addresses.git
		cd cardano-addresses

		export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
		export GHCUP_INSTALL_BASE_PREFIX="$HOME"
		curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
		echo 'source $HOME/.ghcup/env' >> ~/.bashrc
		source ~/.bashrc

		ghcup --version
		cabal --version

		cabal update

		cabal build all
		export LANG=C.UTF-8
		cabal test cardano-addresses:unit
		cabal install cardano-address
		mv $(find ./ -name cardano-address -type f) /out/cardano-address

	else
		echo "Unsupported arch: $TARGETARCH";
		exit 1;
	fi

	/out/cardano-address version
	sleep 5

EOF

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/cardano-cli     /usr/local/bin/cardano-cli
COPY --from=builder /out/cardano-address /usr/local/bin/cardano-address

COPY create.sh /usr/local/bin/create.sh
RUN chmod +755 /usr/local/bin/create.sh

USER root
WORKDIR /root

ENTRYPOINT ["tail", "-F", "/dev/null"]
