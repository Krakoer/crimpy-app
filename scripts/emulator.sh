#!/usr/bin/env bash
# Run the app on a headless Android emulator, against a simulated force sensor,
# so the app can be seen working on a machine with no phone and no sensor.
# Linux only: it relies on KVM. See "Running on an emulator" in the README.
set -euo pipefail

caller_dir="$PWD"
cd "$(dirname "$0")/.."

sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/sdk}}"
avd="${CRIMPY_AVD:-crimpy}"
api_level=35
system_image="system-images;android-${api_level};google_apis;x86_64"
device_profile="pixel_7"
package="com.crimpyclimbing.crimpy.beta.debug"
activity="com.crimpyclimbing.crimpy.MainActivity"
apk="build/app/outputs/flutter-apk/app-beta-debug.apk"
log="build/emulator.log"

# Every adb call below targets this serial, so a phone plugged in over USB is
# never the device that gets configured, installed onto or screenshotted.
port="${CRIMPY_EMULATOR_PORT:-5554}"
export ANDROID_SERIAL="emulator-$port"
user="$(id -un)"

# 10.0.2.2 is the host's loopback as the emulator sees it, so this reaches
# the API of the dev stack running on the same machine.
api_url="${CRIMPY_API_URL:-http://10.0.2.2:3000}"

dart_defines=(
    --dart-define=CRIMPY_SIMULATED_SENSOR=true
    "--dart-define=CRIMPY_API_URL=$api_url"
)

sdkmanager="$sdk/cmdline-tools/latest/bin/sdkmanager"
avdmanager="$sdk/cmdline-tools/latest/bin/avdmanager"
emulator="$sdk/emulator/emulator"
adb="$sdk/platform-tools/adb"

usage() {
    cat >&2 <<EOF
usage: $0 <command>

  setup              install the emulator and system image, create the AVD
  start              boot the AVD headless and wait until it is ready
  install            build the beta debug APK with the simulated sensor, install it
  launch             (re)start the installed app
  run                start, install and launch in one go
  dev                flutter run on the emulator, with hot reload
  screenshot <file>  save the emulator screen as a PNG
  stop               shut the emulator down
EOF
    exit 1
}

require_kvm() {
    if [ ! -e /dev/kvm ]; then
        echo "/dev/kvm does not exist: this machine offers no KVM, so the emulator" >&2
        echo "cannot run here. On a VM, the host has to enable nested virtualization." >&2
        exit 1
    fi
    if [ -w /dev/kvm ]; then
        return
    fi
    if id -nG "$user" | tr ' ' '\n' | grep -qx kvm ||
        getent group kvm | cut -d: -f4 | tr ',' '\n' | grep -qx "$user"; then
        return
    fi
    echo "$user cannot open /dev/kvm. Add it to the kvm group, then log in again:" >&2
    echo "    sudo gpasswd -a $user kvm" >&2
    exit 1
}

# A group added since login is in /etc/group but not in this shell's
# credentials yet. sg picks it up without a new login. sg hands its command to
# the login shell, which may not be bash, so the command goes in a bash script
# rather than through that shell's quoting.
run_with_kvm() {
    if [ -w /dev/kvm ]; then
        "$@"
        return
    fi
    local script
    script="$(mktemp)"
    printf 'rm -f -- "$0"\nexec %s\n' "$(printf '%q ' "$@")" >"$script"
    sg kvm -c "bash $script"
}

emulator_online() {
    "$adb" devices | grep -q "^$ANDROID_SERIAL[[:space:]]device$"
}

emulator_process_alive() {
    pgrep -f -- "-avd $avd .*-port $port" >/dev/null
}

require_emulator() {
    if ! emulator_online; then
        echo "no emulator is running, start one with: $0 start" >&2
        exit 1
    fi
}

cmd_setup() {
    require_kvm
    # Answers the license prompts. Fed through a process substitution rather
    # than a pipe, whose SIGPIPE on yes would fail the script under pipefail.
    "$sdkmanager" --install emulator platform-tools "$system_image" < <(yes)
    if "$emulator" -list-avds | grep -qx "$avd"; then
        echo "AVD $avd already exists"
    else
        echo no | "$avdmanager" create avd --name "$avd" \
            --package "$system_image" --device "$device_profile"
    fi
}

cmd_start() {
    require_kvm
    if emulator_online; then
        # adbd answers well before the system has booted, so a start that was
        # interrupted, or is still running elsewhere, still has to be waited on.
        echo "emulator already running as $ANDROID_SERIAL"
        wait_for_boot false
        return
    fi
    if ! "$emulator" -list-avds | grep -qx "$avd"; then
        echo "no AVD named $avd, create it with: $0 setup" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$log")"
    # Detached from this shell so it outlives the command that started it.
    # No snapshot is saved, so every boot starts from the same clean device.
    run_with_kvm setsid nohup "$emulator" -avd "$avd" -port "$port" \
        -no-window -no-audio -no-boot-anim -no-snapshot-save \
        -gpu swiftshader_indirect >"$log" 2>&1 </dev/null &
    echo "booting $avd as $ANDROID_SERIAL, log in $log"
    wait_for_boot true
}

# Waits for the system to finish booting, then turns animations off. Checks the
# emulator process is alive only when this script started it: one started
# elsewhere may run under other arguments.
wait_for_boot() {
    local started_here="$1"
    local waited=0
    until [ "$("$adb" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
        # Give the process a moment to appear before treating its absence as
        # a crash at boot.
        if [ "$started_here" = true ] && [ "$waited" -ge 6 ] && ! emulator_process_alive; then
            echo "emulator exited during boot, see $log" >&2
            exit 1
        fi
        if [ "$waited" -ge 300 ]; then
            echo "emulator did not finish booting in 300s, see $log" >&2
            exit 1
        fi
        sleep 2
        waited=$((waited + 2))
    done
    # Animations make screenshots catch screens half way through a transition.
    "$adb" shell settings put global window_animation_scale 0
    "$adb" shell settings put global transition_animation_scale 0
    "$adb" shell settings put global animator_duration_scale 0
    echo "emulator ready as $ANDROID_SERIAL"
}

cmd_install() {
    require_emulator
    flutter build apk --flavor beta --debug "${dart_defines[@]}"
    "$adb" install -r "$apk"
}

cmd_launch() {
    require_emulator
    "$adb" shell am force-stop "$package"
    "$adb" shell am start -W -n "$package/$activity" >/dev/null
    echo "launched $package"
}

cmd_dev() {
    require_emulator
    flutter run --flavor beta -d "$ANDROID_SERIAL" "${dart_defines[@]}"
}

cmd_screenshot() {
    [ $# -eq 1 ] || usage
    require_emulator
    local file="$1"
    case "$file" in
        /*) ;;
        *) file="$caller_dir/$file" ;;
    esac
    mkdir -p "$(dirname "$file")"
    "$adb" exec-out screencap -p >"$file"
    echo "saved $file"
}

cmd_stop() {
    if ! emulator_online; then
        echo "no emulator running as $ANDROID_SERIAL"
        return
    fi
    "$adb" emu kill
}

[ $# -ge 1 ] || usage
command="$1"
shift
case "$command" in
    setup) cmd_setup ;;
    start) cmd_start ;;
    install) cmd_install ;;
    launch) cmd_launch ;;
    run)
        cmd_start
        cmd_install
        cmd_launch
        ;;
    dev) cmd_dev ;;
    screenshot) cmd_screenshot "$@" ;;
    stop) cmd_stop ;;
    *) usage ;;
esac
