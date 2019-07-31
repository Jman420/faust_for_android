$ProjectDir = "build"
$BuildDir = "out"
$RootSourcePath = "jni"

$AndroidSystemVersion="21"
$AndroidSdkDir = "$env:LOCALAPPDATA/Android/Sdk"
$AndroidCmake = "$AndroidSdkDir/cmake/3.10.2.4988404/bin/cmake.exe"
$AndroidNinja = "$AndroidSdkDir/cmake/3.10.2.4988404/bin/ninja.exe"
$NdkBundle = "$AndroidSdkDir/ndk-bundle/"
$ToolchainFile = "$NdkBundle/build/cmake/android.toolchain.cmake"
$ToolchainBinsRoot = "$NdkBundle/toolchains"
$ArchTargets = @("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
$ArchToolchains = @("arm-linux-androideabi", "aarch64-linux-android", "x86", "x86_64" )
$ArchToolchainVersion = "4.9"

$LlvmAndroidBuildPath = "libs/llvm_for_android/android-build"

for ($archCounter = 0; $archCounter -lt $ArchTargets.Length; $archCounter++) {
    $archTarget = $ArchTargets[$archCounter]
    $toolchain = $ArchToolchains[$archCounter]

    $archProjectDir = "$ProjectDir/$archTarget"
    $archBuildDir = "$BuildDir/$archTarget"
    $fullLlvmDir = Resolve-Path "libs/llvm_for_android/android-build/$archTarget/lib/cmake/llvm"
    $archStrip = "$ToolchainBinsRoot/$toolchain-$ArchToolchainVersion/prebuilt/windows-x86_64/$toolchain/bin/strip.exe"
    
    Write-Output "Setting Up Build Environment for Architecture : $archTarget ..."
    if (Test-Path $archProjectDir) {
        Write-Output "Removing existing Build Directory for $archTarget..."
        Remove-Item $archProjectDir -Force -Recurse
    }
    if (Test-Path $archBuildDir) {
        Write-Output "Removing existing Output Directory for $archTarget..."
        Remove-Item $archBuildDir -Force -Recurse
    }
    
    Write-Output "Creating Build & Output Directory for $archTarget ..."
    New-Item -ItemType directory -Force -Path $archProjectDir
    New-Item -ItemType directory -Force -Path $archBuildDir
    $buildFullPath = Resolve-Path $archBuildDir
    
    Write-Output "Generating Project Files for Architecture : $archTarget ..."
    Push-Location $ProjectDir/$archTarget
    . $AndroidCmake `
        -DCMAKE_BUILD_TYPE="Release" `
        -DCMAKE_INSTALL_PREFIX="$buildFullPath" `
        -DCMAKE_TOOLCHAIN_FILE="$ToolchainFile" `
        -DCMAKE_MAKE_PROGRAM="$AndroidNinja" `
        `
        -DANDROID_ABI="$archTarget" `
        -DANDROID_PLATFORM="$AndroidSystemVersion" `
        `
        -DLLVM_DIR="$fullLlvmDir" `
        -DUSE_LLVM_CONFIG="OFF" `
        `
        -C../../backends.cmake `
        -C../../targets.cmake `
        `
        -G "Ninja" `
        `
        "../../$RootSourcePath/build/"
    if (!$?) {
        Write-Output "Project Generation failed for Architecture : $archTarget !"
        Pop-Location
        exit 1
    }
    
    Write-Output "Building Faust for Architecture : $archTarget ..."
    . $AndroidCmake --build . --target install
    if (!$?) {
        Write-Output "Compilation failed for Architecture : $archTarget !"
        Pop-Location
        exit 1
    }
    Pop-Location
    
    Write-Output "Stripping libfaust for Architecture : $archTarget ..."
    . $archStrip --strip-unneeded "$buildFullPath/lib/libfaust.so"
    if (!$?) {
        Write-Output "Stripping libfaust failed for Architecture : $archTarget !"
        exit 1
    }
    
    Write-Output "Successfully built Faust for Architecture : $archTarget !"
}
Write-Output "Successfully built Faust for Android!"
