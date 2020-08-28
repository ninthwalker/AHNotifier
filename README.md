<p align="center">
<img align="center" src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/ahnotifier-logo.png" width="250"></p>  
<img src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/discord-alert.png">  
<img src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/windows_toast.png" width="250">  
Notifies you of prices for specific WoW Auction House Items.  
Currently supports Discord, Telegram, Pushover, Text Messages, Alexa 'Notify Me' Skill, Windows Toast Notifications and Home Assistant scripts. If you want another notification type, let me know.    
  

## Details/Requirements  
1. Windows 10 (Computer does need to be on or scheduled to wake to run the script)
2. Powershell 3.0+ (Comes with WIN10)
3. A TSM API Key (get from [here](https://www.tradeskillmaster.com/user))  
4. Discord, Telegram, Pushover, Cell Phone, or Alexa Device.

## How it works  
Enter in your Realm/TSM API Info and the Auction House items you would like to be notified on in the settings.txt file.  
Run the Script as a scheduled task in Windows and be alerted via one of the notification types when your price is matched.  

## Overview of Setup steps  
1. Download these 3 files and place them in the same folder/directory on your computer:  
* AHNotifier.ps1  
* AHNotifier_Task.vbs
* settings.txt    
3. Configure the settings.txt file per the instructions below.  
4. Schedule the script to run via a scheduled task on your computer per the instructions below.  
  
## Settings.txt file setup  
Please see the settings.sample file for detailed info on the sections.  
Overview of settings.txt sections:  

* **[Server Settings]**  
Enter your Region (ie: US or  EU)  
Enter your Server Name  
Enter your TSM API Key from [here](https://www.tradeskillmaster.com/user)    
BulkMode: If Checkng on a lot of AH items (Like More than 25-50), then set this to Enabled and only run the script at most once per hour to avoid API rate limits.  

* **[Notification Types]**  
Set to 'Disabled' or 'Enabled' for the types you want to use.  
You can pick which ones you want Enabled or Disabled.   

* **[Notification Settings]**  
For each Notification type that you set to 'Enabled' in the above section, create a corresponding section here for it.  
See the setttings.sample for details of how this should look. 

* **[Toast]**  
Set to Enabled to show the Windows Toast Notifications. No further configuration is necessary.
If you do not have notifcations on windows enabled, you can turn them on under `Settings > System > Notifications & actions`

* **Discord**  
Enter in the discord webhook for the channel you would like the notification to go to.  
Discord > Click cogwheel next to a channel to edit it > Webhooks > Create webhook.
See this quick video I found on Youtube if you need further help. It's very easy. Do not share this Webhook with anyone else.  
[Create Discord Webhook](https://www.youtube.com/watch?v=zxi926qhP7w)  

* **Pushover**   
Log in and create a new application in your Pushover.net account.  
Copy the User API Key and the newly created Application API Key to the Pushover variables.  
Set the optional commented out settings if desired.     

* **Telegram**  
This can be a little more complicated to set up, but you can look online for further help. The basics are below but I didn't go into detail:  
Get the Token by creating a bot by messaging @BotFather  
Get the ChatID by messaging your bot you created, or making your own group with the bot and messaging the group. Then get the ChatID for that conversation with the below step.  
Go to this url replacing [telegramBotToken] with your own Bot's token and look for the chatID to use. 
https://api.telegram.org/bot[telegramBotToken]/getUpdates

* **Text Message**  
Note: I didn't want to code in all the carriers and all the emails. So only Gmail is fully supported for now. If using 2FA, make a google app password from here: https://myaccount.google.com/security.  
Feel free to do a pull request to add more if it doesn't work with these default settings and options. Or just edit the below code with your own carrier and email settings.  
Enter carrier email, should be in the format of:  
@vtext.com, @txt.att.net, @messaging.sprintpcs.com, @tmomail.net, @msg.fi.google.com  
Enter in your phone number, email address and email password.  
Change the smtp server and port if you are not using Gmail.  

* **Alexa 'Notify Me' Skill**    
Enable the Skill inside the Alexa app. once linked it will email you an Access Code.  

* **Home Assistant**  
This is probably way more advanced than most people will use, but it's here for those that want it.    
Set your HASS URL, and API Token  
Enter in your script's entity_id that you want to have run when the AH Alert is triggered.  

### [Auction House Items to Monitor]  
Add a seperate section for each AH Item you want to check. Make sure to have it named like the following.  
The bracketed [AHItem#] must look like that with a unique number for each section.   
The price must be in COPPER! This is just to avoid any rounding and price matching errors. Conversion is easy!  

Gold: multiply the gold price by 10000.  ie: 12g 70s 0c would become: 12.7 * 10000 = 127000 copper.  
Silver: multiply the silver price by 100. ie: 58s 0c would become: 58 * 100 = 5800  

* Description: Friendly name. Can be whatever you want
* ItemID: get this ID from wowhead or TSM for the item you want to check for.
* Price: The price to alert on - In COPPER! (multiple gold by 10000 to get copper)
* Check: can be either 'Above' or 'Below' This is if you want to be alerted when the price is at or above/below the price you set.

[AHItem1]  
Description = Tidespray Linen  
itemID      = 152576  
price       = 22000  
check       = Below  

[AHItem2]  
Description = Monelite Ore  
itemID      = 152512  
price       = 51000  
check       = Above  

## How to use the windows Task Scheduler to run the script.
Note: The WoW Auction House API (And therefore the TSM API as well) is only updated about once every hour. So I recommend for the scheduled task time, to only run once per hour.

Creating a scheduled task is pretty easy. There are some specifics for this script though to make it work how we want.  
Use these basic steps to get started and see the screenshots below for an example of the Scheduled task as well:  

1. Create a new Scheduled task (Search: Task Scheduler > Create Task  
    1. Enter a friendly name. ie: AH Notifier  
1. Triggers tab: New (Suggestions below for how often, but do what you want here)  
    1. Select Daily and enter a date/time to start at. Recur every '1' days.
    1. Check the box for 'Repeat task every' and select 1 hour in the dropdown. For a duration of '1 day'  
    1. Click Ok  
1. Actions Tab: New
    1. Action: Start a program  
    1. Program/script box enter: AHNotifier_Task.vbs  
    1. Start in box: Enter in the path to where you saved the 3 files required ie: C:\users\Jaina\Desktop\AHNotifier
    1. Click ok.  
1. Click ok to save the Scheduled Task    

## FAQ/Common Issues  
1. This is powershell, so it does need Wndows and a computer that runs the script as scheduled unfortunately.  
2. Maybe I'll port this to Linux someday. Running this on a little Raspberry Pi Zero W would allow it to be on all the time. And cost less than $2 USD a year.  
3. TODO: Add setting option to combine multiple AH Items into one alert instead of the seperate ones they are now. - (aybe? Might not be needed or wanted)  
4. TODO: Add the ability to check multiple servers Auction Houses. Limited to one for right now.
5. TODO: Create a video walkthrough of the process.

## Advanced config
If using the windows toast notification option, there are 3 buttons that can appear. Open WoW, Details, and Dismiss.  
* Dismiss: Self explanatory, closes the notification.  
* Details: Opens up your default web browser to the TSM Details page of the item that was alerted on.  
* Open WoW: Clicking this will launch the World of Warcraft launcher program to sign into WoW.  
However, the 'Open WoW' takes some advanced config. If you ant to see and use this feature of the Notification, then please follow the steps below:  

TODO - Add registry steps here for Open Wow  

## Screenshots/Videos  
<img src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/text-alert.png" width="400">    
<img src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/task_trigger.png" width="450">  
<img src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/task_action.png" width="450">  
