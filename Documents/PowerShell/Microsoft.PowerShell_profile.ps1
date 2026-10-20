# ============================================
# Personal PowerShell Profile
# Linux-style workflow for Security / Dev
# ============================================
# ============================================
# Environment
# ============================================
$env:EDITOR = "vim"
# UTF-8
$env:LANG = "en_US.UTF-8"
# Less / more friendly pager
if (Get-Command less -ErrorAction SilentlyContinue) {
    $env:PAGER = "less"
}
# ============================================
# Starship Prompt
# ============================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
# ============================================
# zoxide
# ============================================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { zoxide init powershell | Out-String })
}
# ============================================
# Terminal Icons
# ============================================
if (Get-Module -ListAvailable Terminal-Icons) {
    Import-Module Terminal-Icons
}
# ============================================
# PSReadLine
# ============================================
Import-Module PSReadLine
Set-PSReadLineOption `
    -EditMode Windows `
    -HistoryNoDuplicates `
    -PredictionSource History `
    -PredictionViewStyle ListView `
    -BellStyle None `
    -MaximumHistoryCount 10000
# History search
Set-PSReadLineKeyHandler -Chord UpArrow `
    -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord DownArrow `
    -Function HistorySearchForward
# Linux / Bash style
Set-PSReadLineKeyHandler -Chord Ctrl+a `
    -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+e `
    -Function EndOfLine
Set-PSReadLineKeyHandler -Chord Ctrl+l `
    -Function ClearScreen
Set-PSReadLineKeyHandler -Chord Ctrl+w `
    -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord Alt+d `
    -Function ShellKillWord
# Undo / Redo
Set-PSReadLineKeyHandler -Chord Ctrl+z `
    -Function Undo
Set-PSReadLineKeyHandler -Chord Ctrl+y `
    -Function Redo
# Ctrl+D = EOF / exit
Set-PSReadLineKeyHandler -Chord Ctrl+d `
    -Function ViExit
# ============================================
# fzf
# ============================================
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # fzf default appearance
    $env:FZF_DEFAULT_OPTS = @"
--height 40%
--layout=reverse
--border
--info=inline
--bind=ctrl-j:down,ctrl-k:up
"@
    # fzf + bat preview
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        $env:FZF_CTRL_T_OPTS = @"
--preview 'bat --style=numbers --color=always --line-range :80 {}'
--preview-window 'right:60%'
"@
    }
    # ============================================
    # Ctrl+R = fzf history search
    # ============================================
    Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock {
        $command = Get-Content (Get-PSReadLineOption).HistorySavePath |
            Select-Object -Unique |
            fzf --tac --no-sort

        if ($command) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
        }
    }

    # ============================================
    # Ctrl+T = fzf file search (all files)
    # ============================================
    Set-PSReadLineKeyHandler -Chord Ctrl+t -ScriptBlock {
        $file = fd --type f --hidden --no-ignore 2>$null |
            fzf

        if ($file) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert(
                ('"{0}"' -f $file)
            )
        }
    }

    # ============================================
    # Ctrl+F = fzf file search (normal files)
    # ============================================
    Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock {
        $file = fd --type f 2>$null |
            fzf

        if ($file) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert(
                ('"{0}"' -f $file)
            )
        }
    }
}
# ============================================
# eza
# ============================================
if (Get-Command eza -ErrorAction SilentlyContinue) {
    if (Test-Path alias:ls) {
        Remove-Item alias:ls -Force -ErrorAction SilentlyContinue
    }
    function ls {
        eza -G --icons $args
    }
    function ll {
        eza -lh --icons --git $args
    }
    function la {
        eza -lah --icons --git $args
    }
    function tree {
        eza --tree --icons $args
    }
    function lt {
        eza --tree --level=2 --icons $args
    }
}
# ============================================
# bat
# ============================================
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat {
        bat --style=header,grid,numbers @args
    }
    function ccat {
        bat --style=plain @args
    }
}
# ============================================
# fd / rg
# ============================================
if (Get-Command fd -ErrorAction SilentlyContinue) {
    function ff {
        fd @args
    }
    function ffile {
        fd --type f @args
    }
    function fdir {
        fd --type d @args
    }
}
if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep {
        rg @args
    }
    function rgi {
        rg -i @args
    }
    function rgf {
        rg --files | rg @args
    }
}
# ============================================
# yazi
# ============================================
if (Get-Command yazi -ErrorAction SilentlyContinue) {
    function y {
        $tmp = [System.IO.Path]::GetTempFileName()
        try {
            yazi @args --cwd-file="$tmp"
            if (Test-Path $tmp) {
                $cwd = Get-Content $tmp
                if ($cwd -and ($cwd -ne (Get-Location).Path)) {
                    Set-Location $cwd
                }
            }
        }
        finally {
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        }
    }
}
# ============================================
# Basic Unix-like commands
# ============================================
function which {
    param([string]$Command)
    Get-Command $Command |
        Select-Object -ExpandProperty Source
}
function whereis {
    param([string]$Command)
    Get-Command $Command -All
}
function touch {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    }
    else {
        New-Item -ItemType File -Path $Path | Out-Null
    }
}
function mkcd {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}
function .. {
    Set-Location ..
}
function ... {
    Set-Location ../..
}
function .... {
    Set-Location ../../..
}
# ============================================
# Open / Explorer
# ============================================
function open {
    param([string]$Path = ".")
    Start-Process $Path
}
function copen {
    explorer.exe .
}
# ============================================
# Git shortcuts
# ============================================
function gs {
    git status
}
function ga {
    git add @args
}
function gc {
    git commit @args
}
function gp {
    git push @args
}
function gl {
    git log --oneline --graph --decorate --all @args
}
function gd {
    git diff @args
}
function gco {
    git checkout @args
}
function gsw {
    git switch @args
}
# ============================================
# Security / Network helpers
# ============================================
function ports {
    Get-NetTCPConnection |
        Sort-Object LocalPort |
        Select-Object `
            LocalAddress,
            LocalPort,
            RemoteAddress,
            RemotePort,
            State,
            OwningProcess
}
function listening {
    Get-NetTCPConnection -State Listen |
        Sort-Object LocalPort |
        Select-Object `
            LocalAddress,
            LocalPort,
            OwningProcess
}
function ip {
    Get-NetIPAddress |
        Where-Object AddressFamily -eq IPv4 |
        Select-Object InterfaceAlias,
                      IPAddress,
                      PrefixLength
}
function dns {
    Get-DnsClientServerAddress |
        Select-Object InterfaceAlias,
                      ServerAddresses
}
function route {
    Get-NetRoute -AddressFamily IPv4 |
        Sort-Object RouteMetric |
        Select-Object DestinationPrefix,
                      NextHop,
                      InterfaceAlias,
                      RouteMetric
}
# ============================================
# Process helpers
# ============================================
function psg {
    param([string]$Name)
    Get-Process |
        Where-Object ProcessName -like "*$Name*" |
        Sort-Object CPU -Descending |
        Select-Object ProcessName,
                      Id,
                      CPU,
                      WorkingSet
}
function killp {
    param(
        [Parameter(Mandatory)]
        [int]$Id
    )
    Stop-Process -Id $Id
}
# ============================================
# PowerShell helpers
# ============================================
function reload {
    . $PROFILE
}
function c {
    Clear-Host
}
function h {
    Get-History
}
function now {
    Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}
# ============================================
# Proxy
# ============================================
function proxyon {
    $proxy = "http://127.0.0.1:7890"
    $env:HTTP_PROXY  = $proxy
    $env:HTTPS_PROXY = $proxy
    $env:ALL_PROXY   = $proxy
    Write-Host "Proxy: ON  -> $proxy" -ForegroundColor Green
}
function proxyoff {
    Remove-Item Env:HTTP_PROXY  -ErrorAction SilentlyContinue
    Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:ALL_PROXY   -ErrorAction SilentlyContinue
    Write-Host "Proxy: OFF" -ForegroundColor Yellow
}
function proxystatus {
    [PSCustomObject]@{
        HTTP_PROXY  = $env:HTTP_PROXY
        HTTPS_PROXY = $env:HTTPS_PROXY
        ALL_PROXY   = $env:ALL_PROXY
    }
}

# ============================================
# Developer helpers
# ============================================
function serve {
    param(
        [int]$Port = 8000
    )
    if (Get-Command python -ErrorAction SilentlyContinue) {
        python -m http.server $Port
    }
    elseif (Get-Command py -ErrorAction SilentlyContinue) {
        py -m http.server $Port
    }
    else {
        Write-Host "Python not found." -ForegroundColor Red
    }
}
# ============================================
# Environment diagnostics
# ============================================
function tools {
    $commands = @(
        "git",
        "fzf",
        "eza",
        "bat",
        "fd",
        "rg",
        "zoxide",
        "yazi",
        "starship",
        "vim",
        "python",
        "uv"
    )
    foreach ($cmd in $commands) {
        $found = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($found) {
            Write-Host ("[OK]   {0,-10} {1}" -f $cmd, $found.Source) `
                -ForegroundColor Green
        }
        else {
            Write-Host ("[MISS] {0,-10}" -f $cmd) `
                -ForegroundColor DarkGray
        }
    }
}
# ============================================
# Startup
# ============================================
# 不建议每次启动打印大量信息。
# 如果需要可以取消下面注释。
#
# Write-Host ""
# Write-Host "PowerShell Ready 🚀" -ForegroundColor Cyan
# Write-Host ""