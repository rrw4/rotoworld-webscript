rotoworld-webscript
===================

Rotoworld email/text notifications via webscript.io: Scrapes rotoworld (http://www.rotoworld.com/) for player updates and sends them via email or text message.

Usage:

- Runs on webscript.io (https://www.webscript.io/), which allows Lua scripts to be run as HTTP requests or cron jobs.
- Set storage key-values (webscript.io's persistent storage) by running storage_reset.lua.  Add relevant details (Twilio/SMTP credentials) where needed.
- Set the players to track in the players table, and which sport (NFL/NBA/MLB) in the HTTP request params url.
- Set the email_notification and text_notification options to send via email and/or text.
- Run the script as a cron job every 1 minute, or however often you want to check for updates.
