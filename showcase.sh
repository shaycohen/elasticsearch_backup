#!/bin/bash

ES_URL="http://localhost:19200"
INDEX="test-index"
REPO="my_backup"
SNAPSHOT="snapshot_$(date +%Y%m%d_%H%M%S)"
SNAPSHOT_DIR="/usr/share/elasticsearch/backup"

case "$1" in
  init)
    echo "Creating index and inserting 1000 documents..."
    for i in $(seq 1 1000); do
      curl -s -X POST "$ES_URL/$INDEX/_doc/$i" -H 'Content-Type: application/json' -d "{\"value\": $i}" > /dev/null
    done
    echo "Done."
    ;;

  snapshot_init)
    echo "Creating snapshot repository..."
    curl -X PUT "$ES_URL/_snapshot/$REPO" -H 'Content-Type: application/json' -d"
    {
      \"type\": \"fs\",
      \"settings\": {
        \"location\": \"$SNAPSHOT_DIR\",
        \"compress\": true
      }
    }"
    echo
    ;;

  snapshot_take)
    echo "Taking snapshot: $SNAPSHOT"
    curl -X PUT "$ES_URL/_snapshot/$REPO/$SNAPSHOT?wait_for_completion=true"
    echo
    ;;

  snapshot_list)
    echo "Listing snapshots..."
    curl -X GET "$ES_URL/_snapshot/$REPO/_all" | jq .
    ;;

  snapshot_restore)
    echo "Restoring snapshot..."
    LATEST=$(curl -s "$ES_URL/_snapshot/$REPO/_all" | jq -r '.snapshots[-1].snapshot')
    if [ -z "$LATEST" ]; then
      echo "No snapshot found."
      exit 1
    fi
    curl -X POST "$ES_URL/$INDEX/_close"
    echo
    curl -X POST "$ES_URL/_snapshot/$REPO/$LATEST/_restore" -H 'Content-Type: application/json' -d"
    {
      \"indices\": \"$INDEX\",
      \"include_global_state\": false,
      \"ignore_unavailable\": true
    }"
    echo
    curl -X POST "$ES_URL/$INDEX/_open"
    echo
    ;;

  check)
    DOC_ID=${2:-1}
    echo "Checking document with ID: $DOC_ID"
    curl -s "$ES_URL/$INDEX/_doc/$DOC_ID" | jq .
    ;;

  modify)
    DOC_ID=${2:-1}
    echo "Modifying document ID $DOC_ID..."
    curl -X POST "$ES_URL/$INDEX/_doc/$DOC_ID/_update" -H 'Content-Type: application/json' -d"
    {
      \"doc\": {
        \"value\": 999999
      }
    }"
    echo
    ;;

  *)
    echo "Usage: $0 {initialize|snapshot_init|snapshot_take|snapshot_list|snapshot_restore|check <id>|modify <id>}"
    ;;
esac

