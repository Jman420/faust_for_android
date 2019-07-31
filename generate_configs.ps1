$RootSourcePath = "./jni"
$BackendsFileSource = "$RootSourcePath/build/backends/backends.cmake"
$TargetsFileSource = "$RootSourcePath/build/targets/regular.cmake"

$OutputPath = "."
$BackendsFileDest = "$OutputPath/backends.cmake"
$TargetsFileDest = "$OutputPath/targets.cmake"

Write-Output "Generating Backends CMake File..."
New-Item -Force $BackendsFileDest
Copy-Item -Force $BackendsFileSource -Destination $BackendsFileDest
Write-Output "Successfully generated Backends CMake File!"

Write-Output "Generating Targets CMake File..."
New-Item -Force $TargetsFileDest
Copy-Item -Force $TargetsFileSource -Destination $TargetsFileDest
Write-Output "Successfully generated Targets CMake File!"
