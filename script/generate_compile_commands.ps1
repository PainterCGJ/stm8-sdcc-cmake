# 生成 compile_commands.json 的 PowerShell 脚本
# 用于 Ninja 生成器（Ninja 不会自动生成 compile_commands.json）

param(
    [string]$BuildDir = "build/stm8l-app",
    [string]$SourceDir = "source/app"
)

Write-Host "正在生成 compile_commands.json..." -ForegroundColor Green

# 检查构建目录是否存在
if (-not (Test-Path $BuildDir)) {
    Write-Host "错误: 构建目录不存在: $BuildDir" -ForegroundColor Red
    Write-Host "请先运行 CMake 配置" -ForegroundColor Yellow
    exit 1
}

# 切换到构建目录
Push-Location $BuildDir

try {
    # 方法1: 使用 CMake 3.20+ 的新功能（如果可用）
    $cmakeVersion = (cmake --version | Select-String -Pattern "version (\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value })
    $majorVersion = [int]($cmakeVersion.Split('.')[0])
    $minorVersion = [int]($cmakeVersion.Split('.')[1])
    
    if ($majorVersion -gt 3 -or ($majorVersion -eq 3 -and $minorVersion -ge 20)) {
        Write-Host "使用 CMake 3.20+ 方法生成 compile_commands.json..." -ForegroundColor Cyan
        cmake --build . --target $SourceDir 2>&1 | Out-Null
        # CMake 3.20+ 会在构建时自动生成 compile_commands.json
    }
    
    # 方法2: 手动创建 compile_commands.json（如果方法1失败）
    if (-not (Test-Path "compile_commands.json")) {
        Write-Host "使用备用方法生成 compile_commands.json..." -ForegroundColor Cyan
        
        # 获取源文件列表
        $sourceFiles = Get-ChildItem -Path "..\$SourceDir" -Filter "*.c" -Recurse | ForEach-Object { $_.FullName }
        
        if ($sourceFiles.Count -eq 0) {
            Write-Host "警告: 未找到源文件" -ForegroundColor Yellow
            exit 1
        }
        
        # 读取 CMakeCache.txt 获取配置信息
        $cacheFile = "CMakeCache.txt"
        if (-not (Test-Path $cacheFile)) {
            Write-Host "错误: 未找到 CMakeCache.txt" -ForegroundColor Red
            exit 1
        }
        
        # 解析包含目录和编译标志
        $includeDirs = @()
        $defines = @("-D__SDCC__", "-DSTM8L05X_MD_VL")
        $flags = @("-mstm8", "--std-c99")
        
        # 从 CMakeCache 读取信息（简化版本）
        # 实际应该解析 CMakeCache.txt，这里使用默认值
        
        # 构建 compile_commands.json
        $compileCommands = @()
        
        foreach ($file in $sourceFiles) {
            $relativePath = $file.Replace((Get-Location).Parent.FullName + "\", "").Replace("\", "/")
            $command = "sdcc -mstm8 --std-c99 -DSTM8L05X_MD_VL -D__SDCC__ -I../$SourceDir -I../../source/StdPeriph -I../../source/StdPeriph/STM8L15x-16x-05x/Libraries/STM8L15x_StdPeriph_Driver/inc -c `"$relativePath`""
            
            $compileCommands += @{
                directory = (Get-Location).Path
                command = $command
                file = $relativePath
            }
        }
        
        # 写入 JSON 文件
        $json = $compileCommands | ConvertTo-Json -Depth 10
        $json | Out-File -FilePath "compile_commands.json" -Encoding UTF8
        
        Write-Host "已生成 compile_commands.json" -ForegroundColor Green
    } else {
        Write-Host "compile_commands.json 已存在" -ForegroundColor Green
    }
    
    # 在工作区根目录创建符号链接（可选）
    $workspaceRoot = (Get-Location).Parent.Parent
    $linkPath = Join-Path $workspaceRoot "compile_commands.json"
    $targetPath = Join-Path (Get-Location) "compile_commands.json"
    
    if (Test-Path $targetPath) {
        if (Test-Path $linkPath) {
            Remove-Item $linkPath -Force
        }
        # Windows 需要管理员权限创建符号链接，使用复制代替
        Copy-Item $targetPath $linkPath -Force
        Write-Host "已在工作区根目录创建 compile_commands.json" -ForegroundColor Green
    }
    
} finally {
    Pop-Location
}

Write-Host "完成!" -ForegroundColor Green


