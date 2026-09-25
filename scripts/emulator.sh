#!/usr/bin/env bash
# Run the app on a headless Android emulator, against a simulated force sensor,
# so the app can be seen working on a machine with no phone and no sensor.
# Linux only: it relies on KVM. See "Running on an emulator" in the README.
set -euo pipefail

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
    if [ -w /dev/kvm ]; then
        return
    fi
    if id -nG "$USER" | tr ' ' '\n' | grep -qx kvm ||
        getent group kvm | cut -d: -f4 | tr ',' '\n' | grep -qx "$USER"; then
        return
    fi
    echo "$USER cannot open /dev/kvm. Add it to the kvm group, then log in again:" >&2
    echo "    sudo gpasswd -a $USER kvm" >&2
    exit 1
}

# A group added since login is in /etc/group but not in this shell's
# credentials yet. sg picks it up without a new login.
run_with_kvm() {
    if [ -w /dev/kvm ]; then
        "$@"
    else
        sg kvm -c "$(printf '%q ' "$@")"
    fi
}

serial() {
    "$adb" devices | awk '/^emulator-[0-9]+\tdevice$/ { print $1; exit }'
}

require_emulator() {
    if [ -z "$(serial)" ]; then
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
    if [ -n "$(serial)" ]; then
        echo "emulator already running as $(serial)"
        return
    fi
    if ! "$emulator" -list-avds | grep -qx "$avd"; then
        echo "no AVD named $avd, create it with: $0 setup" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$log")"
    # Detached from this shell so it outlives the command that started it.
    # No snapshot is saved, so every boot starts from the same clean device.
    run_with_kvm setsid nohup "$emulator" -avd "$avd" \
        -no-window -no-audio -no-boot-anim -no-snapshot-save \
        -gpu swiftshader_indirect >"$log" 2>&1 </dev/null &
    echo "booting $avd, log in $log"
    "$adb" wait-for-device
    local waited=0
    until [ "$("$adb" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
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
    echo "emulator ready as $(serial)"
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
    flutter run --flavor beta -d "$(serial)" "${dart_defines[@]}"
}

cmd_screenshot() {
    [ $# -eq 1 ] || usage
    require_emulator
    mkdir -p "$(dirname "$1")"
    "$adb" exec-out screencap -p >"$1"
    echo "saved $1"
}

cmd_stop() {
    if [ -z "$(serial)" ]; then
        echo "no emulator running"
        return
    fi
    "$adb" -s "$(serial)" emu kill
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
