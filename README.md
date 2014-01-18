rotoworld-webscript
===================

Rotoworld email/text notifications via webscript.io: Scrapes rotoworld (http://www.rotoworld.com/) for player updates and sends them via email or text message.

Usage:

- Runs on webscript.io (https://www.webscript.io/), which allows Lua scripts to be run as HTTP requests or cron jobs.
- Set storage key-values (webscript.io's persistent storage) by running storage_reset.lua.  Add relevant details (Twilio/SMTP credentials) where needed.
- Set the players to track in the players table, and which sport (NFL/NBA/MLB) in the HTTP request params url.
- Set the email_notification and text_notification options to send via email and/or text.
- Run the script as a cron job every 1 minute, or however often you want to check for updates.
- Note that if more than 3 updates for tracked players are posted within a 15 update sequence (each scrape of Rotoworld's updates will grab last 15 updates), then repeats will be sent.  The script can be easily modified to add more slots, but it generally won't be an issue unless you're tracking a lot of players.  I don't think it's possible to programmatically set a storage key or iterate through storage key-values in webscript.io, so additional slots will have to be added one by one in the process_data() function.
