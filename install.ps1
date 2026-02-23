# ====== AYARLAR ======
$zipUrl = "github.com/ardacy2112/moreemminstaller/releases/download/v10.0.0.0/v10.2026.zip"
$dllUrl = "https://raw.githubusercontent.com/ardacy2112/moreemminstaller/main/xinput1_4.dll"

$downloads = [Environment]::GetFolderPath("Downloads")
$zipPath = "$downloads\v10.2026.zip"
$extractPath = "$downloads\Moreemm v10.2026"

# Steam oyun dizini (GEREKİRSE DEĞİŞTİR)
$steamGamePath = "C:\Program Files (x86)\Steam"

# =====================

Write-Host "Uygulama indiriliyor..."

# ZIP indir
Invoke-WebRequest $zipUrl -OutFile $zipPath

# Klasör yoksa oluştur
if (!(Test-Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath | Out-Null
}

Write-Host "ZIP cikariliyor..."
Expand-Archive $zipPath -DestinationPath $extractPath -Force

# ZIP sil
Remove-Item $zipPath -Force

# setup.exe bul
$setupExe = Get-ChildItem $extractPath -Recurse -Filter setup.exe | Select-Object -First 1

if (!$setupExe) {
    Write-Error "setup.exe bulunamadi!"
    exit
}

Write-Host "Kurulum baslatiliyor..."
Start-Process $setupExe.FullName

# Kullanici kurulumu yapsin diye bekle
Read-Host "Kurulum bittikten sonra ENTER'a basin"

# Kurulum klasörünü aç
Start-Process explorer.exe $extractPath

# ================= DLL =================
Write-Host "xinput1_4.dll indiriliyor..."

$tempDll = "$env:TEMP\xinput1_4.dll"
Invoke-WebRequest $dllUrl -OutFile $tempDll

if (!(Test-Path $steamGamePath)) {
    Write-Warning "Steam oyun dizini bulunamadi, DLL kopyalanamadi!"
} else {
    Copy-Item $tempDll "$steamGamePath\xinput1_4.dll" -Force
    Write-Host "xinput1_4.dll basariyla kopyalandi"
}

Write-Host "Islem tamamlandi."
