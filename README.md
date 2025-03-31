# Elasticsearch Snapshot Showcase

This project demonstrates how to use Elasticsearch 6.4.0 snapshots for backup and restore in a Dockerized environment using both Bash and PowerShell.

It provides a complete flow to:
- Initialize an index with sample data
- Configure a snapshot repository
- Take and list snapshots
- Modify documents to simulate data loss/change
- Restore from snapshot and verify integrity

## 🐳 Getting Started

### 1. Start Elasticsearch

```bash
docker-compose up -d
```

Make sure Elasticsearch is accessible at: http://localhost:19200

---

## ⚙️ Script Usage

### 🐧 Bash (showcase.sh)

```bash
./showcase.sh initialize             # Index 1000 documents into "test-index"
./showcase.sh snapshot_init          # Register snapshot repository
./showcase.sh snapshot_take          # Take a new snapshot
./showcase.sh snapshot_list          # List all snapshots
./showcase.sh modify <id>            # Modify a document by ID (default: 1)
./showcase.sh check <id>             # View document by ID (default: 1)
./showcase.sh snapshot_restore       # Restore the latest snapshot
```

### 🪟 PowerShell (showcase.ps1)

```powershell
.\showcase.ps1 -Action initialize            # Index 1000 documents into "test-index"
.\showcase.ps1 -Action snapshot_init         # Register snapshot repository
.\showcase.ps1 -Action snapshot_take         # Take a new snapshot
.\showcase.ps1 -Action snapshot_list         # List all snapshots
.\showcase.ps1 -Action modify -Id 1          # Modify document with ID 1
.\showcase.ps1 -Action check -Id 1           # View document with ID 1
.\showcase.ps1 -Action snapshot_restore      # Restore the latest snapshot
```

---

## 🔄 Example Flow

```bash
./showcase.sh initialize
./showcase.sh snapshot_init
./showcase.sh snapshot_take
./showcase.sh modify 1
./showcase.sh check 1
./showcase.sh snapshot_restore
./showcase.sh check 1
```

Or in PowerShell:

```powershell
.\showcase.ps1 -Action initialize
.\showcase.ps1 -Action snapshot_init
.\showcase.ps1 -Action snapshot_take
.\showcase.ps1 -Action modify -Id 1
.\showcase.ps1 -Action check -Id 1
.\showcase.ps1 -Action snapshot_restore
.\showcase.ps1 -Action check -Id 1
```

---

## 📦 Requirements

- Bash or PowerShell
- `curl` (for Bash)
- `jq` (for pretty JSON output in Bash)

Install `jq` via:

```bash
brew install jq        # macOS
sudo apt install jq    # Debian/Ubuntu
```

---

## 🧹 Cleanup

To stop and remove containers and volumes:

```bash
docker-compose down -v
```

---

## 🧠 License

This project is for educational and demonstration purposes.
