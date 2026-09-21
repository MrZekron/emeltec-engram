# Emeltec Engram — instalador automático para Claude Desktop (Windows)
# Ejecutar en PowerShell normal (no hace falta admin)

$ErrorActionPreference = "Stop"

$binDir = "$env:USERPROFILE\bin"
$exePath = "$binDir\engram.exe"
$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"

Write-Host "1/4 - Descargando engram.exe..."
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
Invoke-WebRequest -Uri "https://github.com/MrZekron/emeltec-engram/releases/download/emeltec-windows-v1/engram.exe" -OutFile $exePath

Write-Host "2/4 - Agregando $binDir al PATH..."
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$binDir;$userPath", "User")
}

Write-Host "3/4 - Configurando claude_desktop_config.json..."
New-Item -ItemType Directory -Force -Path (Split-Path $configPath) | Out-Null
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
} else {
    $config = [PSCustomObject]@{}
}
if (-not ($config.PSObject.Properties.Name -contains "mcpServers")) {
    $config | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value ([PSCustomObject]@{})
}
$engramEntry = [PSCustomObject]@{
    command = $exePath
    args    = @("mcp", "--tools=agent")
}
if ($config.mcpServers.PSObject.Properties.Name -contains "engram") {
    $config.mcpServers.engram = $engramEntry
} else {
    $config.mcpServers | Add-Member -MemberType NoteProperty -Name "engram" -Value $engramEntry
}
$config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8

Write-Host "4/4 - Cerrando Claude Desktop (si esta abierto)..."
Get-Process "Claude" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host ""
Write-Host "Listo. Pasos manuales que quedan:"
Write-Host "1. Abrir Claude Desktop de nuevo"
Write-Host "2. Settings -> Developer -> verificar que 'engram' aparezca conectado"
Write-Host "3. Settings -> Profile -> Custom Instructions -> pegar el bloque de texto del protocolo Emeltec"
