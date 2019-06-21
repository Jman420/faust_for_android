$ProjectDir = "build"
$BuildDir = "out"
$RootSourcePath = "jni"

$AndroidSystemVersion="21"
$AndroidSdkDir = "$env:LOCALAPPDATA/Android/Sdk"
$AndroidCmakeExe = "$AndroidSdkDir/cmake/3.10.2.4988404/bin/cmake.exe"
$AndroidNinjaExe = "$AndroidSdkDir/cmake/3.10.2.4988404/bin/ninja.exe"
$NdkBundle = "$AndroidSdkDir/ndk-bundle/"
$ToolchainFile = "$NdkBundle/build/cmake/android.toolchain.cmake"
$ArchTargets = @("armeabi-v7a", "arm64-v8a", "x86", "x86_64")

foreach ($archTarget in $ArchTargets) {
    # Remove build & output directories
    $archProjectDir = "$ProjectDir/$archTarget"
    $archBuildDir = "$BuildDir/$archTarget"
    if (Test-Path $archProjectDir) {
        Write-Output "Removing existing Build Directory for $archTarget..."
        Remove-Item $archProjectDir -Force -Recurse
    }
    if (Test-Path $archBuildDir) {
        Write-Output "Removing existing Output Directory for $archTarget..."
        Remove-Item $archBuildDir -Force -Recurse
    }
    
    # Make Target Output Directory
    Write-Output "Creating Build & Output Directory for $archTarget ..."
    New-Item -ItemType directory -Force -Path $archProjectDir
    New-Item -ItemType directory -Force -Path $archBuildDir
    $fullArchBuildPath = Resolve-Path $archBuildDir
    $fullLlvmDir = Resolve-Path "llvm_for_android/android-build/$archTarget/lib/cmake/llvm"
    
    Write-Output "Generating Project Files for Architecture : $archTarget ..."
    Push-Location $ProjectDir/$archTarget
    . $AndroidCmakeExe `
        -C../../backends.cmake `
        -C../../targets.cmake `
        `
        -DLLVM_DIR="$fullLlvmDir" `
        -DUSE_LLVM_CONFIG="OFF" `
        `
        -DANDROID_NDK="$NdkBundle" `
        -DANDROID_ABI="$archTarget" `
        `
        -DCMAKE_BUILD_TYPE="MinSizeRel" `
        -DCMAKE_INSTALL_PREFIX="$fullArchBuildPath" `
        -DCMAKE_SYSTEM_NAME="Android" `
        -DANDROID_PLATFORM="android-$AndroidSystemVersion" `
        -DCMAKE_SYSTEM_VERSION="$AndroidSystemVersion" `
        -DCMAKE_TOOLCHAIN_FILE="$ToolchainFile" `
        -DCMAKE_MAKE_PROGRAM="$AndroidNinjaExe" `
        `
        -G "Ninja" `
        "../../$RootSourcePath/build/"
    
    Write-Output "Building LLVM for Architecture : $archTarget ..."
    . $AndroidCmakeExe --build . --target install
    
    Pop-Location
    Write-Output "Successfully built LLVM for Architecture : $archTarget !"
}
Write-Output "Successfully built Faust for Android!"
