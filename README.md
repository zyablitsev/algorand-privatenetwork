# Algorand PrivateNetwork Sandbox. The Simplest Tool

This is [Algorand Sandbox](https://github.com/algorand/sandbox) alternative to create an Algorand development environment.

**jq** is required ([https://stedolan.github.io/jq/](https://stedolan.github.io/jq/)).

**Docker** is not needed.

**Postgres** should be installed if you need [Indexer](https://github.com/algorand/indexer) in your environment.

## Usage

Create and edit configuration file:

```bash
~$ cp config.example config
~$ vi config
```

Use the **make** command to interact with the Algorand PrivateNetwork Sandbox.

```plain
make commands:
  binaries-download   -> fetch latest release of algorand node, tools and indexer binaries.
  binaries-clean      -> delete binaries.

  network-create      -> init private network.
  network-start       -> start private network.
  network-stop        -> stop private network.
  network-delete      -> delete private network.
  network-status      -> get node status.
  account-list        -> list of algorand accounts on this machine.

  kmd-start           -> start kmd service.

  pgschema-install    -> create postgres database for indexer.
  pgschema-uninstall  -> remove indexer database.
  indexer-start       -> start indexer.

  clean               -> full cleanup.
```

## Getting Started

### Network (algod)

Open a terminal and run:

```bash
~$ git clone https://github.com/zyablitsev/algorand-privatenetwork.git
```

In whatever local directory the private network sandbox should reside. Then:

```bash
~$ cd algorand-privatenetwork
~$ cp config.example config
~$ vi config
~$ make binaries-download network-create network-start
```

This will download binaries, configure private network and start it.


algod endoint:
  - address: `http://localhost:4001`
  - token (from config): `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`

### Key management daemon (kmd)

Run:

```bash
~$ make kmd-start
```

kmd endpoint:
  - address: `http://localhost:4002`
  - token (from config): `cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc`

### Indexer

To start indexer make sure the postgres is running. Then:

```bash
~$ make pgschema-install indexer-start
```

indexer endpoint:
  - address: `http://localhost:8980`

Example `curl` command

```bash
~$ curl "localhost:8980/v2/accounts"
```
