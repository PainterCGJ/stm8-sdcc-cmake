# Fix clangd configuration script
# Generate compile_commands.json and configure clangd

Write-Host "=== Fixing clangd configuration ===" -ForegroundColor Cyan

# 1. Reconfigure CMake
Write-Host "`n1. Reconfiguring CMake..." -ForegroundColor Yellow
$preset = "stm8l-app"
cmake --preset $preset

if ($LASTEXITCODE -ne 0) {
    Write-Host "CMake configuration failed!" -ForegroundColor Red
    exit 1
}

# 2. Check and generate compile_commands.json
Write-Host "`n2. Checking compile_commands.json..." -ForegroundColor Yellow
$buildDir = "build\stm8l-app"
$compileCommandsPath = Join-Path $buildDir "compile_commands.json"

if (-not (Test-Path $compileCommandsPath)) {
    Write-Host "compile_commands.json does not exist, generating..." -ForegroundColor Yellow
    
    # For Ninja generator, we need to manually generate
    $ninjaFile = Join-Path $buildDir "build.ninja"
    
    if (Test-Path $ninjaFile) {
        Write-Host "Extracting compile commands from build.ninja..." -ForegroundColor Cyan
        
        $compileCommands = @()
        
        # Find source files
        $sourceFiles = Get-ChildItem -Path "source/app" -Filter "*.c" -Recurse
        
        foreach ($file in $sourceFiles) {
            $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "").Replace("\", "/")
            $absolutePath = $file.FullName.Replace("\", "/")
            
            # Build compile command (based on project configuration)
            # Escape quotes in JSON string
            $escapedPath = $absolutePath.Replace('\', '\\').Replace('"', '\"')
            $command = "sdcc -mstm8 --std-c99 -DSTM8L05X_MD_VL -D__SDCC__ " +
                      "-Isource/app " +
                      "-Isource/StdPeriph " +
                      "-Isource/StdPeriph/STM8L15x-16x-05x/Libraries/STM8L15x_StdPeriph_Driver/inc " +
                      "-c `"$escapedPath`""
            
            # Use workspace root as directory so relative include paths work correctly
            $workspaceRoot = (Get-Location).Path.Replace("\", "/")
            $compileCommands += @{
                directory = $workspaceRoot
                command = $command
                file = $absolutePath
            }
        }
        
        # Write JSON (must be an array)
        # Manually construct JSON to ensure proper escaping
        $jsonLines = @()
        $jsonLines += "["
        for ($i = 0; $i -lt $compileCommands.Count; $i++) {
            $cmd = $compileCommands[$i]
            
            # Normalize paths (use forward slashes)
            $dir = $cmd.directory.Replace('\', '/')
            $file = $cmd.file.Replace('\', '/')
            
            # Escape command string properly for JSON
            # Replace backslashes with forward slashes first, then escape quotes
            $cmdStr = $cmd.command.Replace('\', '/')
            # Escape quotes: " becomes \"
            $cmdStr = $cmdStr.Replace('"', '\"')
            
            $jsonLines += "  {"
            $jsonLines += "    `"directory`": `"$dir`","
            $jsonLines += "    `"command`": `"$cmdStr`","
            $jsonLines += "    `"file`": `"$file`""
            if ($i -lt $compileCommands.Count - 1) {
                $jsonLines += "  },"
            } else {
                $jsonLines += "  }"
            }
        }
        $jsonLines += "]"
        $jsonLines -join "`n" | Out-File -FilePath $compileCommandsPath -Encoding UTF8 -NoNewline
        
        Write-Host "Generated compile_commands.json" -ForegroundColor Green
    } else {
        Write-Host "Warning: build.ninja not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "compile_commands.json already exists" -ForegroundColor Green
}

# 3. Create symlink in workspace root
Write-Host "`n3. Creating compile_commands.json in workspace root..." -ForegroundColor Yellow
$workspaceLink = "compile_commands.json"

if (Test-Path $compileCommandsPath) {
    Copy-Item $compileCommandsPath $workspaceLink -Force
    Write-Host "Created compile_commands.json in workspace root" -ForegroundColor Green
}

# 4. Verify configuration
Write-Host "`n4. Verifying configuration..." -ForegroundColor Yellow
if (Test-Path $compileCommandsPath) {
    $content = Get-Content $compileCommandsPath -Raw
    if ($content -match '\[.*\]') {
        Write-Host "compile_commands.json format is correct" -ForegroundColor Green
    } else {
        Write-Host "compile_commands.json format may have issues" -ForegroundColor Yellow
    }
} else {
    Write-Host "compile_commands.json not found" -ForegroundColor Red
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host "`nTips:" -ForegroundColor Yellow
Write-Host "1. Restart VSCode or restart clangd server (Ctrl+Shift+P -> clangd: Restart language server)" -ForegroundColor White
Write-Host "2. If still cannot jump to headers, check include paths in .clangd configuration file" -ForegroundColor White
