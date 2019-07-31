# Building Faust for Android

The [build_faust.ps1](build_faust.ps1) script is a PowerShell script which will automatically generate the necessary Android Make files for ndk-build to compile Faust for Android.

## Requirements
  - LLVM for Android (See [https://github.com/Jman420/llvm_for_android](https://github.com/Jman420/llvm_for_android))

## Steps
  - Build LLVM for Android in libs/llvm_for_android/ (See above referenced repo for instructions)
  - Execute the [generate_configs.ps1](generate_configs.ps1) script to generate the 'backend.cmake' & 'targets.cmake' files
  - Modify the 'backend.cmake' & 'targets.cmake' files as necessary
  - Execute the [build_faust.ps1](build_faust.ps1) script
  - Resulting files are in /out/ directory
