# MSP Automated User Onboarding Script
# Purpose: Automate local user creation, group assignment, and logging for new clients.

# 1. Define paths and dummy data template
$LogFile = ".\C_OnboardingLog.txt"
$DummyUsers = @(
    [PSCustomObject]@{FirstName="John"; LastName="Doe"; Department="Helpdesk"; Title="Tier 1 Tech"}
    [PSCustomObject]@{FirstName="Jane"; LastName="Smith"; Department="Finance"; Title="Accountant"}
)

Write-Host "=== Starting MSP Automated Onboarding ===" -ForegroundColor Cyan

# 2. Loop through each user to process creation
foreach ($User in $DummyUsers) {
    $Username = ($User.FirstName[0] + $User.LastName).ToLower()
    $SecurePassword = ConvertTo-SecureString "MSP_Temp_2026!" -AsPlainText -Force
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    try {
        # Check if user already exists
        if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
            $Message = "[$Timestamp] SKIP: User $Username already exists."
            Write-Host $Message -ForegroundColor Yellow
            Add-Content -Path $LogFile -Value $Message
        } else {
            # Create the local user account
            New-LocalUser -Name $Username -Password $SecurePassword -FullName "$($User.FirstName) $($User.LastName)" -Description "$($User.Title) - $($User.Department)" -PasswordNeverExpires -ErrorAction Stop
            
            # (Optional) Attempt to assign to a standard local group
            # Standard local groups vary by OS language, so we catch errors safely
            try {
                Add-LocalGroupMember -Group "Users" -Member $Username -ErrorAction SilentlyContinue
            } catch {}

            $Message = "[$Timestamp] SUCCESS: Created account $Username for $($User.FirstName) $($User.LastName)."
            Write-Host $Message -ForegroundColor Green
            Add-Content -Path $LogFile -Value $Message
        }
    } catch {
        $Message = "[$Timestamp] ERROR: Failed to create user $Username. Reason: $_"
        Write-Host $Message -ForegroundColor Red
        Add-Content -Path $LogFile -Value $Message
    }
}

Write-Host "=== Onboarding Process Complete. Log written to $LogFile ===" -ForegroundColor Cyan
