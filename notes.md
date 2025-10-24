# Cripmpy

## Roadmap

- [x] Clean custom training form (no load when rest, hand selector, show some stats, etc)
- [x] Clean available trainings list
- [x] Add form to edit training
- [x] Add form to create repeaters
- [x] Run trainings
- [x] Calibration settings
- [x] Tare dialog when connected
- [x] Allow user to pin trainings on main screen
- [x] Choose a nomenclature and rename all things accordingly
- [x] Better error handling (e.g when saving thing into db, etc.) + Apply logging to all files
- [x] Refacto and clean the code
- [x] BT activation error handling (activate BT, enable location etc.)
- [x] Add profile page
- [x] Add MVC 3FD assessment
- [x] Add critical force assessment
- [ ] Create trainings based on profile
- [ ] Allow logging climbing/stretching/workout sessions
- [ ] Add sessions history screen & session details screen
- [ ] Histogram modes (monday to sunday vs 3 days before 3 days after)
- [ ] Add tutorials before assessment
- [ ] Cleanup UI
- [ ] Write docs and comment code
- [ ] Reorganise whole rep
---------------- V1 merge in main

Future work/ideas:
- [ ] BLE session add record and stop record to avoid saving data in memory when not needed
- [ ] Add tests ???
- [ ] Add an "RPE" notion
- [ ] Allow user to plan its sessions
- [ ] Add backend db
- [ ] Add fitness exercices (dips, pushups, etc.) and allow to create trainings from them.
- [ ] Add AI to suggest planning ?
- [ ] Injury prevention (allow user to tell pain felt during session, propose routines/help)
- [ ] Add "coach" accounts (can edit planning of some users & add notes)

## Install

Install a new prod version wihtout losing data:
```PowerShell
flutter build apk --flavor prod --release
adb install -r .\build\app\outputs\flutter-apk\app-prod-release.apk
```

## Used nomenclature

- A `training` refers as an available workout that can be done using the Crimpy app.
- A `session` refers as a workout that has been done, either using the crimpy or a logged climbing/stretching session.

## Debugging

debug critical force: pull data with `adb -d shell "run-as com.example.crimpy.beta cat /data/user/0/com.example.crimpy.beta/app_flutter/1757075795797" > data.json`