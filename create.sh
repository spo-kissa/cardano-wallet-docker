#/usr/bash

# 0) 前提
export NETWORK="--mainnet"    # 例
mkdir -p $HOME/share/hd1 && cd $HOME/share/hd1
# umask 077

# 1) 24語を生成（既存のフレーズがあるなら流用）
cardano-address recovery-phrase generate --size 24 > phrase.txt

# 2) ルート鍵 → アカウント鍵（m/1852H/1815H/0H）
cat phrase.txt \
 | cardano-address key from-recovery-phrase Shelley \
 | cardano-address key child 1852H/1815H/0H > acct.xprv

# 3) 受取用(外部) 0番: m/.../0/0  と ステーク: m/.../2/0
cat acct.xprv | cardano-address key child 0/0 > pay.xprv
cat acct.xprv | cardano-address key child 2/0 > stake.xprv

# 4) cardano-cli 互換の“拡張鍵”へ変換
cardano-cli key convert-cardano-address-key \
  --signing-key-file pay.xprv --shelley-payment-key --out-file payment.xsk
cardano-cli key convert-cardano-address-key \
  --signing-key-file stake.xprv --shelley-stake-key   --out-file stake.xsk

# 5) 検証鍵と非拡張vkeyへ
cardano-cli key verification-key \
  --signing-key-file payment.xsk \
  --verification-key-file payment.evkey
cardano-cli key verification-key \
  --signing-key-file stake.xsk \
  --verification-key-file stake.evkey

cardano-cli key non-extended-key \
  --extended-verification-key-file payment.evkey \
  --verification-key-file payment.vkey
cardano-cli key non-extended-key \
  --extended-verification-key-file stake.evkey \
  --verification-key-file stake.vkey

# 6) アドレス生成（Aと同じ）
cardano-cli address build \
  --payment-verification-key-file payment.vkey \
  --stake-verification-key-file   stake.vkey \
  --out-file addr.addr \
  $NETWORK
