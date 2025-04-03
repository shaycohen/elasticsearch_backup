#Below is a script configured to exclude a specific index (in this example, log-index) from being backed up during the snapshot process:
$ES_URL = "http://localhost:19200"
$INDEX = "test-index"
$REPO = "my_backup"
$SNAPSHOT_DIR = "/usr/share/elasticsearch/backup"
$SNAPSHOT = "snapshot_{0:yyyyMMdd_HHmmss}" -f (Get-Date)

param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("initialize", "snapshot_init", "snapshot_take", "snapshot_list", "snapshot_restore", "check", "modify")]
    [string]$Action,
    
    [string]$Id = "1"
)

switch ($Action) {
    "initialize" {
        Write-Host "Creating index and inserting 1000 documents..."
        1..1000 | ForEach-Object {
            $body = @{ value = $_ } | ConvertTo-Json -Compress
            Invoke-RestMethod -Method PUT -Uri "$ES_URL/$INDEX/_doc/$_" -ContentType "application/json" -Body $body | Out-Null
        }
        Write-Host "Done."
    }

    "snapshot_init" {
        Write-Host "Creating snapshot repository..."
        $body = @{
            type = "fs"
            settings = @{ location = $SNAPSHOT_DIR; compress = $true }
        } | ConvertTo-Json -Depth 3
        Invoke-RestMethod -Method PUT -Uri "$ES_URL/_snapshot/$REPO" -ContentType "application/json" -Body $body
    }

    "snapshot_take" {
        Write-Host "Taking snapshot: $SNAPSHOT"
        $indicesToBackup = (Invoke-RestMethod -Method GET -Uri "$ES_URL/_cat/indices?h=index" | Out-String).Split("`n") | Where-Object { $_ -ne "log-index" } | ForEach-Object { $_.Trim() }
        $indices = $indicesToBackup -join ","
        Invoke-RestMethod -Method PUT -Uri "$ES_URL/_snapshot/$REPO/$SNAPSHOT?wait_for_completion=true&indices=$indices" -ContentType "application/json"
    }

    "snapshot_list" {
        Write-Host "Listing snapshots..."
        Invoke-RestMethod -Method GET -Uri "$ES_URL/_snapshot/$REPO/_all" | ConvertTo-Json -Depth 3
    }

    "snapshot_restore" {
        Write-Host "Restoring latest snapshot..."
        $snapshots = Invoke-RestMethod -Method GET -Uri "$ES_URL/_snapshot/$REPO/_all"
        $latest = $snapshots.snapshots[-1].snapshot
        if (-not $latest) {
            Write-Host "No snapshot found."
            exit 1
        }
        $body = @{
            indices = $INDEX
            include_global_state = $false
            ignore_unavailable = $true
        } | ConvertTo-Json -Depth 3
        Invoke-RestMethod -Method POST -Uri "$ES_URL/$INDEX/_close" -ContentType "application/json"
        Invoke-RestMethod -Method POST -Uri "$ES_URL/_snapshot/$REPO/$latest/_restore" -ContentType "application/json" -Body $body
        Invoke-RestMethod -Method POST -Uri "$ES_URL/$INDEX/_open" -ContentType "application/json"
    }

    "check" {
        Write-Host "Checking document ID: $Id"
        Invoke-RestMethod -Method GET -Uri "$ES_URL/$INDEX/_doc/$Id" | ConvertTo-Json -Depth 3
    }

    "modify" {
        Write-Host "Modifying document ID: $Id"
        $body = @{ doc = @{ value = 999999 } } | ConvertTo-Json -Depth 3
        Invoke-RestMethod -Method POST -Uri "$ES_URL/$INDEX/_doc/$Id/_update" -ContentType "application/json" -Body $body
    }
}
