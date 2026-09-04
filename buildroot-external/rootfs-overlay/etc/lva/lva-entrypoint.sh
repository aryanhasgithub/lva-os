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

        # Boolean/flag fields are written with a "B_" prefix on the env var
        # name (added at config-save time, see config.py's _env_key()).
        # These are zero-argument switches in the LVA CLI, so we emit the
        # bare flag with no trailing value when true, and omit it entirely
        # when false. Detecting this purely from the "B_" prefix means no
        # per-key allowlist needs to be kept in sync with the schema here.
        if [[ "$key" == B_* ]]; then
            bool_key="${key#B_}"
            cli_key=$(echo "${bool_key,,}" | tr '_' '-')
            if [[ "$value" == "1" || "$value" == "true" ]]; then
                ARGS+=("--$cli_key")
            fi
            continue
        fi

        # Standard key-value pairs
        cli_key=$(echo "${key,,}" | tr '_' '-')
        ARGS+=("--$cli_key" "$value")
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