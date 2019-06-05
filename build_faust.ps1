$BuildDir = "build"
$OutputDir = "out"
$RootSourcePath = "./jni"

$AndroidSdkDir = "Android/Sdk"
$AndroidCmakeExe = "$AndroidSdkDir/cmake/3.6.4111459/bin/cmake.exe"
$AndroidNinjaExe = "$AndroidSdkDir/cmake/3.6.4111459/bin/ninja.exe"
$NdkBundle = "$AndroidSdkDir/ndk-bundle/"
$ToolchainFile = "$NdkBundle/build/cmake/android.toolchain.cmake"
$ArchTargets = @("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
$LibraryFilePattern = "*.so"

$IncludeFileSource = "$RootSourcePath/architecture/faust/dsp/llvm-dsp.h"
$IncludeFileDest = "./$OutputDir/include/llvm-dsp.h"

foreach ($archTarget in $ArchTargets) {
    # Remove build & output directories
    if (Test-Path $BuildDir/$archTarget) {
        Write-Output "Removing existing Build Directory for $archTarget..."
        Remove-Item $BuildDir/$archTarget -Force -Recurse
    }
    if (Test-Path $OutputDir/$archTarget) {
        Write-Output "Removing existing Output Directory for $archTarget..."
        Remove-Item $OutputDir/$archTarget -Force -Recurse
    }

    # Make Target Output Directory
    Write-Output "Creating Build & Output Directory for $archTarget ..."
    New-Item -ItemType directory -Force -Path $BuildDir/$archTarget
    New-Item -ItemType directory -Force -Path $OutputDir/$archTarget
    $fullOutputPath = Resolve-Path $OutputDir/$archTarget
    
    Write-Output "Building Faust for Android - $archTarget ..."
    Push-Location $BuildDir/$archTarget
    . $env:LOCALAPPDATA\$AndroidCmakeExe `
        -C../../backends.cmake `
        -C../../targets.cmake `
        -DANDROID_NDK="$env:LOCALAPPDATA/$NdkBundle" `
        -DCMAKE_TOOLCHAIN_FILE="$env:LOCALAPPDATA/$ToolchainFile" `
        -DCMAKE_MAKE_PROGRAM="$env:LOCALAPPDATA/$AndroidNinjaExe" `
        -DCMAKE_CXX_FLAGS=-std=c++14 `
        -DANDROID_STL=c++_shared `
        -DANDROID_ABI="$archTarget" `
        -DANDROID_LINKER_FLAGS="-landroid -llog" `
        -DANDROID_CPP_FEATURES="rtti exceptions" `
        -G "Android Gradle - Ninja" `
        ../../jni/build/
    
    . $env:LOCALAPPDATA\$AndroidCmakeExe --build .
    Write-Output "Successfully built Faust for Android - $archTarget !"
    
    Write-Output "Copying $archTarget binaries to Output Directory..."
    $libraryFiles = (Get-ChildItem -Path $LibraryFilePattern -Recurse).FullName | Resolve-Path -Relative
    foreach ($libFile in $libraryFiles) {
        $libFileDest = "$fullOutputPath/" + $libFile.Replace(".\", "").Replace("\", "/")
        Write-Output "Copying $libFile to $libFileDest ..."
        New-Item -Force $libFileDest
        Copy-Item -Force $libFile -Destination $libFileDest
    }
    Pop-Location
}
Write-Output "Successfully built Faust for Android!"

# Remove Include output directory
if (Test-Path $IncludeDir) {
    Write-Output "Removing existing Output Include directory..."
    Remove-Item $IncludeDir -Force -Recurse
}

# Make the Include output directory
Write-Output "Creating output Include directory..."
New-Item -ItemType directory -Force -Path $IncludeDir
$includeFileDest = Resolve-Path $IncludeDir

# Copy Headers to Include Directory
Write-Output "Copying Include File to $IncludeFileDest ..."
New-Item -Force $IncludeFileDest
Copy-Item -Force $IncludeFileSource -Destination $IncludeFileDest
Write-Output "Successfully copied Faust Include File to $IncludeFileDest !"
