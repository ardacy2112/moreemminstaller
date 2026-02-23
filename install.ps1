# ====== AYARLAR ======
$zipUrl = "https://github.com/ardacy2112/moreemminstaller/releases/download/v10.0.0.0/v10.2026.zip"
$dllUrl = "https://raw.githubusercontent.com/ardacy2112/moreemminstaller/main/xinput1_4.dll"

$downloads = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
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

# Turkce BUYUK İ karakteri
$TurkceI = [char]0x0130

Get-ChildItem $extractPath -Recurse -Filter "*.application" | ForEach-Object {
    $correctName = "Moreeemm ${TurkceI}nstaller v10 2026.application"
    $newPath = Join-Path $_.DirectoryName $correctName

    if ($_.FullName -ne $newPath) {
        Rename-Item $_.FullName $newPath -Force
    }
}


# ===== CLICKONCE APPLICATION FILES TURKCE İ FIX =====

$TurkceI = [char]0x0130
$appFilesPath = Join-Path $extractPath "Application Files"

if (Test-Path $appFilesPath) {
    Get-ChildItem $appFilesPath -Directory | ForEach-Object {

        # Hedef klasör adı (DOĞRU)
        $correctName = "Moreeemm ${TurkceI}nstaller v10 2026_10_0_0_0"
        $correctPath = Join-Path $appFilesPath $correctName

        if ($_.FullName -ne $correctPath) {
            Rename-Item $_.FullName $correctPath -Force
        }
    }
}


# ===== APPLICATION FILES / IC KLASOR DOSYA ADI TURKCE İ FIX =====

$TurkceI = [char]0x0130
$appFilesRoot = Join-Path $extractPath "Application Files"

# Moreeemm İnstaller ile başlayan klasörü bul
$targetFolder = Get-ChildItem $appFilesRoot -Directory |
    Where-Object { $_.Name -like "Moreeemm*2026_*" } |
    Select-Object -First 1

if ($targetFolder) {
    Get-ChildItem $targetFolder.FullName -File | ForEach-Object {

        if ($_.Name -match "Installer" -and $_.Name -notmatch $TurkceI) {

            $newName = $_.Name -replace "Installer", "${TurkceI}nstaller"
            $newPath = Join-Path $_.DirectoryName $newName

            Rename-Item $_.FullName $newPath -Force
        }
    }
}

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
