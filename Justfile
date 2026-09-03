gen:
    dart run build_runner build

migrate:
    dart run drift_dev make-migrations
preprod-release *args:
    ./scripts/preprod-release.sh {{args}}

beta-release *args:
    ./scripts/beta-release.sh {{args}}

prod-release bump *args:
    ./scripts/prod-release.sh {{bump}} {{args}}
