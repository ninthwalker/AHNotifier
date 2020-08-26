<p align="center">
<img align="center" src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/AHNotifier-logo.png" width="250"></p>
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
  
### Settings.txt file setup  
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

## FAQ/Common Issues  
1. This is powershell, so it does need windows and computer that runs the script as scheduled unfortunately.

## Screenshots & Videos  

<img src="https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/mobile.png" width="500">  

![](https://raw.githubusercontent.com/ninthwalker/AHNotifier/master/screenshots/alert.png) ![]  

