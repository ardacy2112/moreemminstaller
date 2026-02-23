# ====== AYARLAR ======
$zipUrl = "https://github.com/ardacy2112/moreemminstaller/releases/download/v10.0.0.0/v10.2026.zip"
$dllUrl = "https://raw.githubusercontent.com/ardacy2112/moreemminstaller/main/xinput1_4.dll"

$downloads = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
$zipPath = "$downloads\v10.2026.zip"
$extractPath = "$downloads\Moreemm v10.2026"

$steamGamePath = "C:\Program Files (x86)\Steam"

# =====================

# 7-Zip
$sevenZipExe = "C:\Program Files\7-Zip\7z.exe"
$sevenZipInstaller = "$env:TEMP\7zip.exe"
$sevenZipUrl = "https://www.7-zip.org/a/7z2301-x64.exe"

Write-Host "ZIP indiriliyor..."
Invoke-WebRequest $zipUrl -OutFile $zipPath

# 7-Zip yoksa indir
if (!(Test-Path $sevenZipExe)) {
    Write-Host "7-Zip bulunamadi, indiriliyor..."
    Invoke-WebRequest $sevenZipUrl -OutFile $sevenZipInstaller
    Start-Process $sevenZipInstaller -ArgumentList "/S" -Wait
}

if (!(Test-Path $sevenZipExe)) {
    Write-Error "7-Zip kurulumu basarisiz!"
    exit
}

# Klasör
if (!(Test-Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath | Out-Null
}

Write-Host "ZIP cikariliyor (ClickOnce uyumlu)..."
& "$sevenZipExe" x "$zipPath" "-o$extractPath" -y | Out-Null
Remove-Item $zipPath -Force

# SADECE setup.exe bul
$setupExe = Get-ChildItem $extractPath -Recurse -Filter setup.exe | Select-Object -First 1

if (!$setupExe) {
    Write-Error "setup.exe bulunamadi!"
    exit
}

Write-Host "setup.exe baslatiliyor..."
Start-Process $setupExe.FullName

Read-Host "Kurulum bittikten sonra ENTER'a basin"
Start-Process explorer.exe $extractPath

# ===== DLL =====
Write-Host "xinput1_4.dll indiriliyor..."
$tempDll = "$env:TEMP\xinput1_4.dll"
Invoke-WebRequest $dllUrl -OutFile $tempDll

if (Test-Path $steamGamePath) {
    Copy-Item $tempDll "$steamGamePath\xinput1_4.dll" -Force
    Write-Host "xinput1_4.dll kopyalandi"
} else {
    Write-Warning "Steam dizini bulunamadi"
}

Write-Host "ISLEM TAMAMLANDI."
