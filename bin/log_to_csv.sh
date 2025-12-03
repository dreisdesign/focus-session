#!/usr/bin/env zsh
# Convert /tmp/watch_inactivity_simple.log -> CSV of paired sessions
# Output: ~/Library/Logs/focus-session/focus-session-YYYY-MM-DD.csv

LOG="/tmp/watch_inactivity_simple.log"
ARCHIVE_DIR="$HOME/Library/Logs/focus-session"
OUT="$ARCHIVE_DIR/focus-session-$(date +%F).csv"

mkdir -p "$ARCHIVE_DIR"

if [[ ! -f "$LOG" || ! -s "$LOG" ]]; then
  echo "No log to convert." >&2
  exit 1
fi

# Header
printf '%s\n' "session,start_epoch,start_iso,start_human,end_epoch,end_iso,end_human,duration_sec,completed" > "$OUT"

# Build ordered list of events: "start,epoch" or "end,epoch"
events=()
while IFS= read -r line; do
  if [[ $line == *"Session start"* ]]; then
    epoch=$(echo "$line" | grep -oE '[0-9]{9,}' | tail -n1)
    [[ -n $epoch ]] && events+=("start,$epoch")
  elif [[ $line == *"Session end"* ]]; then
    epoch=$(echo "$line" | grep -oE '[0-9]{9,}' | tail -n1)
    [[ -n $epoch ]] && events+=("end,$epoch")
  fi
done < "$LOG"

session_idx=1
i=1
len=${#events[@]}
while (( i <= len )); do
  IFS=',' read -r typ epoch <<< "${events[i-1]}"
  if [[ $typ == "start" ]]; then
    s_epoch=$epoch
    # find next end with epoch >= s_epoch
    end_epoch=""
    j=$((i+1))
    while (( j <= len )); do
      IFS=',' read -r typ2 epoch2 <<< "${events[j-1]}"
      if [[ $typ2 == "end" && $epoch2 -ge $s_epoch ]]; then
        end_epoch=$epoch2
        break
      fi
      ((j++))
    done

    start_iso=$(date -r "$s_epoch" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || echo "")
    start_human=$(date -r "$s_epoch" "+%l:%M%p" 2>/dev/null | sed 's/^ //' || echo "")
    if [[ -n $end_epoch ]]; then
      end_iso=$(date -r "$end_epoch" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || echo "")
      end_human=$(date -r "$end_epoch" "+%l:%M%p" 2>/dev/null | sed 's/^ //' || echo "")
      duration=$(( end_epoch - s_epoch ))
      completed=1
    else
      end_iso=""
      end_human=""
      duration=""
      completed=0
    fi

    printf '%s,%s,%s,%s,%s,%s,%s,%s\n' \
      "$session_idx" "$s_epoch" "$start_iso" "$start_human" \
      "${end_epoch:-}" "${end_iso:-}" "${end_human:-}" "${duration:-}" "$completed" >> "$OUT"

    ((session_idx++))
    if [[ -n $end_epoch ]]; then
      i=$((j+1))
    else
      i=$((i+1))
    fi
  else
    e_epoch=$epoch
    end_iso=$(date -r "$e_epoch" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || echo "")
    end_human=$(date -r "$e_epoch" "+%l:%M%p" 2>/dev/null | sed 's/^ //' || echo "")
    printf '%s,%s,%s,%s,%s,%s,%s,%s\n' \
      "$session_idx" "" "" "" "$e_epoch" "$end_iso" "$end_human" "" 1 >> "$OUT"
    ((session_idx++))
    ((i++))
  fi
done

echo "Wrote CSV: $OUT"
