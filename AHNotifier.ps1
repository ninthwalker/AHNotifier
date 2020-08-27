######################################################################
# Name: AHNotifier                                                   #
# Desc: Notifies you of prices for specific wow Auction House Items  #
# Author: Ninthwalker                                                #
# Instructions: https://github.com/ninthwalker/AHNotifier            #
# Date: 27AUG2020                                                    #
# Version: 1.2                                                       #
######################################################################

############################ CHANGE LOG ##############################
## 1.0                                                               #
# Initial App version only supports one server per script for now    #
## 1.1                                                               #
# Added Settings file instead of having to edit this script directly #
## 1.2                                                               #
# Added Windows Toast Notification Option                            #
######################################################################

### setup environment ###   

if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript") {
    $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
else {
    $ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
    if (!$ScriptPath) {
        $ScriptPath = "."
    }
}

# Set-Location $PSScriptRoot
Set-Location $ScriptPath

# Import settings
Function Get-Settings ([string]$fileName) {
       $ini = @{}
       switch -regex -file $fileName {
              "^\[(.+)\]$" {                # recognize a section
                     $section = $matches[1]
                     $ini[$section] = @{}
              }
              "^\s*([^#]+?)\s*=\s*(.*)" {   # recognize a property
                     $name,$value = $matches[1..2]
                     if (!(Test-path variable:\section)) {
                           $section = "-unknown-"
                           $ini[$section] = @{}
                     }
                     $ini[$section][$name] = $value.trim()
              }
       }
       $ini
} 

$settings = Get-Settings .\Settings.txt

### Server and TSM Settings ###
$region = $settings.'server settings'.region
$server = $settings.'server settings'.server
$apiKey = $settings.'server settings'.apikey

# notification types
if ($settings.'Notification Types'.Discord -eq "Enabled")  {$discord = $True}
if ($settings.'Notification Types'.Telegram -eq "Enabled") {$telegram = $True}
if ($settings.'Notification Types'.Pushover -eq "Enabled") {$pushover = $True}
if ($settings.'Notification Types'.TextMsg -eq "Enabled") {$textMsg = $True} 
if ($settings.'Notification Types'.Alexa -eq "Enabled") {$alexa = $True}
if ($settings.'Notification Types'.HASS -eq "Enabled") {$hass = $True}

### AUCTION HOUSE SETTINGS ###

$items = @()
$settings.GetEnumerator() | ForEach-Object { 
    
    if ($_.key -like "AHITem*") {

        $items += [PSCustomObject]@{
            Description = $settings[$_.key]['description']
            itemID      = $settings[$_.key]['itemID']
            price       = $settings[$_.key]['price']
            check       = $settings[$_.key]['check']
        }
    }
}

### Windows Toast Notification ###
function New-Toast {
$app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]

$Template = [Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText01

#Gets the Template XML so we can manipulate the values
[xml]$ToastTemplate = ([Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($Template).GetXml())

# wow AH Alert logo
$base64Img = "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"
If (!(Test-Path $env:TEMP\AHNotifier_ToastImg.png)) {
    $ImageFile = "$env:TEMP\AHNotifier_ToastImg.png"
    [byte[]]$Bytes = [convert]::FromBase64String($Base64Img)
    [System.IO.File]::WriteAllBytes($ImageFile,$Bytes)
}

$toast_msg = $msg.TrimStart("AH Alert: ")

[xml]$ToastTemplate = @"
<toast launch="app-defined-string">
  <visual>
    <binding template="ToastGeneric">
      <text>Auction House Alert</text>
      <text>$toast_msg</text>
      <image id="1" placement="appLogoOverride" hint-crop="circle" src="$img"/>
    </binding>
  </visual>
  <actions>
  </actions>
</toast>
"@

$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($ToastTemplate.OuterXml)

$notify = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app)
$notify.Show($ToastXml)
}

### NOTIFICATION SETTINGS ###

# Force tls1.2 - mainly for telegram since they recently changed this in FEB2020
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# If using text method, convert password into secure credential object
if ($textMsg) {
    [SecureString]$secureEmailPass = $settings.textmsg.emailPass | ConvertTo-SecureString -AsPlainText -Force 
    [PSCredential]$emailCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $settings.textmsg.emailUser, $secureEmailPass
}


# Notification Function
function AHNotifier {


    # msg Discord
    if ($discord) {

        $discordHeaders = @{
            "Content-Type" = "application/json"
        }

        $discordBody = @{
            content = $msg
        } | convertto-json

        Invoke-RestMethod -Uri $settings.discord.discordWebHook -Method POST -Headers $discordHeaders -Body $discordBody
    }

    # msg Telegram
    if ($telegram) {
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$($settings.telegram.telegramBotToken)/sendMessage?chat_id=$($settings.telegram.telegramChatID)&text=$($msg)"
    }
    
    # msg Pushover
    if ($pushover) {
        $data = @{
            token = $settings.pushover.pushoverAppToken
            user = $settings.pushover.pushoverUserToken
            message = $msg
        }
        
        if ($settings.pushover.device)   { $data.Add("device", $settings.pushover.device) }
        if ($settings.pushover.title)    { $data.Add("title", $settings.pushover.title) }
        if ($settings.pushover.priority) { $data.Add("priority", $settings.pushover.priority) }
        if ($settings.pushover.sound)    { $data.Add("sound", $settings.pushover.sound) }

        Invoke-RestMethod "https://api.pushover.net/1/messages.json" -Method POST -Body $data
    }
    
    # text Msg
    if ($textMsg) {
        Send-MailMessage -SmtpServer $settings.TextMsg.smtpServer -Port $settings.TextMsg.smtpPort -UseSsl -Priority High -from $settings.TextMsg.fromAddress -to $($settings.TextMsg.phoneNumber+$settings.TextMsg.CarrierEmail) -Subject "AH Alert" -Body $msg -Credential $emailCreds
    }
    
    # msg Alexa
    if ($alexa) {
        $alexaBody = @{
            notification = $msg
            accessCode = $settings.alexa.alexaAccessCode
        } | ConvertTo-Json

        Invoke-RestMethod https://api.notifymyecho.com/v1/NotifyMe -Method POST -Body $alexaBody
    }

    # msg HASS
    if ($HASS) {
    
        $hassHeaders = @{
            "Content-Type" = "application/json"
            "Authorization"= "Bearer $($settings.hass.hassToken)"
        }

        $hassBody = @{
            "entity_id" = $settings.hass.entityID
        } | convertto-json

        Invoke-RestMethod -Uri "$($settings.hass.hassURL)/api/services/script/toggle" -Method POST -Headers $hassHeaders -Body $hassBody
    }

    if ($toast) {
        New-Toast
    }

}

# Get AH Data for each item specified

$ahData = @()
foreach ($item in $items) {

$ahData += Invoke-RestMethod -Uri "https://api.tradeskillmaster.com/v1/item/$region/$server/$($item.itemID)?format=json&apiKey=$apiKey"

}

# Get current update time
$updatedAt = ((Get-Date 01.01.1970).AddSeconds($ahData[0].LastUpdated)).TolocalTime()

# init msg array
# Leave this for later to combine alerts maybe
# $msg = @()

# check items for price and create notification if threshold is met
foreach ($item in $items) {

    $details = $ahData | ? {$_.Id -eq $item.itemID}

    if ($details.Quantity -ge 1) {
        
        if ($item.check -eq "Above") {

            if ([int64]$details.MinBuyout -ge [int64]$item.price) {
                # send alert

                # maths
                if ( [int64]$details.MinBuyout -ge 10000) {
                    $minBuyout = "$($details.MinBuyout/10000)g" # gold
                }
                else {
                    $minBuyout = "$($details.MinBuyout/100)s" # silver
                }

                
                if ( [int64]$item.price -ge 10000) {
                    $setPrice = "$($item.price/10000)g" # gold
                }
                else {
                    $setPrice = "$($item.price/100)s" # silver
                }

                $msg = "AH Alert: $($details.name) is now $($minBuyout). This is above your price of $($setPrice). Updated: $($updatedAt)"
                
                # notify
                AHNotifier

            }
            else {
            # Don't send Alert
                #write-host "$($details.name) is NOT above your set price of $($item.price) - NO ALERT TRIGGERED" -ForegroundColor Red
            }
        }

        if ($item.check -eq "Below") {

            if ([int64]$details.MinBuyout -le [int64]$item.price) {
                # send alert
                # maths
                if ( [int64]$details.MinBuyout -ge 10000) {
                    $minBuyout = "$($details.MinBuyout/10000)g" # gold
                }
                else {
                    $minBuyout = "$($details.MinBuyout/100)s" # silver
                }

                
                if ( [int64]$item.price -ge 10000) {

                    $setPrice = "$($item.price/10000)g" # gold
                }
                else {
                    $setPrice = "$($item.price/100)s" # silver
                }

                $msg = "AH Alert: $($details.name) is now $($minBuyout). This is below your price of $($setPrice). Updated: $($updatedAt)"

                # notify
                AHNotifier

            }
            else {
                # Don't send alert
                    #write-host "$($details.name) is NOT below your set price of $($item.price) - NO ALERT TRIGGERED" -ForegroundColor Red
            }
        }

    }
    else {
        #write-host "Quantity available is less than 1" -ForegroundColor Red
    }

}
