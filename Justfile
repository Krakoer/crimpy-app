gen:
    dart run build_runner build

migrate:
    dart run drift_dev make-migrations
promote *args:
    ./scripts/promote.sh {{args}}

beta-release *args:
    ./scripts/beta-release.sh {{args}}

prod-release bump *args:
    ./scripts/prod-release.sh {{bump}} {{args}}

# Headless Android emulator with a simulated sensor, see the README.
emulator *args:
    ./scripts/emulator.sh {{args}}
