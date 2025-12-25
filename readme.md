### maestro local test
- ```curl -Ls "https://get.maestro.mobile.dev" | bash```
- maestro test .maestro/flow.yaml


### adb test
- adb devices
- adb shell pm list packages | grep deskclock

### testing workflow
- act -j mobile-tests --container-architecture linux/amd64
