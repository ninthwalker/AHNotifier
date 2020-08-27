<p align="center">
<img align="center" src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/ahnotifier-logo.png" width="250"></p>  
<img src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/discord-alert.png">  
Notifies you of prices for specific WoW Auction House Items.  
Currently supports Discord, Telegram, Pushover, Text Messages, Alexa 'Notify Me' Skill, and Home Assistant scripts. If you want another notification type, let me know.    
  

## Details/Requirements  
1. Windows 10 (Computer does need to be on or scheduled to wake to run the script)
2. Powershell 3.0+ (Comes with WIN10)
3. A TSM API Key (get from [here](https://www.tradeskillmaster.com/user))  
4. Discord, Telegram, Pushover, Cell Phone, or Alexa Device.

## How it works  
Enter in your Realm/TSM API Info and the Auction House items you would like to be notified on in the settings.txt file.  
Run the Script as a scheduled task in Windows and be alerted via one of the notification types when your price is matched.  

## Overview of Setup steps  
1. Download the AHNotifier.ps1 and the settings.txt files.  
2. Place the 2 files in the same folder or directory on your computer.  
3. Configure the settings.txt file per the section below.  
4. Schedule the script to run via a scheduled task on your computer per the section below.  
  
## Settings.txt file setup  
Please see the settings.sample file for detailed info on the sections.  
Overview of settings.txt sections:  

* **[Server Settings]**  
Enter your Region (ie: US or  EU)  
Enter your Server Name  
Enter your TSM API Key from [here](https://www.tradeskillmaster.com/user)    

* **[Notification Types]**  
Set to 'Disabled' or 'Enabled' for the types you want to use.  
You can set one or all.  

* **[Notification Settings]**  
For each Notification type that you set to 'Enabled' in the above section, create a corresponding section here for it.  
See the setttings.sample for details of how this should look. 

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
Note: The WoW Auction House API (And therefore the TSM API as well) is only updated about once every hour. So I recommend for the scheduled task time, to only run at most once per hour.  

Creating a scheduled task is pretty easy. Here is a website with some screenshots and basic instructions.  
https://blog.netwrix.com/2018/07/03/how-to-automate-powershell-scripts-with-task-scheduler/  

* Here are some specific settings to use for this script and see the screenshots below for an example of the Scheduled task as well  
In the Action Section of editing your task, add the following line in the 'Add Arguments' box. (change the -File path to your own):  
`-executionpolicy bypass -noprofile -windowstyle hidden -File "C:\scripts\AHNotifier\AHNotifier.ps1"`  
This will keep the script window hidden and set the execution policy to allow your computer to run the script.  

## FAQ/Common Issues  
1. This is powershell, so it does need windows and a computer that runs the script as scheduled unfortunately.  
2. Maybe I'll port this to Linux someday. Running this on a little Raspberry Pi Zero W would allow it to be on all the time. And cost less than $2 USD a year.  
3. TODO: Add setting option to combine multiple AH Items into one alert instead of the seperate ones they are now.  

## Screenshots/Videos  
<img src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/text-alert.png" width="400">  
<img src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/task1.png" width="400">  
<img src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/task2.png" width="400">  
