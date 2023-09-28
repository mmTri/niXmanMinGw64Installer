# $MinGw64Prefix = 'C:\' # こちらを有効にすれば、C:\mingw64にインストールされます
$MinGw64Prefix = 'C:\MinGw64Test' # テスト用
$MinGw64URL = 'https://github.com/niXman/mingw-builds-binaries/releases/download/13.1.0-rt_v11-rev1/x86_64-13.1.0-release-posix-seh-ucrt-rt_v11-rev1.7z'


# 7zipの実行ファイルを取得しカレントディレクトリに保存
function Get-7zip {
    Param(
        [string] $workDir
    )
    $url = 'https://www.7-zip.org/a/7zr.exe'
    $exe = '7zr.exe'
    $path = Join-Path $workDir $exe
    Write-Host "Downloading $url to $path"
    if (-not (Test-Path $path)) {
        Invoke-WebRequest $url -OutFile $path
    }
    return $path
}

# 
function Get-MinGw64 {
    Param(
        [string] $workDir,
        [string] $url = $MinGw64URL
    )
    $file = 'mingw64.7z'
    $path = Join-Path $workDir $file
    Write-Host "Downloading $url to $path"
    if (-not (Test-Path $path)) {
        Invoke-WebRequest $url -OutFile $path
    }
    return $path
}

function getAndInstall {
    # 一時ディレクトリを作成
    $tempDir = New-TemporaryFile | %{ rm $_; mkdir $_ }

    # 7zipとmingwを取得
    $7zip = Get-7zip $tempDir
    $mingw = Get-MinGw64 $tempDir $MinGw64URL

    # 7zipの引数を作成
    $7zipArgs = @(
        'x'
        '-y'
        '-o' + $MinGw64Prefix
        $mingw
    )
    # 7zipを実行
    Start-Process $7zip -ArgumentList $7zipArgs -Wait

    # mingwのシンボリックリンクを作成(あどみんのみ)
    #new-item -ItemType SymbolicLink -Path $MinGw64Prefix\mingw -Target $MinGw64Prefix\mingw64


    # 一時ディレクトリを削除
    $tempDir | ? { Test-Path $_ } | % { ls $_ -File -Recurse | rm; $_} | rmdir -Recurse
}

getAndInstall
