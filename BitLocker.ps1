# Check if the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Restart the script with elevated privileges
    Write-Host "This script requires administrator privileges. Restarting as administrator..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
# Define the drive letter of the partition to encrypt
$DriveLetter = "E:"  # Replace with your partition drive letter

# Enable BitLocker on the drive
Enable-BitLocker -MountPoint $DriveLetter `
    -RecoveryPasswordProtector `
    -UsedSpaceOnly `
    -EncryptionMethod XtsAes256 `
    -Verbose


# Start the encryption process
Start-BitLocker -MountPoint $DriveLetter

Write-Host "BitLocker has been enabled on the drive $DriveLetter."
Write-Host "The recovery key has been saved to $RecoveryKeyPath."

# Define email settings
$SMTPServer = "XXXXXXXXXXX"
$SMTPPort = "XXXX"
$Username = "XXXXXXXXXXX"
$Password = "XXXXXXXXXX"
$To = "XXXXXXXXXXXXXX"
$From = "XXXXXXXXXXX"
$Subject = "BitLocker Recovery Key"
# Retrieve the BitLocker recovery key
$BitLockerKey = (Get-BitLockerVolume).KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' } | Select-Object -ExpandProperty RecoveryPassword
# Construct the email body
$Body = "BitLocker Recovery Key: $BitLockerKey"
# Send email
Send-MailMessage -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential (New-Object PSCredential($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))) -From $From -To $To -Subject $Subject -Body $Body
