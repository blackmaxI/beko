local config = loadfile("./config.lua")()
local URL = require "socket.url"
local https = require "ssl.https"
local serpent = require "serpent"
local json = require "JSON"
local JSON = require "cjson"
local token = config.ApiBotToken
local url = 'https://api.telegram.org/bot' .. token
local offset = 0
local redis = require('redis')
local redis = redis.connect('127.0.0.1', 6379)
local ChannelLink = config.Channel_Link
function is_mod(chat,user)
sudo = config.SudoUser
Cli = config.CliBotId
  local var = false
  for v,_user in pairs(sudo) do
    if _user == user then
      var = true
    end
  end
 local hash = redis:sismember('owners:'..chat,user)
 if hash then
 var = true
 end
 local hash2 = redis:sismember('mods:'..chat,user)
 if hash2 then
 var = true
 end
 return var
 end
--*******************************************--
local function getUpdates()
  local response = {}
  local success, code, headers, status  = https.request{
    url = url .. '/getUpdates?timeout=20&limit=1&offset=' .. offset,
    method = "POST",
    sink = ltn12.sink.table(response),
  }

  local body = table.concat(response or {"no response"})
  if (success == 1) then
    return json:decode(body)
  else
    return nil, "Request Error"
  end
end

function vardump(value)
  print(serpent.block(value, {comment=false}))
end 
function send_msg(chat_id, text, reply_to_message_id, markdown)
  local url = url .. "/sendMessage?chat_id=" .. chat_id .. "&text=" .. URL.escape(text)
  if reply_to_message_id then
    url = url .. "&reply_to_message_id=" .. reply_to_message_id
  end
  if markdown == "md" or markdown == "markdown" then
    url = url .. "&parse_mode=Markdown"
  elseif markdown == "html" then
    url = url .. "&parse_mode=HTML"
  end
  https.request(url)
end

function sendmsg(chat,text,keyboard)
if keyboard then
urlk = url .. '/sendMessage?chat_id=' ..chat.. '&text='..URL.escape(text)..'&parse_mode=html&reply_markup='..URL.escape(json:encode(keyboard))
else
urlk = url .. '/sendMessage?chat_id=' ..chat.. '&text=' ..URL.escape(text)..'&parse_mode=html'
end
https.request(urlk)
end
function sendinline(chat_id_,text,keyboard)
local bot = '302333716:AAHpZKn8a_3a4PkK1QmbOc371j4pA-cWlrE'
local url = 'https://api.telegram.org/bot'..bot
if keyboard then

tokens = url .. '/sendMessage?chat_id=' ..chat_id_.. '&text='..URL.escape(text)..'&parse_mode=html&reply_markup='..URL.escape(json:encode(keyboard))
else
tokens = url .. '/sendMessage?chat_id=' ..chat_id_.. '&text=' ..URL.escape(text)..'&parse_mode=html'
end
https.request(tokens)
end
 function edit( message_id, text, keyboard)
  local urlk = url .. '/editMessageText?&inline_message_id='..message_id..'&text=' .. URL.escape(text)
    urlk = urlk .. '&parse_mode=Markdown'
  if keyboard then
    urlk = urlk..'&reply_markup='..URL.escape(json:encode(keyboard))
  end
    return https.request(urlk)
  end
function Canswer(callback_query_id, text, show_alert)
	local urlk = url .. '/answerCallbackQuery?callback_query_id=' .. callback_query_id .. '&text=' .. URL.escape(text)
	if show_alert then
		urlk = urlk..'&show_alert=true'
	end
  https.request(urlk)
	end
  function answer(inline_query_id, query_id , title , description , text , keyboard)
  local results = {{}}
         results[1].id = query_id
         results[1].type = 'article'
         results[1].description = description
         results[1].title = title
         results[1].message_text = text
  urlk = url .. '/answerInlineQuery?inline_query_id=' .. inline_query_id ..'&results=' .. URL.escape(json:encode(results))..'&parse_mode=Markdown&cache_time=' .. 1
  if keyboard then
   results[1].reply_markup = keyboard
  urlk = url .. '/answerInlineQuery?inline_query_id=' .. inline_query_id ..'&results=' .. URL.escape(json:encode(results))..'&parse_mode=Markdown&cache_time=' .. 1
  end
    https.request(urlk)
  end
function settings(chat,value) 
local hash = 'settings:'..chat..':'..value
   if value == 'file' then
      text = 'فایل'
   elseif value == 'keyboard' then
    text = 'کیبورد شیشه ای'
  elseif value == 'links' then
    text = 'لینک'
  elseif value == 'spam' then
    text = 'اسپم'
  elseif value == 'tag' then
    text = 'تگ'
elseif value == 'fosh' then
    text = 'فحش'
  elseif value == 'emoji' then
    text = 'ایموجی'
elseif value == 'flood' then
    text = 'پیام مکرر'
elseif value == 'join' then
    text = 'جوین'
  elseif value == 'edit' then
    text = 'ادیت'
   elseif value == 'game' then
    text = 'بازی ها'
    elseif value == 'username' then
    text = 'یوزرنیم(@)'
   elseif value == 'pin' then
    text = 'پین کردن پیام'
    elseif value == 'photo' then
    text = 'عکس'
    elseif value == 'gif' then
    text = 'گیف'
    elseif value == 'video' then
    text = 'فیلم'
elseif value == 'selfvideo' then
    text = 'فیلم سلفی'
    elseif value == 'audio' then
    text = 'ویس'
    elseif value == 'music' then
    text = 'اهنگ'
    elseif value == 'text' then
    text = 'متن'
    elseif value == 'sticker' then
    text = 'استیکر'
    elseif value == 'contact' then
    text = 'مخاطب'
    elseif value == 'forward' then
    text = 'فوروارد'
    elseif value == 'persian' then
    text = 'گفتمان فارسی'
    elseif value == 'english' then
    text = 'گفتمان انگلیسی'
    elseif value == 'bot' then
    text = 'ربات(Api)'
    elseif value == 'tgservice' then
    text = 'پیغام ورود،خروج'
    end
		if not text then
		return ''
		end
	if redis:get(hash) then
  redis:del(hash)
return 'قفل '..text..' غیرفعال شد.'
		else 
		redis:set(hash,true)
return 'قفل '..text..' فعال شد.'
end
    end
function fwd(chat_id, from_chat_id, message_id)
  local urlk = url.. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id
  local res, code, desc = https.request(urlk)
  if not res and code then --if the request failed and a code is returned (not 403 and 429)
  end
  return res, code
end
function sleep(n) 
os.execute("sleep " .. tonumber(n)) 
end
local day = 86400
local run = function()
  while true do
    local updates = getUpdates()
    vardump(updates)
    if(updates) then
      if (updates.result) then
        for i=1, #updates.result do
          local msg = updates.result[i]
        if msg.text == "/start" then
print('hi')
          Text = [[ خوش آمدید.
> این ربات توسط تیم گرند(@GrandTeam) ساخته شده و درحال حاضر کاربردی در خصوصی ندارد.]]
          sendmsg((msg.chat).id, Text, "")
send_msg(msg.message.chat.id, '> Helper is Now *Online* !', msg.message.message_id, "md")
        end
          offset = msg.update_id + 1
          if msg.inline_query then
            local q = msg.inline_query
						 if q.from.id == Cli or q.from.id == 378393503 then
            if q.query:match('%d+') then
              local chat = '-'..q.query:match('%d+')
							local function is_lock(chat,value)
local hash = 'settings:'..chat..':'..value
 if redis:get(hash) then
    return true 
    else
    return false
    end
  end
                            local keyboard = {}
							keyboard.inline_keyboard = {
								{
                 {text = 'تنظیمات گروه🛠', callback_data = 'gpsettings:'..chat}
				  },{
				 {text = 'لینک🖇', callback_data = 'gplinks:'..chat},{text = 'قوانین📋', callback_data = 'gprules:'..chat}
			  	},{
				 {text = 'ناظر ها📗', callback_data = 'mods:'..chat}
			  	},{
				 {text = 'میوت شده ها📒', callback_data = 'mutes:'..chat},{text = 'بن شده ها📕', callback_data = 'bans:'..chat}
			  	},{
				 {text = 'پشتیبانی👥', callback_data = 'support:'..chat}
			  	},{
				{text = 'کانال ربات💬', url = ChannelLink}
			  	},{
				 {text = 'بستن منو مدیریتی🚫', callback_data = 'Cskhfgnljvhnjfgkgf:'..chat}
				}
							}
            answer(q.id,'Menu','> منو مدیریتی',chat,[[
به منو مدیریتی گروه خوش اومدین
لطفا بخش مورد نظر را انتخاب کنید
]],keyboard)
            end
            end
if q.query:match('new') then
                            local keyboard = {}
							keyboard.inline_keyboard = {}
local text = [[گروه جدیدی با اید اضافه شد]]
sendinline(226283662,text,keyboard)
            end
						end
          if msg.callback_query then
            local q = msg.callback_query
						local chat = ('-'..q.data:match('(%d+)') or '')
						if is_mod(chat,q.from.id) then
             if q.data:match('_') and not (q.data:match('sting2') or q.data:match('gpsettings') or q.data:match('sting3')) then
                Canswer(q.id,">برای مشاهده راهنمای بیشتر این بخش عبارت\n/help\nرا ارسال کنید",true)
					elseif q.data:match('lock') then
							local lock = q.data:match('lock (.*)')
							TIME_MAX = (redis:get('floodtime'..chat) or 3)
              MSG_MAX = (redis:get('floodmax'..chat) or 5)
							local result = settings(chat,lock)
							if lock == 'photo' or lock == 'audio' or lock == 'video' or lock == 'gif' or lock == 'music' or lock == 'file' or lock == 'links' or lock == 'sticker' or lock == 'text' or lock == 'pin' or lock == 'username' or lock == 'selfvideo' or lock == 'contact' or lock == 'tag' or lock == 'fosh' or lock == 'join' or lock == 'warn' then
							q.data = 'gpsettings:'..chat
							elseif lock == 'muteall' then
								if redis:get('muteall'..chat) then
								redis:del('muteall'..chat)
									result = "قفل چت غیرفعال گردید."
								else
								redis:set('muteall'..chat,true)
									result = "قفل چت فعال گردید!"
							end
						 q.data = 'gpsettings:'..chat
							elseif lock == 'warn' then
							local hash = redis:hget("warn:"..chat, "swarn")
						if hash then
            if redis:hget("warn:"..chat, "swarn") == 'kick' then
         			warn_status = 'بن'
							redis:hset("warn:"..chat, "swarn",'ban')
              elseif redis:hget("warn:"..chat, "swarn") == 'ban' then
              warn_status = 'بی صدا'
							redis:hset("warn:"..chat, "swarn",'mute')
              end
          else
          warn_status = 'اخراج'
					redis:hset("warn:"..chat, "swarn",'kick')
          end
								result = 'عملکرد دریافت اخطار در گروه '..warn_status
								q.data = 'gpsettings:'..chat
								elseif lock == 'MSGMAXup' then
								if tonumber(MSG_MAX) == 20 then
									Canswer(q.id,'حداکثر عدد انتخابی برای این قابلیت [20] میباشد!',true)
									else
								MSG_MAX = tonumber(MSG_MAX) + 1
								redis:set('floodmax'..chat,MSG_MAX)
								q.data = 'gpsettings:'..chat
							  result = MSG_MAX
								end
								elseif lock == 'MSGMAXdown' then
								if tonumber(MSG_MAX) == 2 then
									Canswer(q.id,'حداقل عدد انتخابی مجاز  برای این قابلیت [2] میباشد!',true)
									else
								MSG_MAX = tonumber(MSG_MAX) - 1
								redis:set('floodmax'..chat,MSG_MAX)
								q.data = 'gpsettings:'..chat
								result = MSG_MAX
							end
								elseif lock == 'TIMEMAXup' then
								if tonumber(TIME_MAX) == 10 then
								Canswer(q.id,'حداکثر عدد انتخابی برای این قابلیت [10] میباشد!',true)
									else
								TIME_MAX = tonumber(TIME_MAX) + 1
								redis:set('floodtime'..chat,TIME_MAX)
								q.data = 'gpsettings:'..chat
								result = TIME_MAX
									end
								elseif lock == 'TIMEMAXdown' then
								if tonumber(TIME_MAX) == 2 then
									Canswer(q.id,'حداقل عدد انتخابی مجاز  برای این قابلیت [2] میباشد!',true)
									else
								TIME_MAX = tonumber(TIME_MAX) - 1
								redis:set('floodtime'..chat,TIME_MAX)
								q.data = 'gpsettings:'..chat
								result = TIME_MAX
									end
								elseif lock == 'welcome' then
								local h = redis:get('status:welcome:'..chat)
								if h == 'disable' or not h then
								redis:set('status:welcome:'..chat,'enable')
         result = 'ارسال پیام خوش آمدگویی فعال گردید.'
								q.data = 'gpsettings:'..chat
          else
          redis:set('status:welcome:'..chat,'disable')
          result = 'ارسال پیام خوش آمدگویی غیرفعال گردید!'
								q.data = 'gpsettings:'..chat
									end
								else
								q.data = 'gpsettings:'..chat
								end
							Canswer(q.id,result)
							end
							-------------------------------------------------------------------------
							if q.data:match('firstmenu') then
							local chat = '-'..q.data:match('(%d+)$')
							local function is_lock(chat,value)
local hash = 'settings:'..chat..':'..value
 if redis:get(hash) then
    return true 
    else
    return false
    end
  end
              local keyboard = {}
							keyboard.inline_keyboard = {
								{
                                 {text = 'تنظیمات گروه🛠', callback_data = 'gpsettings:'..chat}
				  },{
				 {text = 'لینک🖇', callback_data = 'gplinks:'..chat},{text = 'قوانین📋', callback_data = 'gprules:'..chat}
			  	},{
				 {text = 'ناظر ها📗', callback_data = 'mods:'..chat}
			  	},{
				 {text = 'میوت شده ها📒', callback_data = 'mutes:'..chat},{text = 'بن شده ها📕', callback_data = 'bans:'..chat}
			  	},{
				 {text = 'پشتیبانی👥', callback_data = 'support:'..chat}
			  	},{
				{text = 'کانال ربات💬', url = ChannelLink}
			  	},{
				 {text = 'بستن منو مدیریتی🚫', callback_data = 'Cskhfgnljvhnjfgkgf:'..chat}
				}
							}
            edit(q.inline_message_id,[[
به منو مدیریتی گروه خوش اومدین
لطفا بخش مورد نظر را انتخاب کنید
]],keyboard)
            end
if q.data:match('support') then
                           local chat = '-'..q.data:match('(%d+)$')
		local keyboard = {}
							keyboard.inline_keyboard = {
								{
                   {text = '«️', callback_data = 'firstmenu:'..chat}
				}
							}
              edit(q.inline_message_id,'`> در صورت گزارش مشکلات به ساپورت مراجمعه کنید`\n[ورود به ساپورت](https://t.me/joinchat/E_wGCUPUlOkFxf3AN7dr5w)',keyboard)
            end
if q.data:match('Cskhfgnljvhnjfgkgf') then
                           local chat = '-'..q.data:match('(%d+)$')
		local keyboard = {}
		keyboard.inline_keyboard = {}
              edit(q.inline_message_id,'🚫منو مدیریتی گروه با موفقیت بسته شد',keyboard)
            end
if q.data:match('mods') then
                           local chat = '-'..q.data:match('(%d+)$')
						   local list = redis:smembers('mods:'..chat)
          local t = '> لیست ناظران گروه:\n\n'
          for k,v in pairs(list) do
          t = t..k.." - *"..v.."*\n" 
          end
          if #list == 0 then
          t = '> لیست ناظران خالی است.'
          end
		local keyboard = {}
							keyboard.inline_keyboard = {
								{
                  {text = '🗑', callback_data = 'cm:'..chat}
				   },{
                   {text = '«️', callback_data = 'firstmenu:'..chat}
				}
							}
              edit(q.inline_message_id, ''..t..'',keyboard)
            end
	if q.data:match('cm') then
                           local chat = '-'..q.data:match('(%d+)$')
						   redis:del('mods:'..chat)
	Canswer(q.id,'لیست ناظران گروه با موفقیت حذف شد',true)
end
							------------------------------------------------------------------------
if q.data:match('mutes') then
                           local chat = '-'..q.data:match('(%d+)$')
						   local list = redis:smembers('mutes'..chat)
          local t = '> لیست افراد بی صدا گروه:\n\n'
          for k,v in pairs(list) do
          t = t..k.." - *"..v.."*\n" 
          end
          if #list == 0 then
          t = '> لیست افراد بی صدا خالی است.'
          end
		local keyboard = {}
							keyboard.inline_keyboard = {
								{
                  {text = '🗑', callback_data = 'mt:'..chat}
				   },{
                   {text = '«️', callback_data = 'firstmenu:'..chat}
				}
							}
              edit(q.inline_message_id, ''..t..'',keyboard)
            end
	if q.data:match('mt') then
                           local chat = '-'..q.data:match('(%d+)$')
			redis:del('mutes'..chat)
	Canswer(q.id,'لیست افراد بی صدا با موفقیت حذف شد',true)
end
if q.data:match('bans') then
                           local chat = '-'..q.data:match('(%d+)$')
						   local list = redis:smembers('banned'..chat)
          local t = '> لیست افراد بن شده گروه:\n\n'
          for k,v in pairs(list) do
          t = t..k.." - *"..v.."*\n" 
          end
          if #list == 0 then
          t = '> لیست افراد بن شده خالی است.'
          end
		local keyboard = {}
							keyboard.inline_keyboard = {
								{
                  {text = '🗑', callback_data = 'cb:'..chat}
				   },{
                   {text = '«️', callback_data = 'firstmenu:'..chat}
				}
							}
              edit(q.inline_message_id, ''..t..'',keyboard)
            end
	if q.data:match('cb') then
                           local chat = '-'..q.data:match('(%d+)$')
					redis:del('banned'..chat)
	Canswer(q.id,'لیست افراد بن شده با موفقیت حذف شد',true)
end
						if q.data:match('gprules') then
                           local chat = '-'..q.data:match('(%d+)$')
						   local rules = redis:get('grouprules'..chat)
          if not rules then
          rules = '`> قوانین برای گروه تنظیم نشده است.`'
          end
		local keyboard = {}
							keyboard.inline_keyboard = {
								{
							{text = '🗑', callback_data = 'cr:'..chat}
				   },{
                   {text = '«️', callback_data = 'firstmenu:'..chat}
				}
							}
              edit(q.inline_message_id, 'قوانین گروه:\n `'..rules..'`',keyboard)
            end
if q.data:match('cr') then
                           local chat = '-'..q.data:match('(%d+)$')
					redis:del('grouprules'..chat)
	Canswer(q.id,'قوانین گروه با موفقیت حذف شد',true)
end
							------------------------------------------------------------------------
							if q.data:match('gplinks') then
                           local chat = '-'..q.data:match('(%d+)$')
						   local links = redis:get('grouplink'..chat) 
          if not links then
          links = '`>لینک ورود به گروه تنظیم نشده است.`\n`ثبت لینک جدید با دستور زیر امکان پذیر است:`\n*/setlink* `link`'
          end
		local keyboard = {}
							keyboard.inline_keyboard = {
								{
								{text = '🗑', callback_data = 'cl:'..chat}
				   },{
                    {text = '«️', callback_data = 'firstmenu:'..chat}
				}
							}
              edit(q.inline_message_id, '`لینڪ گروه:`\n '..links..'',keyboard)
            end
if q.data:match('cl') then
                           local chat = '-'..q.data:match('(%d+)$')
					redis:del('grouplink'..chat)
	Canswer(q.id,'لینک گروه با موفقیت حذف شد',true)
end
        if msg.message then
          local text = msg.message.text
          local user = msg.message.from.id
          if text then
if text:match("^/[Ss]tart$") then
		print('hi')
send_msg(msg.message.chat.id, '> Helper is Now *Online* !', msg.message.message_id, "md")
end
end			
end
		if q.data:match('gpsettings') then
							local chat = '-'..q.data:match('(%d+)$')
							local function is_lock(chat,value)
local hash = 'settings:'..chat..':'..value
 if redis:get(hash) then
    return true 
    else
    return false
    end
  end

local function getsettings(value)
       if value == "charge" then
       local ex = redis:ttl("groupc:"..chat)
      if ex == -1 then
        return "نامحدود!"
       else
        local d = math.floor(ex / day ) + 1
        return d.." روز"
       end
        elseif value == 'muteall' then
        local h = redis:ttl('muteall'..chat)
       if h == -1 then
         return '(✔️)'
				elseif h == -2 then
          return '(✖️)'
       else
        return "تا ["..h.."] ثانیه دیگر فعال است"
       end
      elseif value == 'warn' then
       local hash = redis:hget("warn:"..chat, "swarn")
        if hash then
           if redis:hget("warn:"..chat, "swarn") == 'kick' then
         return 'اخراج'
             elseif redis:hget("warn:"..chat, "swarn") == 'ban' then
              return 'بن'
              elseif redis:hget("warn:"..chat, "swarn") == 'mute' then
              return 'بی صدا'
              end
          else
		redis:hset("warn:"..chat, "swarn",'kick')
          return 'اخراج'
          end
        elseif value == 'welcome' then
        local hash = redis:get('status:welcome:'..chat)
        if hash == 'enable' then
          return '(✔️)'
          else
          return '(✖️)'
          end
        elseif is_lock(chat,value) then
          return '(✔️)'
          else
          return '(✖️)'
          end
        end
								local MSG_MAX = (redis:get('floodmax'..chat) or 5)
								local TIME_MAX = (redis:get('floodtime'..chat) or 3)
         		         		local keyboard = {}
							keyboard.inline_keyboard = {
								{
{text= 'قفل سنجاق : '..getsettings('pin')..'',callback_data=chat..':lock pin'}
                },{
{text= 'قفل چت : '..getsettings('muteall')..' ',callback_data=chat..':lock muteall'}
                },{
{text= 'قفل رگبار : '..getsettings('flood')..' ',callback_data=chat..':lock flood'}
                },{
{text = 'تعداد رگبار : '..tostring(MSG_MAX)..'', callback_data = chat..'_MSG_MAX'}
                },{
									{text='≪',callback_data=chat..':lock MSGMAXdown'},{text='≫️',callback_data=chat..':lock MSGMAXup'}
                },{
 {text = 'زمان رگبار : '..tostring(TIME_MAX)..'', callback_data = chat..'_TIME_MAX'}
                },{
									{text='≪️',callback_data=chat..':lock TIMEMAXdown'},{text='≫️',callback_data=chat..':lock TIMEMAXup'}
                },{
{text= 'قفل لینک : '..getsettings('links')..'',callback_data=chat..':lock links'}
            },{ 
{text= 'قفل فوروارد : '..getsettings('forward')..'',callback_data=chat..':lock forward'}
            },{
{text= 'قفل تگ : '..getsettings('tag')..'',callback_data=chat..':lock tag'}
                },{
{text= 'قفل یوزرنیم : '..getsettings('username')..'',callback_data=chat..':lock username'}
                },{
{text= 'قفل فحش : '..getsettings('fosh')..'',callback_data=chat..':lock fosh'}
                },{
{text= 'قفل ایموجی : '..getsettings('emoji')..'',callback_data=chat..':lock emoji'}
                },{
{text= 'قفل جوین : '..getsettings('join')..'',callback_data=chat..':lock join'}
                },{
{text= 'قفل مخاطب : '..getsettings('contact')..'',callback_data=chat..':lock contact'}
                },{
{text= 'قفل ربات : '..getsettings('bot')..'',callback_data=chat..':lock bot'}
                },{
 {text= 'قفل بازی : '..getsettings('game')..'',callback_data=chat..':lock game'}
                },{
{text='قفل فارسی : '..getsettings('persian')..'',callback_data=chat..':lock persian'}
                },{
{text= 'قفل انگلیسی : '..getsettings('english')..'',callback_data=chat..':lock english'}
                },{
{text= 'قفل ادیت : '..getsettings('edit')..'',callback_data=chat..':lock edit'}
                },{
{text= 'قفل سرویس تلگرام : '..getsettings('tgservice')..' ',callback_data=chat..':lock tgservice'}
                },{
{text= 'قفل کیبورد اینلاین : '..getsettings('keyboard')..'',callback_data=chat..':lock keyboard'}
                },{
{text= 'قفل استیکر : '..getsettings('sticker')..'',callback_data=chat..':lock sticker'}
                },{
{text= 'قفل عکس : '..getsettings('photo')..'',callback_data=chat..':lock photo'}
                },{
{text= 'قفل ویس : '..getsettings('audio')..'',callback_data=chat..':lock audio'}
                },{
{text= 'قفل فیلم سلفی : '..getsettings('selfvideo')..'',callback_data=chat..':lock selfvideo'}
                },{
{text= 'قفل فیلم : '..getsettings('selfvideo')..'',callback_data=chat..':lock selfvideo'}
                },{
{text= 'قفل گیف : '..getsettings('gif')..'',callback_data=chat..':lock gif'}
                },{
 {text= 'قفل اهنگ : '..getsettings('music')..'',callback_data=chat..':lock music'}
                },{
                  {text= 'قفل فایل : '..getsettings('file')..'',callback_data=chat..':lock file'}
                },{ 
{text= 'قفل متن : '..getsettings('text')..'',callback_data=chat..':lock text'}
                },{ 
{text='مهلت ربات : '..getsettings('charge'),callback_data=chat..'_charge'}
            },{ 

                },{
                  {text = '«️', callback_data = 'firstmenu:'..chat}
                }
							}
              edit(q.inline_message_id,'تنظیمات گروه شما',keyboard)
            end
            else Canswer(q.id,'شما مالک/ناظر گروه نیستید و امکان تغییر تنظیمات را ندارید!',true)
						end
						end
          if msg.message and msg.message.date > (os.time() - 5) and msg.message.text then
     end
      end
    end
  end
    end
end

return run()
						