######################################################################
# Name: AHNotifier                                                   #
# Desc: Notifies you of prices for specific wow Auction House Items  #
# Author: Ninthwalker                                                #
# Instructions: https://github.com/ninthwalker/AHNotifier            #
# Date: 25AUG2020                                                    #
# Version: 1.1                                                       #
######################################################################

############################ CHANGE LOG ##############################
## 1.0                                                               #
# Initial App version only supports one server per script for now    #
## 1.1                                                               #
# Added Settings file instead of having to edit this script directly #
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

$settings = Get-Settings .\settings.txt

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
                write-host "$($details.name) is NOT above your set price of $($item.price) - NO ALERT TRIGGERED" -ForegroundColor Red
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
                    write-host "$item.price"
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
                write-host "$($details.name) is NOT below your set price of $($item.price) - NO ALERT TRIGGERED" -ForegroundColor Red
            }
        }

    }
    else {
        write-host "Quantity available is less than 1" -ForegroundColor Red
    }

}
