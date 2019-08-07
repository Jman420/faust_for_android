$BuildDir = "test-build"
$RootSourcePath = "faust-src"
$FaustBuildDir = "build"

$AndroidSystemVersion="21"
$AndroidSdkDir = "$env:LOCALAPPDATA/Android/Sdk"
$AndroidCmake = "$AndroidSdkDir/cmake/3.10.2.4988404/bin/cmake.exe"
$AndroidNinja = "$AndroidSdkDir/cmake/3.10.2.4988404/bin/ninja.exe"
$NdkBundle = "$AndroidSdkDir/ndk-bundle/"
$ToolchainFile = "$NdkBundle/build/cmake/android.toolchain.cmake"
$ArchTargets = @("x86") #@("armeabi-v7a", "arm64-v8a", "x86", "x86_64")

$LlvmAndroidBuildPath = "libs/llvm_for_android/android-build"

for ($archCounter = 0; $archCounter -lt $ArchTargets.Length; $archCounter++) {
    $archTarget = $ArchTargets[$archCounter]

    $archBuildDir = "$BuildDir/$archTarget"
    $fullLlvmDir = Resolve-Path "$LlvmAndroidBuildPath/$archTarget/lib/cmake/llvm"
    
    Write-Output "Setting Up Build Environment for Architecture : $archTarget ..."
    if (Test-Path $archBuildDir) {
        Write-Output "Removing existing Output Directory for $archTarget..."
        Remove-Item $archBuildDir -Force -Recurse
    }
    
    Write-Output "Creating Build Directory for $archTarget ..."
    New-Item -ItemType directory -Force -Path $archBuildDir
    
    $buildFullPath = Resolve-Path $archBuildDir
    $targetFaustBuildDir = Resolve-Path "$FaustBuildDir/$archTarget"
    
    Write-Output "Generating Project Files for Architecture : $archTarget ..."
    Push-Location $buildFullPath
    . $AndroidCmake `
        -DCMAKE_TOOLCHAIN_FILE="$ToolchainFile" `
        -DCMAKE_MAKE_PROGRAM="$AndroidNinja" `
        `
        -DANDROID_ABI="$archTarget" `
        -DANDROID_PLATFORM="$AndroidSystemVersion" `
        `
        -DLLVM_DIR="$fullLlvmDir" `
        -DUSE_LLVM_CONFIG="OFF" `
        `
        -DLIBFAUST_DIR="$targetFaustBuildDir/lib" `
        -DINCLUDE_DIR="$targetFaustBuildDir/include" `
        `
        -G "Ninja" `
        `
        "../../$RootSourcePath/tests/llvm-tests/"
    if (!$?) {
        Write-Output "Project Generation failed for Architecture : $archTarget !"
        Pop-Location
        exit 1
    }
    
    Write-Output "Building Faust for Architecture : $archTarget ..."
    . $AndroidCmake --build .
    if (!$?) {
        Write-Output "Compilation failed for Architecture : $archTarget !"
        Pop-Location
        exit 1
    }
    Pop-Location
    
    Write-Output "Successfully built Faust Tests for Architecture : $archTarget !"
}
Write-Output "Successfully built Faust Tests for Android!"
