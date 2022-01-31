#!/bin/bash -e
sleep 10

retried=1
status=$(vault status -format=json | jq -r '.sealed')
until [ "$status" = "false" ] || [ "$status" = "true" ];do
  echo "[$retried] Vault not initialized yet"
  ((retried++))
  sleep 5
  status=$(vault status -format=json | jq -r '.sealed')
done
echo "Vault is sealed: $status"
test "$status" = "true" || exit 0
echo "unsealing"
vault operator unseal $VAULT_KEY1 &>/dev/null
vault operator unseal $VAULT_KEY2 &>/dev/null
vault operator unseal $VAULT_KEY3 &>/dev/null
