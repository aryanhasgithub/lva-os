#!/bin/bash
set -e

# Load config from master.env if present
if [ -f /mnt/data/lva-portal/master.env ]; then
    echo "[lva-entrypoint] Loading config from /mnt/data/lva-portal/master.env"
    ARGS=()
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        
        # Strip quotes from values
        stripped="${value%\"}"
        stripped="${stripped#\"}"
        stripped="${stripped%\'}"
        stripped="${stripped#\'}"
        value="$stripped"

        # 1. Convert underscores to dashes for Python CLI format
        cli_key=$(echo "${key,,}" | tr '_' '-')

        # 2. Handle Boolean Flags (Flags that don't take a value)
        if [[ "$cli_key" == "enable-debug" || "$cli_key" == "debug" ]]; then
            [[ "$value" == "1" || "$value" == "true" ]] && ARGS+=("--debug")
        elif [[ "$cli_key" == "enable-output-only" || "$cli_key" == "output-only" ]]; then
            [[ "$value" == "1" || "$value" == "true" ]] && ARGS+=("--output-only")
        elif [[ "$cli_key" == "enable-thinking-sound" ]]; then
            [[ "$value" == "1" || "$value" == "true" ]] && ARGS+=("--enable-thinking-sound")
        else
            # Standard key-value pairs
            ARGS+=("--$cli_key" "$value")
        fi
    done < /mnt/data/lva-portal/master.env
else
    echo "[lva-entrypoint] WARNING: /mnt/data/lva-portal/master.env not found, using env variables"
    ARGS=()
fi

# Debug: Print the generated arguments
echo "[lva-entrypoint] Generated ARGS:"
for arg in "${ARGS[@]}"; do
    echo "  $arg"
done

# PulseAudio cookie
if [ -n "$PULSE_COOKIE" ] && [ ! -f "$PULSE_COOKIE" ]; then
    echo "[lva-entrypoint] Creating PulseAudio cookie file at $PULSE_COOKIE"
    mkdir -p "$(dirname "$PULSE_COOKIE")"
    touch "$PULSE_COOKIE"
fi

# Wait for PulseAudio
echo "[lva-entrypoint] Checking PulseAudio service status..."
CP_MAX_RETRIES=${CP_MAX_RETRIES:-30}
CP_RETRY_DELAY=${CP_RETRY_DELAY:-1}
count=0
until pactl info > /dev/null 2>&1; do
    if [ "$count" -ge "$CP_MAX_RETRIES" ]; then
        echo "❌ [lva-entrypoint] PulseAudio did not become ready after $CP_MAX_RETRIES seconds"
        exit 1
    fi
    echo "⏳ [lva-entrypoint] PulseAudio socket unavailable, retrying in ${CP_RETRY_DELAY}s..."
    sleep "$CP_RETRY_DELAY"
    count=$((count + 1))
done
echo "✅ [lva-entrypoint] PulseAudio server connection established"

echo "starting application"
exec ./script/run "${ARGS[@]}" "$@" "${EXTRA_ARGS[@]}"