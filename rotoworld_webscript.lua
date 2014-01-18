-- Constants
local player_div = '<div class="player" >'
local report_div = '<div class="report">'
local a_href = '<a href='
local a_href_end = '>'
local a_end = '</a>'
local div_end = '</div>'

-- Script settings
local players = {"Kendall Marshall", "Nicolas Batum",
  "Wilson Chandler", "Thaddeus Young", "Kevin Martin",
  "Marcin Gortat", "Serge Ibaka", "Tristan Thompson",
  "Paul Millsap", "Dion Waiters", "Enes Kanter"}
storage.last_slot = storage.last_slot or 1

local text_notification = false
local email_notification = true
local twilio = require('twilio')
local account_sid = storage.account_sid
local auth_token = storage.auth_token
local twilio_number = storage.twilio_number
local my_number = storage.my_number
local smtp_server = storage.smtp_server
local smtp_username = storage.smtp_username
local smtp_password = storage.smtp_password
local smtp_from_email = storage.smtp_from_email
local my_email = storage.my_email

-- Processing functions
function str_clean(str)
  str = string.gsub(str, "<p>", "")
  str = string.gsub(str, "</p>", "")
  a1, a2 = string.find(str, '[%w%p]')
  b1, b2 = string.find(string.reverse(str), '[%w%p]')
  return string.sub(str, a1, string.len(str)-b1+1)
end

function update_last_slot()
  storage.last_slot = tonumber(storage.last_slot) + 1
  if tonumber(storage.last_slot) > 3 then storage.last_slot = 1 end
end

function send_notifications(name, news)
  if text_notification == true then
    text_message = string.sub(news, 1, 160)
    twilio.sms(account_sid, auth_token, twilio_number, my_number, text_message)
  end
  if email_notification == true then
    email_subject = "Rotoworld news for " .. name
    email_message = news
    email.send {
      server = smtp_server,
      username = smtp_username,
      password = smtp_password,
      from = smtp_from_email,
      to = my_email,
      subject = email_subject,
      text = email_message
    }
  end
end

function process_data(data)
  player_name = data[1]
  player_news = data[2]
  for k, v in pairs(players) do
    if v == player_name then
      -- Three slot "memory"
      if storage.news1 ~= player_news and
        storage.news2 ~= player_news and
        storage.news3 ~= player_news then
        if tonumber(storage.last_slot) == 1 then
          storage.news2 = player_news
        elseif tonumber(storage.last_slot) == 2 then
          storage.news3 = player_news
        else
          storage.news1 = player_news
        end
        update_last_slot()
        send_notifications(player_name, player_news)
      end
    end
  end
end

-- HTTP request
local rotoworld_nfl_player_news = "http://www.rotoworld.com/playernews/nfl/football-player-news"
local rotoworld_nba_player_news = "http://www.rotoworld.com/playernews/nba/basketball-player-news"
local rotoworld_mlb_player_news = "http://www.rotoworld.com/playernews/mlb/baseball-player-news"
local params = { url = rotoworld_nba_player_news}
local response = http.request(params)
local content = response["content"]

-- DOM parsing loop
local updates = {}
local start_find = 1

repeat
  --player name
  --find player div
  ps1, ps2 = string.find(content, player_div, start_find)
  if ps1 == nil then break end
  --find link href
  ls1, ls2 = string.find(content, a_href, ps2+1)
  --get string in <a></a>
  le1, le2 = string.find(content, a_href_end, ls2+1)
  ae1, ae2 = string.find(content, a_end, le2+1)
  name = string.sub(content, le2+1, ae1-1)

  --player update
  x1, x2 = string.find(content, report_div, ae2+1)
  y1, y2 = string.find(content, div_end, x2+1)
  update = string.sub(content, x2+1, y1-1)
  updates[table.getn(updates)+1] = {name, str_clean(update)}
  start_find = y2 + 1
until false

-- Check updates
for k, v in pairs(updates) do
  process_data(v)
end

return
