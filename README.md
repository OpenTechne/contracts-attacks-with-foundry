# Solidity smart contracts attacks reproduction with foundry
Attacks are reproduced using foundry test environment.

## To reproduce an attack
```
forge test -c test/<category>/<attack> -<level of verbosity>
```
level of verbosity:
- -vvv: Test will prompt only logs.
- -vvvv: Test will prompt logs and execution traces.

## Available attacks

| Category          | Name                          |
|-------------------|-------------------------------|
|Token              |EIP-4626-inflation-attack      |
