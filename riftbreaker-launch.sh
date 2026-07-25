#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_dir="$root_dir/4114030"
proton_dir="$root_dir/.proton10"
runtime_entry="$root_dir/.steamrt-sniper/run"
steam_root="$root_dir/.steam-client/home/.local/share/Steam"
compat_dir="$proton_dir/compatdata-steam-live-20260718"
server_config="$install_dir/config.cfg"
runtime_config="$install_dir/amp-runtime.cfg"
local_config_dir="$compat_dir/pfx/drive_c/users/steamuser/Documents/The Riftbreaker/config"
local_config="$local_config_dir/local.cfg"
save_root="$compat_dir/pfx/drive_c/users/steamuser/Documents/The Riftbreaker/campaignV2"
resume_latest="${1:-1}"
launcher_pid=""
stopping=0

config_value() {
  local file="$1"
  local key="$2"

  awk -v wanted="$key" '
    tolower($1) == "set" && tolower($2) == tolower(wanted) {
      value = $3
      gsub(/["\r]/, "", value)
    }
    END { print value }
  ' "$file"
}

if [[ "$resume_latest" == "--watchdog" ]]; then
  parent_pid="${2:-}"
  parent_start="${3:-}"

  [[ "$parent_pid" =~ ^[0-9]+$ && "$parent_start" =~ ^[0-9]+$ ]] || exit 2

  watchdog_server_pids() {
    local pid

    while IFS= read -r pid; do
      [[ -n "$pid" ]] || continue
      if tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null | grep -Fqx "STEAM_COMPAT_DATA_PATH=$compat_dir"; then
        printf '%s\n' "$pid"
      fi
    done < <(pgrep -x DedicatedServer || true)
  }

  while [[ -r "/proc/$parent_pid/stat" ]]; do
    current_start="$(awk '{print $22}' "/proc/$parent_pid/stat" 2>/dev/null || true)"
    [[ "$current_start" == "$parent_start" ]] || break
    sleep 1
  done

  sleep 2
  if [[ -z "$(watchdog_server_pids)" ]]; then
    exit 0
  fi

  export HOME="$root_dir/.steam-client/home"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_DATA_HOME="$HOME/.local/share"
  export XDG_CACHE_HOME="$HOME/.cache"
  export STEAM_COMPAT_APP_ID=4114030
  export STEAM_COMPAT_CLIENT_INSTALL_PATH="$steam_root"
  export STEAM_COMPAT_INSTALL_PATH="$install_dir"
  export STEAM_COMPAT_DATA_PATH="$compat_dir"
  export STEAM_COMPAT_TOOL_PATHS="$proton_dir"
  export STEAM_COMPAT_MOUNTS="$proton_dir"
  export PROTON_USE_WINED3D=1
  export LIBGL_ALWAYS_SOFTWARE=1

  (
    cd "$install_dir"
    timeout 25s "$runtime_entry" -- \
      "$proton_dir/proton" run wineboot.exe -e
  ) >/dev/null 2>&1 || true

  deadline=$((SECONDS + 20))
  while (( SECONDS < deadline )) && [[ -n "$(watchdog_server_pids)" ]]; do
    sleep 1
  done

  mapfile -t watchdog_pids < <(watchdog_server_pids)
  if (( ${#watchdog_pids[@]} )); then
    kill -TERM "${watchdog_pids[@]}" 2>/dev/null || true
  fi

  deadline=$((SECONDS + 10))
  while (( SECONDS < deadline )) && [[ -n "$(watchdog_server_pids)" ]]; do
    sleep 1
  done

  mapfile -t watchdog_pids < <(watchdog_server_pids)
  if (( ${#watchdog_pids[@]} )); then
    kill -KILL "${watchdog_pids[@]}" 2>/dev/null || true
  fi
  exit 0
fi

test -x "$proton_dir/proton" || { echo "GE-Proton10 runtime is missing: $proton_dir/proton" >&2; exit 1; }
test -x "$runtime_entry" || { echo "Valve sniper runtime is missing: $runtime_entry" >&2; exit 1; }
test -f "$install_dir/DedicatedServer.bat" || { echo "Riftbreaker launcher is missing: $install_dir/DedicatedServer.bat" >&2; exit 1; }
test -f "$server_config" || { echo "Riftbreaker server config is missing: $server_config" >&2; exit 1; }
[[ "$resume_latest" == "0" || "$resume_latest" == "1" ]] || { echo "Resume Latest Save must be 0 or 1." >&2; exit 1; }

temporary_runtime="$(mktemp "$install_dir/.amp-runtime.cfg.XXXXXX")"
trap 'rm -f "$temporary_runtime"' EXIT
sed -E '/^[[:space:]]*set[[:space:]]+mission_save[[:space:]]+/d' "$server_config" > "$temporary_runtime"
resume_selected=0

if [[ "$resume_latest" == "1" && -d "$save_root" ]]; then
  latest_info="$(find "$save_root" -mindepth 2 -maxdepth 2 -type f -name '*.inf' -printf '%T@|%p\n' | sort -nr | sed -n '1s/^[^|]*|//p')"
  if [[ -n "$latest_info" ]]; then
    encoded_name="$(basename "$latest_info" .inf)"
    save_name="$(printf '%s' "$encoded_name" | base64 --decode)"
    [[ -n "$save_name" && "$save_name" != *'"'* && "$save_name" != *'\'* && "$save_name" != *$'\r'* && "$save_name" != *$'\n'* ]] || {
      echo "Latest Riftbreaker save name is unsafe or empty; refusing to launch." >&2
      exit 1
    }
    sed -E -i '/^[[:space:]]*set[[:space:]]+(campaign|mission|difficulty)[[:space:]]+/d' "$temporary_runtime"
    printf '%s\r\n' "set mission_save \"$save_name\"" >> "$temporary_runtime"
    resume_selected=1
    echo "Selected latest Riftbreaker save for resume: $save_name"
  else
    echo "Resume Latest Save is enabled, but no save metadata exists; starting the configured new campaign."
  fi
fi

if [[ "$resume_selected" == "0" ]]; then
  campaign_value="$(config_value "$temporary_runtime" campaign)"
  mission_value="$(config_value "$temporary_runtime" mission)"
  difficulty_value="$(config_value "$temporary_runtime" difficulty)"

  case "$campaign_value" in
    open/open)
      case "$mission_value" in
        campaigns/open/headquarters_jungle|campaigns/open/headquarters_metallic|campaigns/open/headquarters_acid|campaigns/open/headquarters_ice|campaigns/open/headquarters_swamp|campaigns/open/headquarters_caverns|campaigns/open/headquarters_desert) ;;
        *) echo "Starting Mission must be an Open Campaign mission when Game Mode is Open Campaign." >&2; exit 1 ;;
      esac
      case "$difficulty_value" in
        easy|normal|hard|brutal) ;;
        *) echo "Difficulty must be an Open Campaign difficulty when Game Mode is Open Campaign." >&2; exit 1 ;;
      esac
      ;;
    mp_story/mp_story)
      case "$difficulty_value" in
        coop_campaign_easy|coop_campaign_normal|coop_campaign_hard|coop_campaign_brutal) ;;
        *) echo "Difficulty must be a Story Campaign difficulty when Game Mode is Story Campaign." >&2; exit 1 ;;
      esac
      sed -E -i '/^[[:space:]]*set[[:space:]]+mission[[:space:]]+/d' "$temporary_runtime"
      ;;
    mp_survival/mp_survival)
      case "$mission_value" in
        survival/jungle|survival/acid|survival/desert|survival/magma|survival/ice|survival/metallic|survival/caverns|survival/swamp|survival/swamp_lakes) ;;
        *) echo "Starting Mission must be a Survival mission when Game Mode is Survival." >&2; exit 1 ;;
      esac
      case "$difficulty_value" in
        coop_easy|coop_normal|coop_hard|coop_brutal) ;;
        *) echo "Difficulty must be a Survival difficulty when Game Mode is Survival." >&2; exit 1 ;;
      esac
      ;;
    *)
      echo "Game Mode must be Open Campaign, Story Campaign, or Survival." >&2
      exit 1
      ;;
  esac
fi

chmod 0600 "$temporary_runtime"
mv -f "$temporary_runtime" "$runtime_config"
trap - EXIT

disable_steam_value="$(config_value "$server_config" disable_steam)"
[[ "$disable_steam_value" == "1" ]] || {
  echo "The current Linux/Proton launcher requires Disable Steam Networking enabled. This compatibility mode supports the verified public browser and Internet client path when broadcasting and UDP 6321 are enabled." >&2
  exit 1
}

mkdir -p "$local_config_dir"
temporary_config="$(mktemp "$local_config_dir/.local.cfg.XXXXXX")"
trap 'rm -f "$temporary_config"' EXIT

if [[ -f "$local_config" ]]; then
  sed -E '/^[[:space:]]*set[[:space:]]+disable_steam[[:space:]]+/d' "$local_config" > "$temporary_config"
else
  printf '%s\r\n' 'set local_config_version "2"' 'set mouse_sensitivity "1"' > "$temporary_config"
fi
printf 'set disable_steam "%s"\r\n' "$disable_steam_value" >> "$temporary_config"
chmod 0644 "$temporary_config"
mv -f "$temporary_config" "$local_config"
trap - EXIT

export HOME="$root_dir/.steam-client/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export STEAM_COMPAT_APP_ID=4114030
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$steam_root"
export STEAM_COMPAT_INSTALL_PATH="$install_dir"
export STEAM_COMPAT_DATA_PATH="$compat_dir"
export STEAM_COMPAT_TOOL_PATHS="$proton_dir"
export STEAM_COMPAT_MOUNTS="$proton_dir"
export PROTON_USE_WINED3D=1
export LIBGL_ALWAYS_SOFTWARE=1

server_pids() {
  local pid

  while IFS= read -r pid; do
    [[ -n "$pid" ]] || continue
    if tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null | grep -Fqx "STEAM_COMPAT_DATA_PATH=$compat_dir"; then
      printf '%s\n' "$pid"
    fi
  done < <(pgrep -x DedicatedServer || true)
}

wait_for_server_exit() {
  local timeout_seconds="$1"
  local deadline=$((SECONDS + timeout_seconds))

  while (( SECONDS < deadline )); do
    if [[ -z "$(server_pids)" ]]; then
      return 0
    fi
    sleep 1
  done

  return 1
}

end_prefix_session() {
  (
    cd "$install_dir"
    timeout 25s "$runtime_entry" -- \
      "$proton_dir/proton" run wineboot.exe -e
  ) || true
}

stop_server() {
  local -a pids=()

  if (( stopping )); then
    return
  fi
  stopping=1
  trap - INT TERM

  printf '%s\n' 'Riftbreaker supervisor: ending the Proton session.'
  end_prefix_session

  if ! wait_for_server_exit 30; then
    mapfile -t pids < <(server_pids)
    if (( ${#pids[@]} )); then
      printf '%s\n' 'Riftbreaker supervisor: clean exit timed out; sending TERM to the scoped server process.'
      kill -TERM "${pids[@]}" 2>/dev/null || true
    fi
  fi

  if ! wait_for_server_exit 10; then
    mapfile -t pids < <(server_pids)
    if (( ${#pids[@]} )); then
      printf '%s\n' 'Riftbreaker supervisor: TERM timed out; sending KILL to the scoped server process.'
      kill -KILL "${pids[@]}" 2>/dev/null || true
    fi
  fi

  if [[ -n "$launcher_pid" ]] && kill -0 "$launcher_pid" 2>/dev/null; then
    kill -TERM "$launcher_pid" 2>/dev/null || true
  fi
  if [[ -n "$launcher_pid" ]]; then
    wait "$launcher_pid" 2>/dev/null || true
  fi

  printf '%s\n' 'Riftbreaker supervisor: stopped.'
  exit 0
}

trap stop_server INT TERM

if [[ -n "$(server_pids)" ]]; then
  printf '%s\n' 'Riftbreaker supervisor: found a detached server for this instance; ending its Proton session before launch.'
  end_prefix_session
  if ! wait_for_server_exit 30; then
    printf '%s\n' 'Riftbreaker supervisor: the existing scoped server did not exit; refusing to launch a duplicate.' >&2
    exit 1
  fi
fi

parent_start="$(awk '{print $22}' "/proc/$$/stat")"
setsid -f "$0" --watchdog "$$" "$parent_start" >/dev/null 2>&1

cd "$install_dir"
/usr/bin/xvfb-run -a -s '-screen 0 1280x720x24 +extension GLX -nolisten tcp' \
  "$runtime_entry" -- \
  "$proton_dir/proton" run \
  "$install_dir/DedicatedServer.bat" cli=1 config=amp-runtime.cfg &
launcher_pid=$!

server_deadline=$((SECONDS + 120))
while (( SECONDS < server_deadline )); do
  if [[ -n "$(server_pids)" ]]; then
    printf '%s\n' 'Riftbreaker supervisor: server process detected.'
    break
  fi
  if ! kill -0 "$launcher_pid" 2>/dev/null; then
    set +e
    wait "$launcher_pid"
    launcher_rc=$?
    set -e
    exit "$launcher_rc"
  fi
  sleep 1
done

if [[ -z "$(server_pids)" ]]; then
  printf '%s\n' 'Riftbreaker supervisor: server process was not detected before the startup timeout.' >&2
  stop_server
fi

while [[ -n "$(server_pids)" ]]; do
  sleep 1
done

wait "$launcher_pid" 2>/dev/null || true
printf '%s\n' 'Riftbreaker supervisor: server process exited.'
