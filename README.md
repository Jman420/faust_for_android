# Building Faust for Android

The [build_faust.ps1](build_faust.ps1) script is a PowerShell script which will automatically generate the necessary Android Make files for ndk-build to compile Faust for Android.

## Steps
  - Download the latest release Source Code from [https://github.com/grame-cncm/faust/releases](https://github.com/grame-cncm/faust/releases)
  - Open the Faust Source Code Archive and extract the contents (not the actual folder) of the 'faust-x.x.x' folder to the /jni/ directory
  - Execute the [generate_configs.ps1](generate_configs.ps1) script to generate the 'backend.cmake' & 'targets.cmake' files
  - Modify the 'backend.cmake' & 'targets.cmake' files as necessary
  - Execute the [build_faust.ps1](build_faust.ps1) script
  - Resulting files are in /out/ directory

## Notes

### Building libfaust Embedded Compiler

