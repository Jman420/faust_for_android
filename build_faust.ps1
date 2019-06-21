$ProjectDir = "build"
$BuildDir = "out"
$RootSourcePath = "./jni"

$AndroidSdkDir = "Android/Sdk"
$AndroidCmakeExe = "$AndroidSdkDir/cmake/3.6.4111459/bin/cmake.exe"
$AndroidNinjaExe = "$AndroidSdkDir/cmake/3.10.2.4988404/bin/ninja.exe"
$NdkBundle = "$AndroidSdkDir/ndk-bundle/"
$ToolchainFile = "$NdkBundle/build/cmake/android.toolchain.cmake"
$ArchTargets = @("armeabi-v7a") #, "arm64-v8a", "x86", "x86_64")

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
    . $env:LOCALAPPDATA\$AndroidCmakeExe `
        -C../../backends.cmake `
        -C../../targets.cmake `
        `
        -DLLVM_DIR="$fullLlvmDir" `
        -DUSE_LLVM_CONFIG="OFF" `
        `
        -DANDROID_NDK="$env:LOCALAPPDATA/$NdkBundle" `
        -DANDROID_STL="c++_shared" `
        -DANDROID_ABI="$archTarget" `
        -DANDROID_LINKER_FLAGS="-landroid -llog" `
        -DANDROID_CPP_FEATURES="rtti exceptions" `
        `
        -DCMAKE_INSTALL_PREFIX="$fullArchBuildPath" `
        -DCMAKE_TOOLCHAIN_FILE="$env:LOCALAPPDATA/$ToolchainFile" `
        -DCMAKE_MAKE_PROGRAM="$env:LOCALAPPDATA/$AndroidNinjaExe" `
        -DCMAKE_CXX_FLAGS="-std=c++14" `
        `
        -G "Android Gradle - Ninja" `
        ../../jni/build/
    
    Write-Output "Building LLVM for Architecture : $archTarget ..."
    . $env:LOCALAPPDATA\$AndroidCmakeExe --build . --target install
    
    Pop-Location
    Write-Output "Successfully built LLVM for Architecture : $archTarget !"
}
Write-Output "Successfully built Faust for Android!"
