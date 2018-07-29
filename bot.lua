_config = dofile('config.lua')
utf8 = dofile('utf8.lua')
serpent = require("serpent")
redis_ = require("redis")
socket = require("socket")
URL = require("socket.url")
http = require("socket.http")
https = require("ssl.https")
ltn12 = require("ltn12")
json = require "JSON"
redis = redis_.connect("127.0.0.1", 6379)
require 'help'
day = 86400
http.TIMEOUT = 10
--------------------------------------------------------------------------------
sudo_users = _config.SudoUser 
bot_id = _config.CliBotId
api_id = _config.ApiBotId
--------------------------------------------------------------------------------
function Run()
print('\27[93m>Developer:\27[39m'..' '..'@GrandDev')
end
--------------------------------------------------------------------------------
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function dl_cb(arg, data)
 -- vardump(data)
  --vardump(arg)
end
--------------------------------------------------------------------------------
  function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
--------------------------------------------------------------------------------
function is_owner(msg) 
  local hash = redis:sismember('owners:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) then
return true
else
return false
end
end
--------------------------------------------------------------------------------
function is_mod(msg) 
  local hash = redis:sismember('mods:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) or is_owner(msg) then
return true
else
return false
end
end 
--------------------------------------------------------------------------------
function is_banned(chat,user)
   local hash =  redis:sismember('banned'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
--------------------------------------------------------------------------------
function is_gban(chat,user)
   local hash =  redis:sismember('gbaned',user)
  if hash then
    return true
    else
    return false
    end
  end
--------------------------------------------------------------------------------
  function is_filter(msg, value)
  local hash = redis:smembers('filters:'..msg.chat_id_)
  if hash then
    local names = redis:smembers('filters:'..msg.chat_id_)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_mod(msg) then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
  end
--------------------------------------------------------------------------------
function is_muted(chat,user)
   local hash =  redis:sismember('mutes'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
--------------------------------------------------------------------------------
function do_notify (user, msg)
	local n = notify.Notification.new(user, msg)
	n:show ()
end
--------------------------------------------------------------------------------
local function UpTime()
  local uptime = io.popen("uptime"):read("*all")
  days = uptime:match("up %d+ days")
  hours = uptime:match(",  %d+:")
  minutes = uptime:match(":%d+,")
    sec = uptime:match(":%d+ up")
  if hours then
    hours = hours
  else
    hours = ""
  end
  if days then
    days = days
  else
    days = ""
  end
  if minutes then
    minutes = minutes
  else
    minutes = ""
  end
  days = days:gsub("up", "")
  local a_ = string.match(days, "%d+")
  local b_ = string.match(hours, "%d+")
  local c_ = string.match(minutes, "%d+")
   local d_ = string.match(sec, "%d+")
  if a_ then
    a = a_
  else
    a = 0
  end
  if b_ then
    b = b_
  else
    b = 0
  end
  if c_ then
    c = c_
  else
    c = 0
  end
    if d_ then
    d = d_
  else
    d = 0
  end
return a..'روز و '..b..' ساعت و '..c..' دقیقه و '..d..' ثانیه'
end
--------------------------------------------------------------------------------
function get_username(user_id)
  if redis:hget('username',user_id) then
    text = '@'..(string.gsub(redis:hget('username',user_id), 'false', '') or '-----')
  end
  get_user(user_id)
  return text
end
function getname(user_id)
  if redis:hget('name',user_id) then
    text = ''..(string.gsub(redis:hget('name',user_id), 'false', '') or '-----')
  end
  get_user(user_id)
  return text
end
function get_phone(user_id)
  if redis:hget('phone',user_id) then
    text = ''..(string.gsub(redis:hget('phone',user_id), 'false', '') or '-----')
  end
  get_user(user_id)
  return text
end
--------------------------------------------------------------------------------
function sleep(sec)
    socket.sleep(sec)
end
--------------------------------------------------------------------------------
function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end
--------------------------------------------------------------------------------
function get_user(user_id)
  function dl_username(arg, data)
    username = data.username or '-----'
        name = data.first_name_ or '-----'
        phone = data.phone_number_ or '-----'

    --vardump(data)
    redis:hset('username',data.id_,data.username_)
redis:hset('name',data.id_,data.first_name_)
redis:hset('phone',data.id_,data.phone_number_)
  end
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, dl_username, nil)
end
--------------------------------------------------------------------------------
function getChats(offset_order, offset_chat_id, limit, cb, cmd)
  if not limit or limit > 20 then
    limit = 20
  end
  tdcli_function ({
    ID = "GetChats",
    offset_order_ = offset_order or 9223372036854775807,
    offset_chat_id_ = offset_chat_id or 0,
    limit_ = limit
  }, cb or dl_cb, cmd)
end
--------------------------------------------------------------------------------
function deleteMessagesFromUser(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function sendRequest(request_id, chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, callback, extra)
  tdcli_function({
    ID = request_id,
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = input_message_content
  }, callback or dl_cb, extra)
end
--------------------------------------------------------------------------------
function string:starts(text)
  return text == string.sub(self, 1, string.len(text))
end
--------------------------------------------------------------------------------
function download_to_file(url, file_name)
  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  local response
  if url:starts("https") then
    options.redirect = false
    response = {
      https.request(options)
    }
  else
    response = {
      http.request(options)
    }
  end
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then
    return nil
  end
  file_name = file_name or get_http_file_name(url, headers)
  local file_path = "data/" .. file_name
  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
--------------------------------------------------------------------------------
function checkChatInviteLink(link, cb, cmd)
  tdcli_function ({
    ID = "CheckChatInviteLink",
    invite_link_ = link
  }, cb or dl_cb, cmd)
end
--------------------------------------------------------------------------------
function run_bash(CMD)
  local cmd = io.popen(CMD)
  local result = cmd:read("*all")
  return result
end
--------------------------------------------------------------------------------
function save(data)
local file = 'database.lua'
  file = io.open(file, 'w+')
  local serialized = serpent.block(data, {comment = false, name = '_'})
  file:write(serialized)
  file:close()
end
--------------------------------------------------------------------------------
local dbhash = db.hash
function get(value,x)
	if x then
	if dbhash[value] and dbhash[value][x] then
			return dbhash[value][x]
			end
		else
if dbhash[value] then
    return dbhash[value]
		end
		end
	return false
  end
--------------------------------------------------------------------------------
function set(hash,value,x)
	if x then
		if not dbhash[hash] then
			dbhash[hash] = {}
			end
		dbhash[hash][x] = value
		else
  dbhash[hash] = value
		end
  save(db)
  end
--------------------------------------------------------------------------------
function del(hash,x)
	if x then
	dbhash[hash][x] = nil
		else
  dbhash[hash] = nil
		end
  save(db)
  end
--------------------------------------------------------------------------------
function get_file(file_name)
  local respbody = {}
  local options = {
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  local file_path = "data/" .. file_name
  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
--------------------------------------------------------------------------------
function getChatId(chat_id)
  local chat = {}
  local chat_id = tostring(chat_id)

  if chat_id:match('^-100') then
    local channel_id = chat_id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = chat_id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  return chat
end
--------------------------------------------------------------------------------
function OpenChat(chat_id, cb)
  tdcli_function ({
    ID = "OpenChat",
    chat_id_ = chat_id
  }, cb or dl_cb, nil)
end
--------------------------------------------------------------------------------
function editMessageText(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)

  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup, -- reply_markup:ReplyMarkup
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function getUser(user_id,cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
--------------------------------------------------------------------------------
function forwardMessages(chat_id, from_chat_id, message_ids, disable_notification)
  tdcli_function ({
    ID = "ForwardMessages",
    chat_id_ = chat_id,
    from_chat_id_ = from_chat_id,
    message_ids_ = message_ids, -- vector
    disable_notification_ = disable_notification,
    from_background_ = 1
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  tdcli_function({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(photo),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = caption
    }
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function editMessageText(chat_id, message_id, reply_markup, text, disable_web_page_preview)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup, -- reply_markup:ReplyMarkup
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {}
    },
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
--------------------------------------------------------------------------------
function reportChannelSpam(channel_id, user_id, message_ids)
  tdcli_function ({
    ID = "ReportChannelSpam",
    channel_id_ = getChatId(channel_id).ID, 
    user_id_ = user_id, 
    message_ids_ = message_ids 
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function changeChatMemberStatus(chat_id, user_id, status)
  tdcli_function ({
    ID = "ChangeChatMemberStatus",
    chat_id_ = chat_id,
    user_id_ = user_id,
    status_ = {
      ID = "ChatMemberStatus" .. status
    },
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
--------------------------------------------------------------------------------
function channel_get_bots(channel,cb)
local function callback_admins(extra,result,success)
    limit = result.member_count_
   getChannelMembers(channel, 0, 'Bots', limit,cb)
    end 
getChannelFull(channel,callback_admins)
end
function getUser(user_id,cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
--------------------------------------------------------------------------------
function getChannelFull(channel_id,cb)
  tdcli_function ({
    ID = "GetChannelFull",
    channel_id_ = getChatId(channel_id).ID
  }, cb, nil)
end
--------------------------------------------------------------------------------
function channel_get_kicked(channel,cb)
local function callback_admins(extra,result,success)
    limit = result.kicked_count_
   getChannelMembers(channel, 0, 'Kicked', limit,cb)
    end
  getChannelFull(channel,callback_admins)
end
--------------------------------------------------------------------------------
function addChatMember(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function migrateGroupChatToChannelChat(chat_id)
  tdcli_function ({

    ID = "MigrateGroupChatToChannelChat",
    chat_id_ = chat_id
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function channel_get_admins(channel,cb)
  local function callback_admins(extra,result,success)
    limit = result.administrator_count_
    if tonumber(limit) > 0 then
    getChannelMembers(channel, 0, 'Administrators', limit,cb)
     else return reply_to(channel, 0, 1,'ربات ادمین گروه نشده است !', 1, 'md') end
    end
  getChannelFull(channel,callback_admins)
end
--------------------------------------------------------------------------------
function getChannelMembers(channel_id, offset, filter, limit,cb)
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset,
    limit_ = limit
  }, cb, nil)
end
--------------------------------------------------------------------------------
function getChatHistory(chat_id, from_message_id, offset, limit,cb)
  tdcli_function ({
    ID = "GetChatHistory",
    chat_id_ = chat_id,
    from_message_id_ = from_message_id,
    offset_ = offset,
    limit_ = limit
  }, cb, nil)
end
--------------------------------------------------------------------------------
function up_time()
  local url = "http://api.timezonedb.com/v2/get-time-zone?"
for i , i_val in pairs(my.time.Parameter) do
    url = url.. i .. '=' .. i_val .. '&'
end
    local dat , suc = performRequest(url)
    local tab = JSON.decode(dat)
    local x = tab.formatted:split(' ')
    local y = x[2]:split(':')
    my.time.h = y[1]
    my.time.m = y[2]
    my.time.s = y[3]
end
--------------------------------------------------------------------------------
function unpin(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end  
--------------------------------------------------------------------------------
   function SendMetion(chat_id, user_id, msg_id, text, offset, length)
local tt = redis:get('endmsg') or ''
  tdcli_function ({
        ID = "SendMessage",
        chat_id_ = chat_id,
        reply_to_message_id_ = msg_id,
        disable_notification_ = 0,
        from_background_ = 1,
        reply_markup_ = nil,
        input_message_content_ = {
          ID = "InputMessageText",
          text_ = text..'\n\n'..tt,
          disable_web_page_preview_ = 1,
        clear_draft_ = 0,
          entities_ = {[0]={
          ID="MessageEntityMentionName",
          offset_=offset,
          length_=length,
          user_id_=user_id
          },
          },
        },
    }, dl_cb, nil)
  end
--------------------------------------------------------------------------------
function getChatId(id)
  local chat = {}
  local id = tostring(id)
  
  if id:match('^-100') then
    local channel_id = id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  
  return chat
end
--------------------------------------------------------------------------------
function getInputMessageContent(file, filetype, caption)
  if file:match("/") or file:match(".") then
    infile = {
      ID = "InputFileLocal",
      path_ = file
    }
  elseif file:match("^%d+$") then
    infile = {
      ID = "InputFileId",
      id_ = file
    }
  else
    infile = {
      ID = "InputFilePersistentId",
      persistent_id_ = file
    }
  end
  local inmsg = {}
  local filetype = filetype:lower()
  if filetype == "animation" then
    inmsg = {
      ID = "InputMessageAnimation",
      animation_ = infile,
      caption_ = caption
    }
  elseif filetype == "audio" then
    inmsg = {
      ID = "InputMessageAudio",
      audio_ = infile,
      caption_ = caption
    }
  elseif filetype == "document" then
    inmsg = {
      ID = "InputMessageDocument",
      document_ = infile,
      caption_ = caption
    }
  elseif filetype == "photo" then
    inmsg = {
      ID = "InputMessagePhoto",
      photo_ = infile,
      caption_ = caption
    }
  elseif filetype == "sticker" then
    inmsg = {
      ID = "InputMessageSticker",
      sticker_ = infile,
      caption_ = caption
    }
  elseif filetype == "video" then
    inmsg = {
      ID = "InputMessageVideo",
      video_ = infile,
      caption_ = caption
    }
  elseif filetype == "voice" then
    inmsg = {
      ID = "InputMessageVoice",
      voice_ = infile,
      caption_ = caption
    }
  end
  return inmsg
end
---------------------------------------------------------------------------
function getInputFile(file)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  return infile
end
--------------------------------------------------------------------------------
function na(arg,data)
    -- vardump(data)
data.title_ = title
end
--------------------------------------------------------------------------------
 function getParseMode(parse_mode)
	if parse_mode then
		local mode = parse_mode:lower()
		
		if mode == "html" or mode == "ht" then
			P = {ID = "TextParseModeHTML"}
		else
			P = {ID = "TextParseModeMarkdown"}
		end
	end
  return P
end

--------------------------------------------------------------------------------
function send_file(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, document, caption, cb, cmd)
  local input_message_content = {
    ID = "InputMessageDocument",
    document_ = getInputFile(document),
    caption_ = caption
  }
  sendRequest("SendMessage", chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, input_message_content, cb, cmd)
end
--------------------------------------------------------------------------------
function deleteMessagesFromUser(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end
--------------------------------------------------------------------------------
function getMe(cb)
  tdcli_function ({
    ID = "GetMe",
  }, cb, nil)
end
--------------------------------------------------------------------------------
function reply_to(ChatId, ReplyToMessageId, from_background, Text, DisableWebPagePreview, ParseMode, UserId, Cb, Extra)
	if ParseMode and ParseMode ~= nil and ParseMode ~= false and ParseMode ~= "" then
		ParseMode = getParseMode(ParseMode)
	else
		ParseMode = nil
	end
	
	Entities = {}
	if UserId then
		if Text:match('<user>') and Text:match('</user>') then
			local A = {Text:match("<user>(.*)</user>")}
			Length = utf8.len(A[1])
			local B = {Text:match("^(.*)<user>")}
			Offset = utf8.len(B[1])
			Text = Text:gsub('<user>','')
			Text = Text:gsub('</user>','')
			table.insert(Entities,{ID = "MessageEntityMentionName", offset_ = Offset, length_ = Length, user_id_ = UserId})
		end
		Entities[0] = {ID='MessageEntityBold', offset_=0, length_=0}
	end
	
	tdcli_function ({
		ID = "SendMessage",
		chat_id_ = ChatId,
		reply_to_message_id_ = ReplyToMessageId or 0,
		disable_notification_ = 0,
		from_background_ = from_background,
		reply_markup_ = nil,
		input_message_content_ = {
			ID = "InputMessageText",
			text_ = Text,
			disable_web_page_preview_ = DisableWebPagePreview,
			clear_draft_ = 0,
			entities_ = Entities,
			parse_mode_ = ParseMode,
		},
	}, Cb or dl_cb, Extra or nil)
end
--------------------------------------------------------------------------------
function getChat(chat_id, dl_cb, cmd)
  tdcli_function ({
    ID = "GetChat",
    chat_id_ = chat_id
  }, dl_cb, cmd)
end
--------------------------------------------------------------------------------
 function delete_msg(chatid,mid)
  tdcli_function ({ID="DeleteMessages", chat_id_=chatid, message_ids_=mid}, dl_cb, nil)
end
--------------------------------------------------------------------------------
function do_notify (user, msg)
	local n = notify.Notification.new(user, msg)
	n:show ()
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function priv(chat,user)
  local owner = redis:sismember('owners:'..chat,user)
  local mod = redis:sismember('mods:'..chat,user)
 if tonumber(SUDO) == tonumber(user) or mod or owner then
   return true
    else
    return false
    end
  end
--------------------------------------------------------------------------------

  function setowner(msg,chat,user)
  local t = '> کاربر <user>'..user..'</user> به لیست مدیر های گروه اضافه شد !'
  reply_to(msg.chat_id_, msg.id_, 1, t, 1, nil,user)
  end
function delowner(msg,chat,user)
  local t = '> کاربر <user>'..user..'</user> از لیست مدیر های گروه حذف شد !'
  reply_to(msg.chat_id_, msg.id_, 1, t, 1, nil,user)
  end
  function promote(msg,chat,user)
  local t = '> کاربر <user>'..user..'</user> به لیست ناظر های گروه اضافه شد !'
  reply_to(msg.chat_id_, msg.id_, 1, t, 1, nil,user)
  end
function demote(msg,chat,user)
  local t = '> کاربر <user>'..user..'</user> از لیست ناظر های گروه حذف شد !'
  reply_to(msg.chat_id_, msg.id_, 1, t, 1, nil,user)
  end
--------------------------------------------------------------------------------
function kick(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      reply_to(msg.chat_id_, msg.id_, 1, '> *شما نمیتوانید دیگر مدیران را اخراج کنید!*', 'md')
    else
  changeChatMemberStatus(chat, user, "Kicked")
    end
  end
--------------------------------------------------------------------------------
function ban(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
reply_to(msg.chat_id_, msg.id_, 1,'> شما نمیتوانید ( ناظران , مالکان , سازندگان ) ربات را #بن کنید !', 1, 'md')
    else
  changeChatMemberStatus(chat, user, "Kicked")
  redis:sadd('banned'..chat,user)
  local t = '> کاربر <user>'..user..'</user> با موفقیت بن شد !'
reply_to(msg.chat_id_, msg.id_, 1, t, 1, nil,user)
  end
  end
--------------------------------------------------------------------------------
function banall(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      reply_to(msg.chat_id_, msg.id_, 1,'> شما نمیتوانید ( ناظران , مالکان , سازندگان ) ربات را #محروم کنید !', 1, 'md')
    else
  changeChatMemberStatus(chat, user, "Kicked")
  redis:sadd('gbaned',user)
  local t = '> کاربر <user>'..user..'</user> با موفقیت از تمامی گروه های ربات بن شد!'
  reply_to(msg.chat_id_, msg.id_, 1, t, 1, nil,user)
  end
  end
--------------------------------------------------------------------------------
function mute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      reply_to(msg.chat_id_, msg.id_, 1, '> شما نمیتوانید ( ناظران , مالکان , سازندگان ) ربات را #بی_صدا کنید', 'md')
    else
  redis:sadd('mutes'..chat,user)
  local t = '> کاربر <user>'..user..'</user> با موفقیت بی صدا شد !'
  reply_to(msg.chat_id_, msg.id_, 1, t, 1, nil,user)
  end
  end
--------------------------------------------------------------------------------
function unban(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   redis:srem('banned'..chat,user)
  local t = '> کاربر <user>'..user..'</user> انبن شد !'
  reply_to(msg.chat_id_, msg.id_, 1, t, 1, nil,user)
  end
--------------------------------------------------------------------------------
function unbanall(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   redis:srem('gbaned',user)
  local t = '> کاربر <user>'..user..'</user> انبن گوبال شد !'
  reply_to(msg.chat_id_, msg.id_, 1, t, 1, nil,user)
  end
--------------------------------------------------------------------------------
function unmute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   redis:srem('mutes'..chat,user)
  local t = '> کاربر <user>'..user..'</user> با صدا شد !'
  reply_to(msg.chat_id_, msg.id_, 1, t, 1, nil,user)
  end
--------------------------------------------------------------------------------
function settings(msg,value,lock) 
local hash = 'settings:'..msg.chat_id_..':'..value
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
elseif value == 'cmd' then
    text = 'دستورات'
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
    else return false
    end
  if lock then
redis:set(hash,true)
local text = '> قفل '..text..' فعال شد.\n> توسط : <user>'..msg.sender_user_id_..'</user>'
reply_to(msg.chat_id_, msg.id_, 1, text, 1, nil,msg.sender_user_id_)
else
  redis:del(hash)
local text = '> قفل '..text..' غیر فعال شد.\n> توسط : <user>'..msg.sender_user_id_..'</user>'
reply_to(msg.chat_id_, msg.id_, 1, text, 1, nil,msg.sender_user_id_)
end
end
--------------------------------------------------------------------------------
function is_lock(msg,value)
 local hash = 'settings:'..msg.chat_id_..':'..value
 if redis:get(hash) then
    return true 
    else
    return false
    end
  end
--------------------------------------------------------------------------------
function warn(msg,chat,user)
  local type = redis:hget("warn:"..msg.chat_id_,"swarn")
  if type == "kick" then
    kick(msg,chat,user)
local text = '> کاربر <user>'..user..'</user> به دلیل دریافت اخطار بیش از حد #کیک شد !'
reply_to(msg.chat_id_, msg.id_, 1, text, 1, nil,user)
    end
  if type == "ban" then
local text = '> کاربر <user>'..user..'</user> به دلیل دریافت اخطار بیش از حد #بن شد !'
reply_to(msg.chat_id_, msg.id_, 1, text, 1, nil,user)
reply_to(msg.chat_id_, msg.id_, 1, Text, 1, nil,user)
redis:sadd('banned'..chat,user)
  end
	if type == "mute" then
local text = '> کاربر <user>'..user..'</user> به دلیل دریافت اخطار بیش از حد #بی_صدا شد !'
reply_to(msg.chat_id_, msg.id_, 1, text, 1, nil,user)
redis:sadd('mutes'..msg.chat_id_,user)
      end
	end
--------------------------------------------------------------------------------
function trigger_anti_spam(msg)
    if is_banned(msg.chat_id_,msg.sender_user_id_) then else
local text = '> کاربر <user>'..getname(msg.sender_user_id_)
..'</user> به دلیل ارسال پیام مکرر از گروه بن شد\nو تمام پیام هایش پاک شد'
reply_to(msg.chat_id_, msg.id_, 1, text, 1, nil,msg.sender_user_id_)
deleteMessagesFromUser(msg.chat_id_, msg.sender_user_id_)
changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
  redis:sadd('banned'..msg.chat_id_,msg.sender_user_id_)
  end
end
--------------------------------------------------------------------------------
function forwardMessages(chat_id, from_chat_id, message_ids, disable_notification)
  tdcli_function ({
    ID = "ForwardMessages",
    chat_id_ = chat_id,
    from_chat_id_ = from_chat_id,
    message_ids_ = message_ids, -- vector
    disable_notification_ = disable_notification,
    from_background_ = 1
  }, dl_cb, nil)
end

--------------------------------------------------------------------------------
function televardump(msg,value)
  local text = json:encode(value)
  reply_to(msg.chat_id_, msg.id_, 1, text, 'md')
  end
--------------------------------------------------------------------------------
function var_cb(msg,data)
function get_gp(arg,data)
   --vardump(data)
  --televardump(msg,data)


    if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        chat_type = 'super'
        elseif id:match('^(%d+)') then
        chat_type = 'user'
        else
        chat_type = 'group'
        end
      end
--------------------------------------------------------------------------------
if msg.sender_user_id_ then
OpenChat(msg.chat_id_)
get_user(msg.sender_user_id_)
end
--------------------------------------------------------------------------------
local text = msg.content_.text_ or  msg.content_.caption_
	if text and text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
		text = text
		end
    --------- messages type -------------------
    if msg.content_.ID == "MessageText" then
      msg_type = 'text'
    end
    if msg.content_.ID == "MessageChatAddMembers" then
      msg_type = 'add'
    end
    if msg.content_.ID == "MessageChatJoinByLink" then
      msg_type = 'join'
    end
    if msg.content_.ID == "MessagePhoto" then
      msg_type = 'photo'
      end
--------------------------------------------------------------------------------
redis:incr("allmsg")
	  if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not redis:sismember("UltraGrandgp",msg.chat_id_) then  
            redis:sadd("UltraGrandgp",msg.chat_id_)
			 -- redis:incrby("g:pa")
        end
        elseif id:match('^(%d+)') then
        if not redis:sismember("usersbot",msg.chat_id_) then
            redis:sadd("usersbot",msg.chat_id_)
			--redis:incrby("pv:mm")
        end
        else
        if not redis:sismember("UltraGrandgp",msg.chat_id_) then
            redis:sadd("UltraGrandgp",msg.chat_id_)
			 -- redis:incrby("g:pa")
        end
     end
    end
--------------------------------------------------------------------------------
if is_sudo(msg) then
if text:match('^leave(-100)(%d+)$') then
       reply_to(msg.chat_id_,msg.id_,1,'> ربات با موفقیت از گروه '..text:match('leave(.*)')..' خارج شد.',1,'md')
       reply_to(text:match('leave(.*)'),0,1,"> ربات به دلایلی گروه را ترک میکند\nبرای اطلاعات بیشتر میتوانید با @GrandDev در ارتباط باشید.",1,'md')
     changeChatMemberStatus(text:match('leave(.*)'), bot_id, "Left")
  end
--------------------------------------------------------------------------------
  if text:match('^plan1(-100)(%d+)$') then
       local timeplan1 = 2592000
       redis:setex("charged:"..text:match('plan1(.*)'),timeplan1,true)
       reply_to(msg.chat_id_,msg.id_,1,'> پلن 1 با موفقیت برای گروه '..text:match('plan1(.*)')..' فعال شد\nاین گروه تا 30 روز دیگر اعتبار دارد! ( 1 ماه )',1,'md')
       reply_to(text:match('plan1(.*)'),0,1,"ربات با موفقیت فعال شد و تا 30 روز دیگر اعتبار دارد!",1,'md')
  end
--------------------------------------------------------------------------------
if text:match('^plan2(-100)(%d+)$') then
      local timeplan2 = 7776000
       redis:setex("charged:"..text:match('plan2(.*)'),timeplan2,true)
       reply_to(msg.chat_id_,msg.id_,1,'> پلن 2 با موفقیت برای گروه '..text:match('plan2(.*)')..' فعال شد\nاین گروه تا 90 روز دیگر اعتبار دارد! ( 3 ماه )',1,'md')
       reply_to(text:match('plan2(.*)'),0,1,"ربات با موفقیت فعال شد و تا 90 روز دیگر اعتبار دارد! ( 3 ماه )",1,'md')
  end
--------------------------------------------------------------------------------
  if text:match('^plan3(-100)(%d+)$') then
       redis:set("charged:"..text:match('plan3(.*)'),true)
       reply_to(msg.chat_id_ ,msg.id_,1,'> پلن 3 با موفقیت برای گروه '..text:match('plan3(.*)')..' فعال شد\nاین گروه به صورت نامحدود شارژ شد!',1,'md')
       reply_to(text:match('plan3(.*)'),0,1,"ربات بدون محدودیت فعال شد ! ( نامحدود )",1,'md')
         
  end
--------------------------------------------------------------------------------
   if text:match('^join(-100)(%d)$') then

addChatMember(text:match('join(.*)'), 335267337, 10)

 reply_to(msg.chat_id_,msg.id_,1,'> rبا موفقیت تورو به گروه '..text:match('join(.*)')..' اضافه کردم.',1,'md')
      
    end
  end
--------------------------------------------------------------------------------
  if chat_type == 'user' and not is_sudo(msg) then
    local text = 'برای خرید ربات روی این متن کلیک نماییید.'
SendMetion(msg.chat_id_, 226283662, msg.id_, text, 27, 0)
    end
--------------------------------------------------------------------------------
--- Start Msg Checks ---
--------------------------------------------------------------------------------
--- Lock Pin ---
--------------------------------------------------------------------------------

  if msg.content_.ID == 'MessagePinMessage' then
 if is_lock(msg,'pin') and is_owner(msg) then
 redis:set('pinned'..msg.chat_id_, msg.content_.message_id_)
  elseif not is_lock(msg,'pin') then
 redis:set('pinned'..msg.chat_id_, msg.content_.message_id_)
 end
 end
   if is_owner(msg) then else
        if msg.content_.ID == 'MessagePinMessage' then
if is_lock(msg,'pin') then
      reply_to(msg.chat_id_, msg.id_, 1, 'قفل پین فعال است \n شما اجازه پین کردن پیامی را ندارید',1, 'md')
       unpin(msg.chat_id_)
          local PinnedMessage = redis:get('pinned'..msg.chat_id_)
          if PinnedMessage then
            pin(msg.chat_id_, tonumber(PinnedMessage),0)
            end
          end
        end
      end
--------------------------------------------------------------------------------
--- Lock Tgservice ---
--------------------------------------------------------------------------------
      if is_mod(msg) then
        else
        if msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" or msg.content_.ID == "MessageChatDeleteMember" then
if is_lock(msg,'tgservice') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
--------------------------------------------------------------------------------
--- Lock Join ---
--------------------------------------------------------------------------------
        if msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" then
      if is_lock(msg,'join') then
  changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
          end
        end
--------------------------------------------------------------------------------
--- Lock Link ---
--------------------------------------------------------------------------------
          if text then
       local is_link = text:find("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or text:find("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or text:find("[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or text:find("[Tt].[Mm][Ee]/")
            if is_link then
if is_lock(msg,'links') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [links]")
              end
            end
        end
--------------------------------------------------------------------------------
--- Lock UserName ---
--------------------------------------------------------------------------------
          if text then
        if text:find("@") then
       if is_lock(msg,'username') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [username]")
        end
            end
        end
--------------------------------------------------------------------------------
--- Lock Tag ---
--------------------------------------------------------------------------------
          if text then
        if text:find("#") then
if is_lock(msg,'tag') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Tag]")
        end
            end
        end
--------------------------------------------------------------------------------
--- Lock Forward ---
--------------------------------------------------------------------------------
		if msg.forward_info_ ~= false then
        if is_lock(msg,'forward') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [forward]")
          end
          end
--------------------------------------------------------------------------------
--- Lock Photo ---
--------------------------------------------------------------------------------
          if msg.content_.ID == 'MessagePhoto' then
        if is_lock(msg,'photo') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Photo]")
          end
        end 
--------------------------------------------------------------------------------
--- Lock File ---
--------------------------------------------------------------------------------
          if msg.content_.ID == 'MessageDocument' then
        if is_lock(msg,'file') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [File]")
          end
        end
--------------------------------------------------------------------------------
--- Lock Keyboard ---
--------------------------------------------------------------------------------
       if tonumber(msg.via_bot_user_id_) ~= 0 then
       if is_lock(msg,'keyboard') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [keyboard]")
          end
        end 
-------------------------------------------------------------------------------
--- Lock Game ---
--------------------------------------------------------------------------------
        if is_lock(msg,'game') then
         if msg.content_.game_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Game]")
          end
        end 
    
-------------------------------------------------------------------------------
--- Lock Audio ---
--------------------------------------------------------------------------------
 if is_lock(msg,'audio') then
          if msg.content_.ID == 'MessageAudio' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [audio]")
            end
          end
-------------------------------------------------------------------------------
--- Lock Voice ---
--------------------------------------------------------------------------------
        if is_lock(msg,'voice') then
if msg.content_.ID == 'MessageVoice' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Voice]")
            end
          end
-------------------------------------------------------------------------------
--- Lock Gif ---
--------------------------------------------------------------------------------
        if is_lock(msg,'gif') then
          if msg.content_.ID == 'MessageAnimation' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Gif]")
            end
          end 
-------------------------------------------------------------------------------
--- Lock Sticker ---
--------------------------------------------------------------------------------
if is_lock(msg,'sticker') then
          if msg.content_.ID == 'MessageSticker' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Sticker]")
            end
          end 
-------------------------------------------------------------------------------
--- Lock Contact ---
--------------------------------------------------------------------------------
        if is_lock(msg,'contact') then
          if msg.content_.ID == 'MessageContact' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Contact]")
            end
          end
-------------------------------------------------------------------------------
--- Lock Video ---
--------------------------------------------------------------------------------
if is_lock(msg,'video') then
          if msg.content_.ID == 'MessageVideo' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Video]")
           end
          end
-------------------------------------------------------------------------------
--- Lock Fosh ---
--------------------------------------------------------------------------------
 if is_lock(msg,'fosh') then
local is_fosh_msg = text:find("کیر") or text:find("کس") or text:find("کون") or text:find("85") or text:find("جنده") or text:find("ننه") or text:find("ننت") or text:find("مادر") or text:find("قهبه") or text:find("گایی") or text:find("سکس") or text:find("kir") or text:find("kos") or text:find("kon") or text:find("nne") or text:find("nnt")
  if is_fosh_msg then
    delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Fosh]")
  end
end
-------------------------------------------------------------------------------
--- Lock Emoji ---
--------------------------------------------------------------------------------
if is_lock(msg,'emoji') then
  local is_emoji_msg = text:find("😀") or text:find("😬") or text:find("😁") or text:find("😂") or  text:find("😃") or text:find("😄") or text:find("😅") or text:find("☺️") or text:find("🙃") or text:find("🙂") or text:find("😊") or text:find("😉") or text:find("😇") or text:find("😆") or text:find("😋") or text:find("😌") or text:find("😍") or text:find("😘") or text:find("😗") or text:find("😙") or text:find("😚") or text:find("🤗") or text:find("😎") or text:find("🤓") or text:find("🤑") or text:find("😛") or text:find("😏") or text:find("😶") or text:find("😐") or text:find("😑") or text:find("😒") or text:find("🙄") or text:find("🤔") or text:find("😕") or text:find("😔") or text:find("😡") or text:find("😠") or text:find("😟") or text:find("😞") or text:find("😳") or text:find("🙁") or text:find("☹️") or text:find("😣") or text:find("😖") or text:find("😫") or text:find("😩") or text:find("😤") or text:find("😲") or text:find("😵") or text:find("😭") or text:find("😓") or text:find("😪") or text:find("😥") or text:find("😢") or text:find("🤐") or text:find("😷") or text:find("🤒") or text:find("🤕") or text:find("😴") or text:find("💋") or text:find("❤️")
  if is_emoji_msg then
    delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [emoji]")
  end
end
-------------------------------------------------------------------------------
--- Lock Selfvideo ---
-------------------------------------------------------------------------------- 
if is_lock(msg,'selfvideo') then
         if msg.content_.ID == "MessageUnsupported" then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Selfvideo]")
           end
          end
-------------------------------------------------------------------------------
--- Lock Text ---
-------------------------------------------------------------------------------- 
if is_lock(msg,'text') then
          if msg.content_.ID == 'MessageText' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Text]")
            end
          end
-------------------------------------------------------------------------------
--- Check Mute ---
-------------------------------------------------------------------------------- 
      if msg.sender_user_id_ and is_muted(msg.chat_id_,msg.sender_user_id_) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [MuteUser]")
      end
 -------------------------------------------------------------------------------
--- Lock Persian ---
-------------------------------------------------------------------------------- 
        if is_lock(msg,'persian') then
          if text:find('[ضصثقفغعهخحجچپشسیبلاتنمکگظطزرذدئو]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [Persian]")
            end 
        end
 -------------------------------------------------------------------------------
--- Lock english ---
-------------------------------------------------------------------------------- 
        if is_lock(msg,'english') then
          if text:find('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [english]")
            end 
end
 -------------------------------------------------------------------------------
--- Lock Bot ---
-------------------------------------------------------------------------------- 
        if is_lock(msg,'bot') then
       if msg.content_.ID == "MessageChatAddMembers" then
            if msg.content_.members_[0].type_.ID == 'UserTypeBot' then
        kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
print("kick [Lock] [bot]")
              end
            end
          end
      end

 -------------------------------------------------------------------------------
--- Lock All ---
-------------------------------------------------------------------------------- 
      local muteall = redis:get('muteall'..msg.chat_id_)
      if msg.sender_user_id_ and muteall and not is_mod(msg) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
print("Deleted [Lock] [All]")
      end
-------------------------------------------------------------------------------
--- Anti Spam ---
-------------------------------------------------------------------------------- 
  if chat_type == 'super' then
      NUM_MSG_MAX = redis:get('floodmax'..msg.chat_id_) or 5
      TIME_CHECK = redis:get('floodtime'..msg.chat_id_) or 3
if is_lock(msg,'flood') then
if not is_mod(msg) then
	local post_count = tonumber(redis:get('floodc:'..msg.sender_user_id_..':'..msg.chat_id_) or 0)
	if post_count > tonumber(redis:get('floodmax'..msg.chat_id_) or 5) then

         trigger_anti_spam(msg)
 end
	redis:setex('floodc:'..msg.sender_user_id_..':'..msg.chat_id_, tonumber(redis:get('floodtime'..msg.chat_id_) or 3), post_count+1)
end
end
-------------------------------------------------------------------------------
--- Check Filter ---
-------------------------------------------------------------------------------- 
    if text and not is_mod(msg) then
     if is_filter(msg,text) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end 
    end
 -------------------------------------------------------------------------------
--- Check bans ---
-------------------------------------------------------------------------------- 
    if msg.sender_user_id_ and is_banned(msg.chat_id_,msg.sender_user_id_) then
      kick(msg,msg.chat_id_,msg.sender_user_id_)
      end
    if msg.content_ and msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].id_ and is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
      end
if msg.sender_user_id_ and is_gban(msg.chat_id_,msg.sender_user_id_) then
      kick(msg,msg.chat_id_,msg.sender_user_id_)
      end
    if msg.content_ and msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].id_ and is_gban(msg.chat_id_,msg.content_.members_[0].id_) then
      kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
      end
 -------------------------------------------------------------------------------
--- Welcome ---
-------------------------------------------------------------------------------- 
			    if msg.content_.ID == "MessageChatJoinByLink" then
        if not is_banned(msg.chat_id_,msg.sender_user_id_) then
local status_welcome = (redis:get('status:welcome:'..msg.chat_id_) or 'disable') 
    if status_welcome == 'enable' then
     function wlc(extra,result,success)
        if redis:get('welcome:'..msg.chat_id_) then
        t = redis:get('welcome:'..msg.chat_id_)
        else
        t = 'سلام <name>\nبه گروه خوش اومدی !'
        end
      local t = t:gsub('<name>',result.first_name_)
          reply_to(msg.chat_id_, msg.id_, 1, t, 1, 'md')
          end
        getUser(msg.sender_user_id_,wlc)
      end
        end
        if msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].type_.ID == 'UserTypeGeneral' then

    if msg.content_.ID == "MessageChatAddMembers" then
      if not is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      if redis:get('welcome:'..msg.chat_id_) then
        t = redis:get('welcome:'..msg.chat_id_)
        else
               t = 'سلام <name>\nبه گروه خوش اومدی !'
        end
      local t = t:gsub('<name>',msg.content_.members_[0].first_name_)
             reply_to(msg.chat_id_, msg.id_, 1, t, 1, 'md')
      end
        end
          end
      end
--------------------------------------------------------------------------------
--- End Msg Checks ---
--------------------------------------------------------------------------------
     if text and is_mod(msg) then
      local lock = text:match('^lock pin$') or text:match('^قفل پین$')
       local unlock = text:match('^unlock pin$') or text:match('^بازكردن پين$')
      if lock then
          settings(msg,'pin','lock')
          end
        if unlock then
          settings(msg,'pin')
        end 
--------------------------------------------------------------------------------
local lock = text:match('^lock links$') or text:match('^قفل لینک$')
       local unlock = text:match('^unlock links$') or text:match('^بازکردن لینک$')
      if lock then
          settings(msg,'links','lock')
          end
        if unlock then
          settings(msg,'links')
        end
     
--------------------------------------------------------------------------------
local lock = text:match('^lock fosh$') or text:match('^قفل فحش$')
       local unlock = text:match('^unlock fosh$') or text:match('^بازكردن فحش$')
      if lock then
          settings(msg,'fosh','lock')
          end
        if unlock then
          settings(msg,'fosh')
        end 
--------------------------------------------------------------------------------
local lock = text:match('^lock emoji$') or text:match('^قفل ایموجی$')
       local unlock = text:match('^unlock emoji$') or text:match('^بازکردن ایموجی$')
      if lock then
          settings(msg,'emoji','lock')
          end
        if unlock then
          settings(msg,'emoji')
        end
     
--------------------------------------------------------------------------------
local lock = text:match('^lock join$') or text:match('^قفل جوین$')
       local unlock = text:match('^unlock join$') or text:match('^بازكردن جوين$')
      if lock then
          settings(msg,'join','lock')
          end
        if unlock then
          settings(msg,'join')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock flood$') or text:match('^قفل رگبار$')
       local unlock = text:match('^unlock flood$') or text:match('^بازكردن رگبار$')
      if lock then
          settings(msg,'flood','lock')
          end
        if unlock then
          settings(msg,'flood')
        end
--------------------------------------------------------------------------------
local lock = text:match('^lock tag$') or text:match('^قفل تگ$')
       local unlock = text:match('^unlock tag$') or text:match('^بازكردن تگ$')
      if lock then
          settings(msg,'tag','lock')
          end
        if unlock then
          settings(msg,'tag')
        end
--------------------------------------------------------------------------------
local lock = text:match('^lock edit$') or text:match('^قفل ادیت$')
       local unlock = text:match('^unlock edit$') or text:match('^بازکردن ادیت$')
      if lock then
          settings(msg,'edit','lock')
          end
        if unlock then
          settings(msg,'edit')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock file$') or text:match('^قفل فایل$')
       local unlock = text:match('^unlock file$') or text:match('^بازكردن فايل$')
      if lock then
          settings(msg,'file','lock')
          end
        if unlock then
          settings(msg,'file')
        end
--------------------------------------------------------------------------------
local lock = text:match('^lock keyboard$') or text:match('^قفل کیبورد اینلاین$')
       local unlock = text:match('^unlock keyboard$') or text:match('^بازكردن كيبورد اينلاين$')
      if lock then
          settings(msg,'keyboard','lock')
          end
        if unlock then
          settings(msg,'keyboard')
        end
       
 --------------------------------------------------------------------------------
local lock = text:match('^lock game$') or text:match('^قفل بازی$')
       local unlock = text:match('^unlock game$') or text:match('^بازكردن بازی$')
      if lock then
          settings(msg,'game','lock')
          end
        if unlock then
          settings(msg,'game')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock username$') or text:match('^قفل یوزرنیم$')
       local unlock = text:match('^unlock username$') or text:match('^بازكردن يوزرنيم$')
      if lock then
          settings(msg,'username','lock')
          end
        if unlock then
          settings(msg,'username')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock photo$') or text:match('^قفل عکس$')
       local unlock = text:match('^unlock photo$') or text:match('^بازكردن عكس$')
      if lock then
          settings(msg,'photo','lock')
          end
        if unlock then
          settings(msg,'photo')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock gifs$') or text:match('^قفل گیف$')
       local unlock = text:match('^unlock gifs$') or text:match('^بازكردن گيف$')
      if lock then
          settings(msg,'gif','lock')
          end
        if unlock then
          settings(msg,'gif')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock video$') or text:match('^قفل فیلم$')
       local unlock = text:match('^unlock video$') or text:match('^بازكردن فيلم$')
      if lock then
          settings(msg,'video','lock')
          end
        if unlock then
          settings(msg,'video')
        end
--------------------------------------------------------------------------------
local lock = text:match('^lock selfvideo$') or text:match('^قفل فیلم سلفی$')
       local unlock = text:match('^unlock selfvideo$') or text:match('^بازكردن فيلم سلفي$')
      if lock then
          settings(msg,'selfvideo','lock')
          end
        if unlock then
          settings(msg,'selfvideo')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock voice$') or text:match('^قفل ویس$')
       local unlock = text:match('^unlock voice$') or text:match('^بازكردن ويس$')
      if lock then
          settings(msg,'voice','lock')
          end
        if unlock then
          settings(msg,'voice')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock audio$') or text:match('^قفل اهنگ$')
       local unlock = text:match('^unlock audio$') or text:match('^بازكردن اهنگ$')
      if lock then
          settings(msg,'music','lock')
          end
        if unlock then
          settings(msg,'music')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock text$') or text:match('^قفل متن$')
       local unlock = text:match('^unlock text$') or text:match('^بازكردن متن$')
      if lock then
          settings(msg,'text','lock')
          end
        if unlock then
          settings(msg,'text')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock sticker$') or text:match('^قفل استیکر$')
       local unlock = text:match('^unlock sticker$') or text:match('^بازكردن استيكر$')
      if lock then
          settings(msg,'sticker','lock')
          end
        if unlock then
          settings(msg,'sticker')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock contacts$') or text:match('^قفل مخاطب$')
       local unlock = text:match('^unlock contacts$') or text:match('^بازكردن مخاطب$')
      if lock then
          settings(msg,'contact','lock')
          end
        if unlock then
          settings(msg,'contact')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock fwd$') or text:match('^قفل فوروارد$')
       local unlock = text:match('^unlock fwd$') or text:match('^بازكردن فوروارد$')
      if lock then
          settings(msg,'forward','lock')
          end
        if unlock then
          settings(msg,'forward')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock tgservice$') or text:match('^قفل سرویس تلگرام$')
       local unlock = text:match('^unlock tgservice$') or text:match('^بازكردن سروس تلگرام$')
      if lock then
          settings(msg,'tgservice','lock')
          end
        if unlock then
          settings(msg,'tgservice')
        end
       
   --------------------------------------------------------------------------------
local lock = text:match('^lock english$') or text:match('^قفل انگلیسی$')
       local unlock = text:match('^unlock english$') or text:match('^بازكردن انگليسي$')
      if lock then
          settings(msg,'english','lock')
          end
        if unlock then
          settings(msg,'english')
        end
       
   --------------------------------------------------------------------------------
local lock = text:match('^lock persian$') or text:match('^قفل فارسی$')
       local unlock = text:match('^unlock persian$') or text:match('^بازكردن فارسي$')
      if lock then
          settings(msg,'persian','lock')
          end
        if unlock then
          settings(msg,'persian')
        end
       
--------------------------------------------------------------------------------
local lock = text:match('^lock bots$') or text:match('^قفل ربات$')
       local unlock = text:match('^unlock bots$') or text:match('^بازكردن ربات$')
      if lock then
          settings(msg,'bot','lock')
          end
        if unlock then
          settings(msg,'bot')
        end
      end 
   
--------------------------------------------------------------------------------
    if text then
      if is_sudo(msg) then
--------------------------------------------------------------------------------
local text = text:gsub("تنظیم لقب", "setrank")
 if text:match('^setrank (.*)') then
        local rank = text:match('setrank (.*)')
        function setrank(extra, result, success)
        redis:set('ranks:'..result.sender_user_id_, rank)
local text = '> لقب کاربر '..result.sender_user_id_..' به '..rank..' تغیر یافت'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 12, string.len(result.sender_user_id_))
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
          getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),setrank)  
          end
        end
--------------------------------------------------------------------------------
 if text:match('^rank$') or text:match('^لقب$') then
  function getrank(extra, result, success)
       local rank =  redis:get('ranks:'..result.sender_user_id_) or 'ست نشده'
reply_to(msg.chat_id_, msg.id_, 1,''..rank..'',1,'md') 
end
if tonumber(msg.reply_to_message_id_) == 0 then
else 
getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),getrank)  
        end
end
--------------------------------------------------------------------------------
   if text:match('^setend (.*)') then
            local endmsg = text:match('^setend (.*)')
redis:set('endmsg',endmsg)
        reply_to(msg.chat_id_, msg.id_, 1,'*> انجام شد !*', 1, 'md')
            end
--------------------------------------------------------------------------------
if text:match('^gplist$') or text:match('^لیست گروه ها$') then
local list = redis:smembers("UltraGrandgp")
          local t = '> *لیست گروه های ربات:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - {`"..v.."`}\n" 
          end
          if #list == 0 then
          t = '> *لیست گروه های ربات خالی میباشد!*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
if text == 'del end' then
redis:del('endmsg',endmsg)
        reply_to(msg.chat_id_, msg.id_, 1,'*> انجام شد !*', 1, 'md')
            end
--------------------------------------------------------------------------------
local text = text:gsub("محروم", "gban")
        if text == 'gban' then
		if msg.reply_to_message_id_ == 0 then
        local user = msg.sender_user_id_
        else
        function banreply(extra, result, success)
        banall(msg,msg.chat_id_,result.sender_user_id_)
          end
		  end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),banreply)
        end
		      if text:match('^gban (%d+)') then
        banall(msg,msg.chat_id_,text:match('^gban (%d+)'))
        end
--------------------------------------------------------------------------------
      if text:match('^gban @(.*)') then
        local username = text:match('gban @(.*)')
        function banusername(extra,result,success)
          if result.id_ then
            banall(msg,msg.chat_id_,result.id_)
            else 
            text = '> *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,banusername)
        end
--------------------------------------------------------------------------------
local text = text:gsub("رفع محروميت", "ungban")
        if text == 'ungban' then
		if msg.reply_to_message_id_ == 0 then
        local user = msg.sender_user_id_
		else
        function unbanreply(extra, result, success)
        unbanall(msg,msg.chat_id_,result.sender_user_id_)
          end
		  end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unbanreply)
        end	
--------------------------------------------------------------------------------
      if text:match('^ungban (%d+)') then
        unbanall(msg,msg.chat_id_,text:match('ungban (%d+)'))
        end
      if text:match('^ungban @(.*)') then
        local username = text:match('ungban @(.*)')
        function unbanusername(extra,result,success)
          if result.id_ then
            unbanall(msg,msg.chat_id_,result.id_)
            else 
            text = '> *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,unbanusername)
        end
--------------------------------------------------------------------------------
       if text == 'leave' or text == 'لفت'then
            changeChatMemberStatus(msg.chat_id_, bot_id, "Left")
          end
--------------------------------------------------------------------------------
if text == 'bc' or text == 'ارسال' and tonumber(msg.reply_to_message_id_) > 0 then
          function cb(a,b,c)
          local text = b.content_.text_
          local list = redis:smembers("UltraGrandgp")
          for k,v in pairs(list) do
        reply_to(v, 0, 1, text,1, 'md')
          end
          end
          getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),cb)
          end
--------------------------------------------------------------------------------
        if text == 'fbc' or text == 'فوروارد' and tonumber(msg.reply_to_message_id_) > 0 then
          function cb(a,b,c)
          local list = redis:smembers("UltraGrandgp")
          for k,v in pairs(list) do
          forwardMessages(v, msg.chat_id_, {[0] = b.id_}, 1)
          end
          end
          getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),cb)
          end
--------------------------------------------------------------------------------
if text == 'msg_id'or text == 'ايدي پيام' then
function msgid(extra, result, success)
 reply_to(msg.chat_id_, msg.id_, 1,'`'..result.id_..'`', 1, 'md')
end
 if tonumber(msg.reply_to_message_id_) == 0 then
 else
 getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),msgid)
end
end
--------------------------------------------------------------------------------
if text == 'ليست افراد محروم' or text == 'gbanlist' then
          local list = redis:smembers('gbaned')
          local t = '> *لیست افراد محروم از گروه های ربات:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '> *لیست افراد محروم از گروه های ربات خالی میباشد!*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
if text:match("^dump$") and is_sudo(msg) then
function vp(extra, result, success)
reply_to(msg.chat_id_, msg.id_, 1, ''..serpent.block(result, {comment=false})..'', 1, 'html')
  end
 if tonumber(msg.reply_to_message_id_) == 0 then
          else
   getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),vp)  
      end
        end
--------------------------------------------------------------------------------
if text:match("^test$") or text:match("^تست$") and is_sudo(msg) then
Text = "✖️ کاربر "..msg.from.username.." ، پیام شما به دلیل طولانی بودن حذف شد."
reply_to(msg.chat_id_, msg.id_, 1, Text, 1, 'html')

end
if text:match("^add$") or text:match("^فعال$") and is_sudo(msg) then
if redis:sismember('add', msg.chat_id_) then
redis:set("groupc:"..msg.chat_id_,true)
reply_to(msg.chat_id_, msg.id_, 1, '> گروه [`'..data.title_..'`] از قبل در لیست گروه های تحت مدیریت ربات است !', 1, 'md')
else
redis:sadd('add', msg.chat_id_)
redis:set("groupc:"..msg.chat_id_,true)
reply_to(msg.chat_id_, msg.id_, 1, '> گروه [`'..data.title_..'`] به لیست گروه های تحت مدیریت ربات اضافه شد !\n> توسط : '..get_username(msg.sender_user_id_)..'', 1, 'md')
       end
end
--------------------------------------------------------------------------------
if text:match("^rem$") or text:match("^حذف$") and is_sudo(msg) then
if not redis:sismember('add', msg.chat_id_) then
reply_to(msg.chat_id_, msg.id_, 1, '> گروه [`'..data.title_..'`] در لیست گروه های تحت مدیریت ربات نیست !', 1, 'md')
else
redis:srem('add', msg.chat_id_)
redis:del("groupc:"..msg.chat_id_,true)
reply_to(msg.chat_id_, msg.id_, 1, '> گروه [`'..data.title_..'`] از لیست گروه های تحت مدیریت ربات حذف شد \n> توسط : '..get_username(msg.sender_user_id_)..'!', 1, 'md')
end
end
--------------------------------------------------------------------------------
local text = text:gsub("شارژ", "charge")
if text:match('^charge (%d+)$') then 
          local gp = text:match('charge (%d+)')
		 local time = gp * day
		   redis:setex("groupc:"..msg.chat_id_,time,true)
 reply_to(msg.chat_id_, msg.id_, 1,'> ربات با موفقیت تنظیم شد\nمدت فعال بودن ربات در گروه به '..text:match('charge (.*)')..' روز دیگر تنظیم شد...',1,'md') 
end
--------------------------------------------------------------------------------
local text = text:gsub("تنظيم مدیر", "setowner")
        if text:match("^setowner$") then
          function prom_reply(extra, result, success)
        redis:sadd('owners:'..msg.chat_id_,result.sender_user_id_)
         setowner(msg,msg.chat_id_,result.sender_user_id_)
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
--------------------------------------------------------------------------------
        if text:match('^setowner (%d+)') then
          local user = text:match('setowner (%d+)')
          redis:sadd('owners:'..msg.chat_id_,user)
setowner(msg,msg.chat_id_,user)
        end
--------------------------------------------------------------------------------
local text = text:gsub("حذف مدیر", "deowner")
        if text:match("^delowner$") then
        function prom_reply(extra, result, success)
        redis:srem('owners:'..msg.chat_id_,result.sender_user_id_)
delowner(msg,msg.chat_id_,result.sender_user_id_)
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
--------------------------------------------------------------------------------
        if text:match('^delowner (%d+)') then
          local user = text:match('deowner (%d+)')
         redis:srem('owners:'..msg.chat_id_,user)
        delowner(msg,msg.chat_id_,user)
      end
        end
--------------------------------------------------------------------------------
      if text == 'clean owners' or text == 'clean ownerlist' then
        redis:del('owners:'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'> *لیست #مالکین_گروه با موفقیت حذف شد. *', 1, 'md')
        end
--------------------------------------------------------------------------------
  if text == 'init' or text == 'بروز' and is_sudo(msg) then
       dofile('./bot.lua') 
io.popen("rm -rf .telegram-cli/data/animation/*")
io.popen("rm -rf .telegram-cli/data/audio/*")
io.popen("rm -rf .telegram-cli/data/document/*")
io.popen("rm -rf .telegram-cli/data/photo/*")
io.popen("rm -rf .telegram-cli/data/sticker/*")
io.popen("rm -rf .telegram-cli/data/temp/*")
io.popen("rm -rf .telegram-cli/data/video/*")
io.popen("rm -rf .telegram-cli/data/voice/*")
io.popen("rm -rf .telegram-cli/data/profile_photo/*")
reply_to(msg.chat_id_, msg.id_, 1,'*> سیستم ربات بروز شد !*\n> حافظه کش ربات پاکسازی شد !', 1, 'md')
  end
--------------------------------------------------------------------------------
	    if text:match("^stats$") and is_sudo(msg) then
   local upt = UpTime()
local gps = redis:scard("UltraGrandgp")
	local users = redis:scard("usersbot")

					reply_to(msg.chat_id_, msg.id_, 1, "> امار ربات الترا گرند :\n\n> کاربران : <code>"..users.."</code>\n> گروه ها : <code>"..gps.."</code>\n> آپتایم : "..upt.."", 1, 'html')
	end 
--------------------------------------------------------------------------------
     if is_owner(msg) then
        if text == 'clean bots' or text == 'حذف ربات ها' then
      local function cb(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          kick(msg,msg.chat_id_,bots[i].user_id_)
          end
        end
       channel_get_bots(msg.chat_id_,cb)
       end
--------------------------------------------------------------------------------
local text = text:gsub("تنظیم لینک", "setlink")
          if text:match('^setlink https://t.me/joinchat/(.*)') and is_owner(msg) then
  local l = text:match('setlink https://t.me/joinchat/(.*)')
  redis:set('grouplink'..msg.chat_id_, l)
  reply_to(msg.chat_id_, msg.id_, 1,'> #لینک گروه اپدیت شد !', 1, 'md')
end
--------------------------------------------------------------------------------
          if text == 'clean link' or text == 'حذف لینک' then
            redis:del('grouplink'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'> لینک گروه #حذف شد !', 1, 'md')
            end
--------------------------------------------------------------------------------
local text = text:gsub("تنظیم قوانین", "setrules")
if text:match('^setrules (.*)') then
            local rules = text:match('setrules (.*)')
if (#rules > 500) or (#rules < 10) then
			if #rules > 500 then
				stats = "_تعداد حروف متن خود را جهت تنظیم قوانین کاهش دهید._"
			else
				stats = "_تعداد حروف متن خود را جهت تنظیم قوانین افزایش دهید._"
			end
			text = "> محدوده تعداد کاراکتر ها برای تنظیم قوانین گروه از `10` تا `500` کاراکتر میباشد!\nتعداد کاراکتر های متن شما : `"..#rules.."`\n"..stats
			reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
            redis:set('grouprules'..msg.chat_id_, rules)
    reply_to(msg.chat_id_, msg.id_, 1,'> #قوانین گروه اپدیت شد !', 1, 'md')
            end
end
--------------------------------------------------------------------------------
          if text == 'clean rules' or text == 'حذف قوانین' then
            redis:del('grouprules'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'> قوانین گروه #حذف شد !', 1, 'md')
            end
--------------------------------------------------------------------------------
local text = text:gsub("تنظیم اسم", "setname")
            if text:match('^setname (.*)') then
            local name = text:match('^setname (.*)')
            changeChatTitle(msg.chat_id_, name)
            end
--------------------------------------------------------------------------------
        if text:match("^wlc on$") then
          redis:set('status:welcome:'..msg.chat_id_,'enable')
          reply_to(msg.chat_id_, msg.id_, 1,'> *ارسال پیام خوش آمدگویی فعال شد.*', 1, 'md')
          end
--------------------------------------------------------------------------------
        if text:match("^wlc off$") then
          redis:set('status:welcome:'..msg.chat_id_,'disable')
          reply_to(msg.chat_id_, msg.id_, 1,'> *ارسال پیام خوش آمدگویی غیرفعال شد.*', 1, 'md')
          end
--------------------------------------------------------------------------------
local text = text:gsub("تنظیم پیام خوش امد گویی", "setwelcome")
        if text:match('^setwelcome (.*)') then
          local welcome = text:match('^setwelcome (.*)')
          redis:set('welcome:'..msg.chat_id_,welcome)
           local t = '> *پیغام خوش آمدگویی با موفقیت ذخیره شد.*'
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
          end
--------------------------------------------------------------------------------
        if text == 'rest welcome' then
          redis:del('welcome:'..msg.chat_id_,welcome)
          reply_to(msg.chat_id_, msg.id_, 1,'> *پیغام خوش آمدگویی بازنشانی گردید و به حالت پیشفرض تنظیم شد.*', 1, 'md')
          end
--------------------------------------------------------------------------------
        if text == 'لیست مالکان' or text == 'ownerlist' then
          local list = redis:smembers('owners:'..msg.chat_id_)
          local t = '> *لیست مالکین گروه:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '> *لیست مالکان گروه خالی میباشد!*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
local text = text:gsub("تنظیم ناظر", "promote")
    	if text:match("^(promote)$") then
        function prom_reply(extra, result, success)
        redis:sadd('mods:'..msg.chat_id_,result.sender_user_id_)
promote(msg,msg.chat_id_,result.sender_user_id_)
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
--------------------------------------------------------------------------------
        if text:match('^promote @(.*)') then
        local username = text:match('^promote @(.*)')
        function promreply(extra,result,success)
          if result.id_ then
        redis:sadd('mods:'..msg.chat_id_,result.id_)
       promote(msg,msg.chat_id_,result.id_)
            else 
reply_to(msg.chat_id_, msg.id_, 1,'> *کاربر مورد نظر یافت نشد*', 1, 'md')
            end
SendMetion(msg.chat_id_, result.id_, msg.id_, text, 8, string.len(result.id_))
          end
        resolve_username(username,promreply)
        end
--------------------------------------------------------------------------------
        if text:match('^promote (%d+)') then
          local user = text:match('promote (%d+)')
          redis:sadd('mods:'..msg.chat_id_,user)
        promote(msg,msg.chat_id_,user)
      end
--------------------------------------------------------------------------------
local text = text:gsub("حذف ناظر", "demote")
        	if text:match("^(demote)$") then
        function prom_reply(extra, result, success)
        redis:srem('mods:'..msg.chat_id_,result.sender_user_id_)
demote(msg,msg.chat_id_,result.sender_user_id_)
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
--------------------------------------------------------------------------------
        if text:match('^demote @(.*)') then
        local username = text:match('^demote @(.*)')
        function demreply(extra,result,success)
          if result.id_ then
        redis:srem('mods:'..msg.chat_id_,result.id_)
demote(msg,msg.chat_id_,result.id_)
            else 
            reply_to(msg.chat_id_, msg.id_, 1,'> *کاربر مورد نظر یافت نشد*', 1, 'md')
            end
           SendMetion(msg.chat_id_, result.id_, msg.id_, text, 8, string.len(result.id_))
          end
        resolve_username(username,demreply)
        end
--------------------------------------------------------------------------------
     if text == 'clean deleted' or text == "حذف دلیت اکانتی ها" and is_owner(msg) then
 local function deleteaccounts(extra, result)
    for k,v in pairs(result.members_) do 
local function cleanaccounts(extra, result)
if not result.first_name_ then
changeChatMemberStatus(msg.chat_id_, result.id_, "Kicked")
end
end
getUser(v.user_id_, cleanaccounts, nil)
 end 
reply_to(msg.chat_id_, msg.id_, 1,'> کاربران #دیلیت_اکانت شده از گروه حذف شد !', 1, 'md')
  end 
  tdcli_function ({ID = "GetChannelMembers",channel_id_ = getChatId(msg.chat_id_).ID,offset_ = 0,limit_ = 1096500}, deleteaccounts, nil)
  end
--------------------------------------------------------------------------------
if text == 'clean kicked' or text == "حذف لیست مسدود ها" and is_owner(msg) then
    local function removeblocklist(extra, result)
      if tonumber(result.total_count_) == 0 then 
        reply_to(msg.chat_id_, msg.id_, 0,'> کاربری در لیست مسدودی گروه شما قرار ندارد.', 1, 'md')
      else
      local x = 0
      for x,y in pairs(result.members_) do
        x = x + 1
        changeChatMemberStatus(msg.chat_id_, y.user_id_, 'Left', dl_cb, nil)
  end
    reply_to(msg.chat_id_, msg.id_, 0,'> تمامی کاربران لیست مسدودی گروه گروه حذف شد', 1, 'md')
    end
 end
  getChannelMembers(msg.chat_id_, 0, 'Kicked', 200, removeblocklist, {chat_id_ = msg.chat_id_, msg_id_ = msg.id_}) 
  end   
--------------------------------------------------------------------------------
if text:match('^demote (%d+)') then
          local user = text:match('demote (%d+)')
         redis:srem('mods:'..msg.chat_id_,user)
demote(msg,msg.chat_id_,user)
      end
  end
      end
--------------------------------------------------------------------------------
	if text == 'expire' or text == "انقضا" and is_owner(msg) then
    local ex = redis:ttl("groupc:"..msg.chat_id_)
       if ex == -1 then
		reply_to(msg.chat_id_, msg.id_, 1,'> تاریخ انقضا برای گروه شما ثبت نشده است و مدت زمان گروه شما نامحدود میباشد', 1, 'md')
       else
        local expire = math.floor(ex / day ) + 1
			reply_to(msg.chat_id_, msg.id_, 1,"> ["..expire.."] روز تا پایان مدت زمان انتقضا گروه باقی مانده است.", 1, 'md') 
       end
    end
--------------------------------------------------------------------------------
   if is_mod(msg) then
      local function getsettings(value)
       if value == "charge" then
       local ex = redis:ttl("groupc:"..msg.chat_id_)
      if ex == -1 then
        return "نامحدود"
       else
        local d = math.floor(ex / day ) + 1
        return "["..d.."] روز !"
       end
elseif value == 'muteall' then
        local h = redis:ttl('muteall'..msg.chat_id_)
       if h == -1 then
        return '(✔️)'
				elseif h == -2 then
			  return '(✖️)'
       else
        return "تا ["..h.."] ثانیه دیگر فعال است"
       end
        elseif value == 'welcome' then
        local hash = redis:get('status:welcome:'..msg.chat_id_)
        if hash == 'enable' then
           return '(✔️)'
          else
          return '(✖️)'
          end
        elseif is_lock(msg,value) then
           return '(✔️)'
          else
          return '(✖️)'
       end
        end
-------------------------------------------------------------------------------------------
      if text:match("^setting$") or text:match("^تنظیمات$") then
        local setting = 'تنظيمات گروه عبارتند از : '
..'\n'
..'\n\n> قـفـل رگبار : '..getsettings('flood')..''
..'\n\n> تعداد رگبار : '..NUM_MSG_MAX..''
..'\n\n> زمان رگبار :  '..TIME_CHECK..''
..'\n\n> قـفـل لینڪ : '..getsettings('links')..''
..'\n\n> قـفـل فوروارد : '..getsettings('forward')..''
..'\n\n> قـفـل تـ#ـگ : '..getsettings('tag')..''
..'\n\n> قـفـل یوزرنـ@ـیم : '..getsettings('username')..''
..'\n\n> قـفـل فـحـش : '..getsettings('fosh')..''
..'\n\n> قـفـل ایـمـوجے : '..getsettings('emoji')..''
..'\n\n> قـفـل مـخـاطـب : '..getsettings('contact')..''
..'\n\n> قفل سـنـجـاق : '..getsettings('pin')..''
..'\n\n> قـفـل دسـتـورات : '..getsettings('cmd')..''
..'\n\n> قـفـل ربـات : '..getsettings('bot')..''
..'\n\n> قـفـل بـازی : '..getsettings('game')..''
..'\n\n> قـفـل فـارسـی : '..getsettings('persian')..''
..'\n\n> قـفـل انـگـلیـسـی : '..getsettings('english')..''
..'\n\n> قـفـل ادیـت : '..getsettings('edit')..''
..'\n\n> قـفـل پـیـام‌سـرویـسـی : '..getsettings('tgservice')..''
..'\n\n> قـفـل ايـنـلـايـن : '..getsettings('keyboard')..''
..'\n\n> قـفـل اسـتـیـکـر : '..getsettings('sticker')..''
..'\n\n> قـفـل عـکـس : '..getsettings('photo')..''
..'\n\n> قـفـل ویـس : '..getsettings('voice')..''
..'\n\n> قفل فـیـلـم‌سـلـفـی : '..getsettings('selfvideo')..''
..'\n\n> قـفـل فـیـلـم : '..getsettings('video')..''
..'\n\n> قـفـل گـیـف : '..getsettings('gif')..''
..'\n\n> قـفـل اهـنـگ : '..getsettings('audio')..''
..'\n\n> قـفـل فـایـل : '..getsettings('file')..''
..'\n\n> قـفـل مـتـن : '..getsettings('text')..''
..'\n\n> خـوش‌‌آمـدگـویـی : '..getsettings('welcome')..''
..'\n\n> مهلت ربات : '..getsettings('charge')..''
reply_to(msg.chat_id_, msg.id_, 1,setting, 1, 'html')
end
--------------------------------------------------------------------------------
     if text:match("^menu$") or text:match("^منو$") then
          function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[0].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = api_id,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(msg.chat_id_),
      offset_ = 0
    }, inline, nil)
       end
--------------------------------------------------------------------------------
	if text:match('^موزیک (.*)') then
        local MusicName = text:match('موزیک (.*)')
 function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[math.random(#data.results_)].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 117678843,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(MusicName),
      offset_ = 0
    }, inline, nil)
       end
--------------------------------------------------------------------------------
	if text:match('^عکس (.*)') then
        local photo = text:match('عکس (.*)')
 function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[math.random(#data.results_)].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 109158646,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(photo),
      offset_ = 0
    }, inline, nil)
       end
--------------------------------------------------------------------------------
	if text:match('^گیف (.*)') then
        local gif = text:match('گیف (.*)')
 function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[math.random(#data.results_)].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 140267078,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(gif),
      offset_ = 0
    }, inline, nil)
       end
--------------------------------------------------------------------------------
local text = text:gsub("تنظیم فلود", "setflood")
if text:match('^setflood (%d+)$') then
          redis:set('floodmax'..msg.chat_id_,text:match('setflood (.*)'))
          reply_to(msg.chat_id_, msg.id_, 1,'> *حداکثر پیام تشخیص ارسال پیام مکرر تنظیم شد به:* [*'..text:match('setflood (.*)')..'*]', 1, 'md')
        end
--------------------------------------------------------------------------------
local text = text:gsub("تنظیم زمان فلود", "setfloodtime")
        if text:match('^setfloodtime (%d+)$') then
          redis:set('floodtime'..msg.chat_id_,text:match('setfloodtime (.*)'))
          reply_to(msg.chat_id_, msg.id_, 1,'> *حداکثر زمان تشخیص ارسال پیام مکرر تنظیم شد به:* [*'..text:match('setfloodtime (.*)')..'*]', 1, 'md')
        end
--------------------------------------------------------------------------------
if text:match("^link$") or text:match("^لینک$") then
local link = redis:get('grouplink'..msg.chat_id_) 
if not redis:get('grouplink'..msg.chat_id_) then
reply_to(msg.chat_id_, msg.id_, 1, '> *لینک ورود به گروه تنظیم نشده.*\n*ثبت لینک جدید با دستور*\n*/setlink* <i>لینک</i>', 1, 'md')
else
local text = '[لینک گروه '..data.title_..']('..link..')'
function viabold(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[0].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 107705060,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = text,
      offset_ = 0
    }, viabold, nil)
end
end
--------------------------------------------------------------------------------
if text == 'rules' or text == 'قوانین' then
          local rules = redis:get('grouprules'..msg.chat_id_) 
          if rules then
        reply_to(msg.chat_id_, msg.id_, 1, ' '..rules, 1, 'md')
            else
        reply_to(msg.chat_id_, msg.id_, 1, '> *قوانین گروه تنظیم نشده.*\n*ثبت قوانین جدید با دستور*\n*/setrules* <i>قوانین</i>', 1, 'md')
            end
          end
--------------------------------------------------------------------------------
        if text == 'muteall' or text == 'قفل گروه' then
          redis:set('muteall'..msg.chat_id_,true)
        reply_to(msg.chat_id_, msg.id_, 1, '> *گروه با موفقیت تعطیل شد*', 1, 'md')
          end
--------------------------------------------------------------------------------
local text = text:gsub("قفل گروه", "muteall")
if text:match('^(muteall) (.*) (.*) (.*)$') then
  local mutematch = {string.match(text, '^(muteall) (.*) (.*) (.*)$')}
  local hour = string.gsub(mutematch[2], 'h', '')
  local num1 = tonumber(hour) * 3600
  local minutes = string.gsub(mutematch[3], 'm', '')
  local num2 = tonumber(minutes) * 60
  local second = string.gsub(mutematch[4], 's', '')
  local num3 = tonumber(second)
  local num4 = tonumber(num1 + num2 + num3)
  local hash = 'muteall'..msg.chat_id_
  redis:setex(hash, num4, true)
  reply_to(msg.chat_id_, msg.id_, 1, '> *تعطیلی گروه با موفقیت فعال شد برای :*\n*'..hour..'* ساعت و\n*'..minutes..'* دقیقه و\n*'..second..'* ثانیه', 1, 'md')
end
--------------------------------------------------------------------------------
        if text == 'unmuteall' or text == 'بازکردن گروه' then
          redis:del('muteall'..msg.chat_id_)
        reply_to(msg.chat_id_, msg.id_, 1, '> *تعطیلی گروه با موفقیت غیرفعال شد*', 1, 'md')
          end
--------------------------------------------------------------------------------
        if text == 'muteall stats' then
          local status = redis:ttl('muteall'..msg.chat_id_)
          if tonumber(status) < 0 then
            t = '> زمانی برای غیرفعال شدن تعطیلی گروه تعین نشده'
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
            else
          t = '> *'..status..'* *ثانیه دیگر تا غیرفعال شدن تعطیلی گروه مانده است*'
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
          end
          end
--------------------------------------------------------------------------------
    if text == 'بن لیست' or text == 'banlist' then
          local list = redis:smembers('banned'..msg.chat_id_)
          local t = '> *لیست افراد بن شده از گروه:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '> *لیست افراد بت شده از گروه خالی میباشد.*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
      if text == 'حذف بن لیست' or text == 'clean banlist' then
        redis:del('banned'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'> لیست افراد #بن شده خالی شد', 1, 'md')
        end
--------------------------------------------------------------------------------
        if text == 'لیست بی صدا' or text == 'mutelist' then
          local list = redis:smembers('mutes'..msg.chat_id_)
          local t = '> *لیست کاربران بی صدا* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '> لیست افراد بی صدا شده خالی است !'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end      
--------------------------------------------------------------------------------
      if text == 'حذف لیست بی صدا' or text == 'clean mutelist' then
        redis:del('mutes'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'> لیست افراد #بی صدا شده خالی شد', 1, 'md')
        end
--------------------------------------------------------------------------------
if text:match('^warnmax (%d+)') then
local num = text:match('^warnmax (%d+)')
if 2 > tonumber(num) or tonumber(num) > 30 then
reply_to(msg.chat_id_, msg.id_, 1,'> عددی بزرگتر از 2 و کوچکتر از 30 وارد کنید !', 1, 'md')
else
redis:hset("warn:"..msg.chat_id_ ,"warnmax" ,num)
reply_to(msg.chat_id_, msg.id_, 1, '> تعداد اخطار به '..num..' بار تنظیم شد ! ', 1, 'md')
end
end
if is_owner(msg) then
if text:match("^(setwarn) (kick)$") then
redis:hset("warn:"..msg.chat_id_ ,"swarn",'kick') 
reply_to(msg.chat_id_, msg.id_, 1,'> وضعیت اخطار بر روی حالت #اخراج تنظیم شد !', 1, 'html')
elseif text:match("^(setwarn) (ban)$") then
redis:hset("warn:"..msg.chat_id_ ,"swarn",'ban') 
reply_to(msg.chat_id_, msg.id_, 1,'> وضعیت اخطار بر روی حالت #بن تنظیم شد !', 1, 'html')
elseif text:match("^(setwarn) (mute)$") then
redis:hset("warn:"..msg.chat_id_ ,"swarn",'mute') 
reply_to(msg.chat_id_, msg.id_, 1,'> وضعیت اخطار بر روی حالت #بی_صدا تنظیم شد !', 1, 'html')
end
end
local text = text:gsub("اخطار", "warn")
	if text:match("^(warn)$") and tonumber(msg.reply_to_message_id_) > 0 then
		function warn_by_reply(extra, result, success)
if priv(msg.chat_id_,result.sender_user_id_) then
      reply_to(msg.chat_id_, msg.id_, 1,'> شما نمیتوانید به ( ناظران , مالکان , سازندگان ) اخطار دهدید !', 1, 'md')
    else
		local nwarn = tonumber(redis:hget("warn:"..result.chat_id_,result.sender_user_id_) or 0)
	    local wmax = tonumber(redis:hget("warn:"..result.chat_id_ ,"warnmax") or 3)
		if nwarn == wmax then
	    redis:hset("warn:"..result.chat_id_,result.sender_user_id_,0)
         warn(msg,msg.chat_id_,result.sender_user_id_)
		 else 
		redis:hset("warn:"..result.chat_id_,result.sender_user_id_,nwarn + 1)
local text = '> کاربر '..result.sender_user_id_..' به دلیل عدم رعایت قوانین ('..(nwarn + 1)..'/'..wmax..') #اخطار دریافت کرد !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
		end  
end
		end 
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),warn_by_reply)
	end
local text = text:gsub("حذف اخطار", "unwarn")
	if text:match("^(unwarn)$") and tonumber(msg.reply_to_message_id_) > 0 then
		function unwarn_by_reply(extra, result, success)
if priv(msg.chat_id_,result.sender_user_id_) then
    else
if not redis:hget("warn:"..result.chat_id_,result.sender_user_id_) then
local text = '> کاربر '..result.sender_user_id_..' هیچ اخطاری ندارد !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
local warnhash = redis:hget("warn:"..result.chat_id_,result.sender_user_id_)
else redis:hdel("warn:"..result.chat_id_,result.sender_user_id_,0)
local text = '> کاربر '..result.sender_user_id_..' تمام اخطار هایش پاک شد !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
end
 end
end
getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unwarn_by_reply)
end
local text = text:gsub("کیک", "kick")
      if text == 'kick' and tonumber(msg.reply_to_message_id_) > 0 then
        function kick_by_reply(extra, result, success)
        kick(msg,msg.chat_id_,result.sender_user_id_)
          end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),kick_by_reply)
        end
--------------------------------------------------------------------------------
      if text:match('^kick (%d+)') then
        kick(msg,msg.chat_id_,text:match('kick (%d+)'))
        end
      if text:match('^kick @(.*)') then
        local username = text:match('kick @(.*)')
        function kick_username(extra,result,success)
          if result.id_ then
            kick(msg,msg.chat_id_,result.id_)
            else 
            text = '> *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,kick_username)
        end
--------------------------------------------------------------------------------
local text = text:gsub("بن", "ban")
        if text == 'ban' and tonumber(msg.reply_to_message_id_) > 0 then
        function banreply(extra, result, success)
        ban(msg,msg.chat_id_,result.sender_user_id_)
          end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),banreply)
        end
--------------------------------------------------------------------------------
      if text:match('^ban (%d+)') then
        ban(msg,msg.chat_id_,text:match('ban (%d+)'))
        end
      if text:match('^ban @(.*)') then
        local username = text:match('ban @(.*)')
        function banusername(extra,result,success)
          if result.id_ then
            ban(msg,msg.chat_id_,result.id_)
            else 
            text = '> *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,banusername)
        end
--------------------------------------------------------------------------------
local text = text:gsub("انبن", "unban")
      if text == 'unban' and tonumber(msg.reply_to_message_id_) > 0 then
        function unbanreply(extra, result, success)
        unban(msg,msg.chat_id_,result.sender_user_id_)
          end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unbanreply)
        end
--------------------------------------------------------------------------------
      if text:match('^unban (%d+)') then
        unban(msg,msg.chat_id_,text:match('unban (%d+)'))
        end
      if text:match('^unban @(.*)') then
        local username = text:match('unban @(.*)')
        function unbanusername(extra,result,success)
          if result.id_ then
            unban(msg,msg.chat_id_,result.id_)
            else 
            text = '> *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,unbanusername)
        end
--------------------------------------------------------------------------------
local text = text:gsub("بی صدا", "mute")
        if text == 'mute' and tonumber(msg.reply_to_message_id_) > 0 then
        function mutereply(extra, result, success)
        mute(msg,msg.chat_id_,result.sender_user_id_)
          end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),mutereply)
        end
--------------------------------------------------------------------------------
      if text:match('^mute (%d+)') then
        mute(msg,msg.chat_id_,text:match('mute (%d+)'))
        end
      if text:match('^mute @(.*)') then
        local username = text:match('mute @(.*)')
        function muteusername(extra,result,success)
          if result.id_ then
            mute(msg,msg.chat_id_,result.id_)
            else 
            text = '> *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,muteusername)
        end
--------------------------------------------------------------------------------
local text = text:gsub("حذف بی صدا", "unmute")
      if text == 'unmute' and tonumber(msg.reply_to_message_id_) > 0 then
        function unmutereply(extra, result, success)
        unmute(msg,msg.chat_id_,result.sender_user_id_)
          end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unmutereply)
        end
--------------------------------------------------------------------------------
      if text:match('^unmute (%d+)') then
        unmute(msg,msg.chat_id_,text:match('unmute (%d+)'))
        end
      if text:match('^unmute @(.*)') then
        local username = text:match('unmute @(.*)')
        function unmuteusername(extra,result,success)
          if result.id_ then
            unmute(msg,msg.chat_id_,result.id_)
            else 
            text = '> *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,unmuteusername)
        end
--------------------------------------------------------------------------------
local text = text:gsub("دعوت", "invite")
         if text == 'invite' and tonumber(msg.reply_to_message_id_) > 0 then
        function inv_by_reply(extra, result, success)
        addChatMembers(msg.chat_id_,{[0] = result.sender_user_id_})
        end
        getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),inv_by_reply)
        end
--------------------------------------------------------------------------------
      if text:match('^invite (%d+)') then
        addChatMembers(msg.chat_id_,{[0] = text:match('invite (%d+)')})
        end
      if text:match('^invite @(.*)') then
        local username = text:match('invite @(.*)')
        function invite_username(extra,result,success)
          if result.id_ then
        addChatMembers(msg.chat_id_,{[0] = result.id_})
            else 
            text = '> *کاربر مورد نظر یافت نشد!*'
            reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
            end
          end
        resolve_username(username,invite_username)
        end
--------------------------------------------------------------------------------
local text = text:gsub("حذف", "rmsg")
    if text:match('^rmsg (%d+)$') then
        local limit = tonumber(text:match('^rmsg (%d+)$'))
        if limit > 1000 then
        reply_to(msg.chat_id_, msg.id_, 1, '> تعداد پیام وارد شده از حد مجاز (1000 پیام) بیشتر است !', 1, 'md')
          else
         function cb(a,b,c)
        local msgs = b.messages_
        for i=1 , #msgs do
          delete_msg(msg.chat_id_,{[0] = b.messages_[i].id_})
        end
        end
        getChatHistory(msg.chat_id_, 0, 0, limit + 1,cb)
        reply_to(msg.chat_id_, msg.id_, 1, '> (*'..limit..'*)پیام اخیر گرو پاک شد', 1, 'md')
        end
        end
--------------------------------------------------------------------------------
local text = text:gsub("حذف همه", "rmsg all")
  if text:match('^rmsg all$') then
       local function delete_msgs_pro(arg,data)
local delall = data.members_
            if not delall[0] then
    reply_to(msg.chat_id_, msg.id_, 1, 'EeeeeeeeE', 1, 'md')
      else

 for k, v in pairs(data.members_) do  
                deleteMessagesFromUser(msg.chat_id_, v.user_id_)
end

      reply_to(msg.chat_id_, msg.id_, 1, '> پیام های گروه با موفقیت حذف شدند', 1, 'md')
           end
           end
tdcli_function ({
                    ID = "GetChannelMembers",
                    channel_id_ = getChatId(msg.chat_id_).ID,
                    filter_ = {
                      ID = "ChannelMembersRecent"
                    },
                    offset_ = 0,
                    limit_ = 10000
                  }, delete_msgs_pro, nil)
                tdcli_function ({
                    ID = "GetChannelMembers",
                    channel_id_ = getChatId(msg.chat_id_).ID,
                    filter_ = {
                      ID = "ChannelMembersKicked"
                    },
                    offset_ = 0,
                    limit_ = 10000
                  }, delete_msgs_pro, nil)
end
--------------------------------------------------------------------------------
      if tonumber(msg.reply_to_message_id_) > 0 then
    if text == "del" then
        delete_msg(msg.chat_id_,{[0] = tonumber(msg.reply_to_message_id_),msg.id_})
    end
        end
--------------------------------------------------------------------------------
    if text == 'modlist' or text == 'لیست ناظران' then
          local list = redis:smembers('mods:'..msg.chat_id_)
          local t = '> *لیست ناظران گروه:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '> *ناظر برای این گروه ثبت نشده است.*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
      if text == 'clean modlist' or text == 'حذف لیست ناظران' then
        redis:del('mods:'..msg.chat_id_)

          reply_to(msg.chat_id_, msg.id_, 1,'> لیست ناظران گروه #حذف شد !', 1, 'md')
        end
--------------------------------------------------------------------------------
local text = text:gsub("فیلتر", "filter")
      if text:match('^filter +(.*)') then
        local w = text:match('^filter +(.*)')
         redis:sadd('filters:'..msg.chat_id_,w)
          reply_to(msg.chat_id_, msg.id_, 1,'> ('..w..') *به لیست کلمات فیلتر شده اضاف شد!*', 1, 'md')
       end
--------------------------------------------------------------------------------
local text = text:gsub("حذف فیلتر", "rw")
      if text:match('^rw +(.*)') then
        local w = text:match('^rw +(.*)')
         redis:srem('filters:'..msg.chat_id_,w)
          reply_to(msg.chat_id_, msg.id_, 1,'> ('..w..') *از لیست کلمات فیلتر شده پاک شد!*', 1, 'md')
       end
--------------------------------------------------------------------------------
      if text == 'clean filterlist' or text == 'حذف فیلتر لیست' and is_mod(msg) then
        redis:del('filters:'..msg.chat_id_)
          reply_to(msg.chat_id_, msg.id_, 1,'> لیست کلمات #فیلتر شده خالی شد !', 1, 'md')
        end
   if text == 'filterlist' or text == 'لیست کلمات فیلتر شده' then
          local list = redis:smembers('filters:'..msg.chat_id_)
          local t = '> *لیست کلمات فیلتر شده:* \n\n'
          for k,v in pairs(list) do
          t = t..k.." - *["..v.."]*\n" 
          end
          if #list == 0 then
          t = '> *فیلتر لیست خالی است.*'
          end
          reply_to(msg.chat_id_, msg.id_, 1,t, 1, 'md')
      end
--------------------------------------------------------------------------------
  if text:match("^(config)$") or text:match("^(پیکربندی)$") then
       local function cb(extra,result,success)
        local list = result.members_
            for k,v in pairs(list) do
redis:sadd('mods:'..msg.chat_id_,v.user_id_)
end
reply_to(msg.chat_id_, msg.id_, 1, '> تمامی ادمین های گروه به لیست ناظران گروه اضافه گردید', 1, 'md')
          end
       channel_get_admins(msg.chat_id_,cb)
      end
--------------------------------------------------------------------------------
if text == "upchat" and is_sudo(msg) then
 migragrateGroupChatToChannelChat(msg.chat_id_)
reply_to(msg.chat_id_, msg.id_, 1, '> انجام شد', 1, 'md')
end
--------------------------------------------------------------------------------------------------------------------------------------------
if text == 'addkick' then
        local function cb(extra,result,success)
        local list = result.members_
            for k,v in pairs(list) do
addChatMember(msg.chat_id_, v.user_id_, 50, dl_cb, nil)
                    end
         reply_to(msg.chat_id_, msg.id_, 1, '> تمام اعضا ریمو شده گروه به گروه اد شدند', 1, 'md')
          end
       channel_get_kicked(msg.chat_id_,cb)
      end
--------------------------------------------------------------------------------
    if msg_type == 'text' then
        if text then
    if text:match("^(id) (.*)$") or text:match("^(ایدی) (.*)$") then
MatchesEN = {text:match("^(id) (.*)$")}; MatchesFA = {text:match("^(ایدی) (.*)$")}
		local username = MatchesEN[2] or MatchesFA[2]
        function id_by_username(extra,result,success)
          if result.id_ then
            text = '`'..result.id_..'`'
            else 
            text = '> *کاربر مورد نظر یافت نشد!*'
            end
           reply_to(msg.chat_id_, msg.id_, 1, text, 1, 'md')
          end
        resolve_username(username,id_by_username)
        end 
--------------------------------------------------------------------------------
			if text:match("^(pin)$") or text:match("^(سنجاق)$") and is_mod(msg) and msg.reply_to_message_id_ ~= 0 then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
end
--------------------------------------------------------------------------------
if text:match("^(حذف) (سنجاق)$") or text:match("^(unpin)$") and is_mod(msg) and msg.reply_to_message_id_ ~= 0 then
       unpin(msg.chat_id_)
end
--------------------------------------------------------------------------------
if text:match("^(report)$") or text:match("^(ریپورت)$") then
      function rep(extra, result, success)
  if priv(msg.chat_id_,result.sender_user_id_) then
reply_to(msg.chat_id_, msg.id_, 1,'> شما نمیتوانید ( ناظران , مالکان , سازندگان ) ربات را #ریپورت کنید !', 1, 'md')
else
       reportChannelSpam(msg.chat_id_, result.sender_user_id_, {[0] = msg.id_})
local text = '> کاربر '..result.sender_user_id_..' ریپورت شد !'
SendMetion(msg.chat_id_, result.sender_user_id_, msg.id_, text, 8, string.len(result.sender_user_id_))
end
end
         if tonumber(msg.reply_to_message_id_) == 0 then
          else
    getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),rep)
      end
        end
--------------------------------------------------------------------------------
if text:match("^(gpinfo)$") or text:match("^(اطلاعات) (گروه)$") and is_mod(msg) then
 function gpinfo(arg,data)
    -- vardump(data)
reply_to(msg.chat_id_, msg.id_, 1, '> شناسه گروه : '..msg.chat_id_..'\n> ادمین ها : *'..data.administrator_count_..'*\n> مسدود شدها : *'..data.kicked_count_..'*\n> اعضا : *'..data.member_count_..'*\n', 1, 'md')
end
  getChannelFull(msg.chat_id_, gpinfo, nil)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
         	if text:match("^(whois) (.*)$") or text:match("^(مشخصات) (.*)$") then
MatchesEN = {text:match("^(whois) (.*)$")}; MatchesFA = {text:match("^(مشخصات) (.*)$")}
		local id = MatchesEN[2] or MatchesFA[2]
            local text = 'برای مشاهده اطلاعات کاربر کلیک کنید.'
			--{"👤 برای مشاهده کاربر کلیک کنید!","Click to view User 👤"}
            tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=36, user_id_=id}}}}, dl_cb, nil)
              end
--------------------------------------------------------------------------------
         	if text:match("^(id)$") or text:match("^(ایدی)$") then
      function id_by_reply(extra, result, success)
        reply_to(msg.chat_id_, msg.id_, 1, '`'..result.sender_user_id_..'`', 1, 'md')
        end
         if tonumber(msg.reply_to_message_id_) == 0 then
          else
    getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),id_by_reply)
      end
        end

          end
        end
      end
--------------------------------------------------------------------------------
 	if text:match("^(ping)$") or text:match("^(پینگ)$")  then
local text = 'PONG'
SendMetion(msg.chat_id_, msg.sender_user_id_, msg.id_, text, 0, 4)
end
--------------------------------------------------------------------------------
  if text:match("^(help)$") or text:match("^(helps)$") or text:match("^(راهنما)$") then
			reply_to(msg.chat_id_, msg.id_, 1, getHelp("HelpList"), 1, 'md')
		elseif text:match("^(help) (.*)$") or text:match("^(راهنمای) (.*)$") then
			MatchesEN = {text:match("^(help) (.*)$")}; MatchesFA = {text:match("^(راهنمای) (.*)$")}
			Ptrn = MatchesEN[2] or MatchesFA[2]
			if Ptrn == "locks" or Prtn == "lock" or Ptrn == "قفل" or Ptrn == "قفل ها" then
				reply_to(msg.chat_id_, msg.id_, 1, getHelp("LocksHelp"), 1, 'md')
			elseif Ptrn == "fun" or Ptrn == "funs" or Ptrn == "فان" or Ptrn == "سرگرمی" then
reply_to(msg.chat_id_, msg.id_, 1, getHelp("FunHelp"), 1, 'md')
			elseif Ptrn == "moderation" or Ptrn == "mod" or Ptrn == "مدیریت" or Ptrn == "مدیریتی" then
reply_to(msg.chat_id_, msg.id_, 1, getHelp("ModerationHelp"), 1, 'md')
			else
				Text = [[
راهنمای درخواستی شما یافت نشد!
———————————
لیست راهنمای ربات:

1- راهنمای قفل
2- راهنمای مدیریتی
4- راهنمای فان
> جهت دریافت هر راهنما تنها کافیست نام آن را تایپ کنید.
]]
				reply_to(msg.chat_id_, msg.id_, 1, Text, 1, 'md')
			end
end
--------------------------------------------------------------------------------
if text:match("^([Bb][Ee][Aa][Uu][Tt][Yy]) (.*)$") or text:match("^(طراحی) (.*)$") then
		MatchesEN = {text:match("^([Bb][Ee][Aa][Uu][Tt][Yy]) (.*)$")}; MatchesFA = {text:match("^(طراحی) (.*)$")}
		TextToBeauty = MatchesEN[2] or MatchesFA[2]
if #TextToBeauty > 20 then
			reply_to(msg.chat_id_, msg.id_, 1, "> تعداد حروف متن جهت زیباسازی باید کمتر از 20 تا باشد.\nمتن شما دارای "..#TextToBeauty.." کاراکتر است.", 1, 'md')
			return
		end
		local font_base = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,9,8,7,6,5,4,3,2,1,.,_"local font_base = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,9,8,7,6,5,4,3,2,1,.,_"
	local font_hash = "z,y,x,w,v,u,t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,Z,Y,X,W,V,U,T,S,R,Q,P,O,N,M,L,K,J,I,H,G,F,E,D,C,B,A,0,1,2,3,4,5,6,7,8,9,.,_"
	local fonts = {
		"ⓐ,ⓑ,ⓒ,ⓓ,ⓔ,ⓕ,ⓖ,ⓗ,ⓘ,ⓙ,ⓚ,ⓛ,ⓜ,ⓝ,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,ⓣ,ⓤ,ⓥ,ⓦ,ⓧ,ⓨ,ⓩ,ⓐ,ⓑ,ⓒ,ⓓ,ⓔ,ⓕ,ⓖ,ⓗ,ⓘ,ⓙ,ⓚ,ⓛ,ⓜ,ⓝ,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,ⓣ,ⓤ,ⓥ,ⓦ,ⓧ,ⓨ,ⓩ,⓪,➈,➇,➆,➅,➄,➃,➂,➁,➀,●,_",
		"⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⓪,⑼,⑻,⑺,⑹,⑸,⑷,⑶,⑵,⑴,.,_",
		"α,в,c,∂,є,ƒ,g,н,ι,נ,к,ℓ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,χ,у,z,α,в,c,∂,є,ƒ,g,н,ι,נ,к,ℓ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,χ,у,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"α,в,c,d,e,ғ,ɢ,н,ι,j,ĸ,l,м,ɴ,o,p,q,r,ѕ,т,υ,v,w,х,y,z,α,в,c,d,e,ғ,ɢ,н,ι,j,ĸ,l,м,ɴ,o,p,q,r,ѕ,т,υ,v,w,х,y,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ą,ҍ,ç,ժ,ҽ,ƒ,ց,հ,ì,ʝ,ҟ,Ӏ,ʍ,ղ,օ,ք,զ,ɾ,ʂ,է,մ,ѵ,ա,×,վ,Հ,ą,ҍ,ç,ժ,ҽ,ƒ,ց,հ,ì,ʝ,ҟ,Ӏ,ʍ,ղ,օ,ք,զ,ɾ,ʂ,է,մ,ѵ,ա,×,վ,Հ,⊘,९,𝟠,7,Ϭ,Ƽ,५,Ӡ,ϩ,𝟙,.,_",		"ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,0,9,8,7,6,5,4,3,2,1,.,_",
		"α,ß,ς,d,ε,ƒ,g,h,ï,յ,κ,ﾚ,m,η,⊕,p,Ω,r,š,†,u,∀,ω,x,ψ,z,α,ß,ς,d,ε,ƒ,g,h,ï,յ,κ,ﾚ,m,η,⊕,p,Ω,r,š,†,u,∀,ω,x,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ﾑ,乃,ζ,Ð,乇,ｷ,Ǥ,ん,ﾉ,ﾌ,ズ,ﾚ,ᄊ,刀,Ծ,ｱ,Q,尺,ㄎ,ｲ,Ц,Џ,Щ,ﾒ,ﾘ,乙,ﾑ,乃,ζ,Ð,乇,ｷ,Ǥ,ん,ﾉ,ﾌ,ズ,ﾚ,ᄊ,刀,Ծ,ｱ,q,尺,ㄎ,ｲ,Ц,Џ,Щ,ﾒ,ﾘ,乙,ᅙ,9,8,ᆨ,6,5,4,3,ᆯ,1,.,_",
		"α,β,c,δ,ε,Ŧ,ĝ,h,ι,j,κ,l,ʍ,π,ø,ρ,φ,Ʀ,$,†,u,υ,ω,χ,ψ,z,α,β,c,δ,ε,Ŧ,ĝ,h,ι,j,κ,l,ʍ,π,ø,ρ,φ,Ʀ,$,†,u,υ,ω,χ,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ձ,ъ,ƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,ձ,ъ,ƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,0,9,8,7,6,5,4,3,2,1,.,_",
		"Λ,ɓ,¢,Ɗ,£,ƒ,ɢ,ɦ,ĩ,ʝ,Қ,Ł,ɱ,ה,ø,Ṗ,Ҩ,Ŕ,Ş,Ŧ,Ū,Ɣ,ω,Ж,¥,Ẑ,Λ,ɓ,¢,Ɗ,£,ƒ,ɢ,ɦ,ĩ,ʝ,Қ,Ł,ɱ,ה,ø,Ṗ,Ҩ,Ŕ,Ş,Ŧ,Ū,Ɣ,ω,Ж,¥,Ẑ,0,9,8,7,6,5,4,3,2,1,.,_",
		"Λ,Б,Ͼ,Ð,Ξ,Ŧ,G,H,ł,J,К,Ł,M,Л,Ф,P,Ǫ,Я,S,T,U,V,Ш,Ж,Џ,Z,Λ,Б,Ͼ,Ð,Ξ,Ŧ,g,h,ł,j,К,Ł,m,Л,Ф,p,Ǫ,Я,s,t,u,v,Ш,Ж,Џ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"A̴,̴B̴,̴C̴,̴D̴,̴E̴,̴F̴,̴G̴,̴H̴,̴I̴,̴J̴,̴K̴,̴L̴,̴M̴,̴N̴,̴O̴,̴P̴,̴Q̴,̴R̴,̴S̴,̴T̴,̴U̴,̴V̴,̴W̴,̴X̴,̴Y̴,̴Z̴,̴a̴,̴b̴,̴c̴,̴d̴,̴e̴,̴f̴,̴g̴,̴h̴,̴i̴,̴j̴,̴k̴,̴l̴,̴m̴,̴n̴,̴o̴,̴p̴,̴q̴,̴r̴,̴s̴,̴t̴,̴u̴,̴v̴,̴w̴,̴x̴,̴y̴,̴z̴,̴0̴,̴9̴,̴8̴,̴7̴,̴6̴,̴5̴,̴4̴,̴3̴,̴2̴,̴1̴,̴.̴,̴_̴",
		"ⓐ,ⓑ,ⓒ,ⓓ,ⓔ,ⓕ,ⓖ,ⓗ,ⓘ,ⓙ,ⓚ,ⓛ,ⓜ,ⓝ,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,ⓣ,ⓤ,ⓥ,ⓦ,ⓧ,ⓨ,ⓩ,ⓐ,ⓑ,ⓒ,ⓓ,ⓔ,ⓕ,ⓖ,ⓗ,ⓘ,ⓙ,ⓚ,ⓛ,ⓜ,ⓝ,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,ⓣ,ⓤ,ⓥ,ⓦ,ⓧ,ⓨ,ⓩ,⓪,➈,➇,➆,➅,➄,➃,➂,➁,➀,●,_",
		"⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⓪,⑼,⑻,⑺,⑹,⑸,⑷,⑶,⑵,⑴,.,_",
		"α,в,c,∂,є,ƒ,g,н,ι,נ,к,ℓ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,χ,у,z,α,в,c,∂,є,ƒ,g,н,ι,נ,к,ℓ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,χ,у,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"α,в,c,ɗ,є,f,g,н,ι,נ,к,Ɩ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,x,у,z,α,в,c,ɗ,є,f,g,н,ι,נ,к,Ɩ,м,η,σ,ρ,q,я,ѕ,т,υ,ν,ω,x,у,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"α,в,c,d,e,ғ,ɢ,н,ι,j,ĸ,l,м,ɴ,o,p,q,r,ѕ,т,υ,v,w,х,y,z,α,в,c,d,e,ғ,ɢ,н,ι,j,ĸ,l,м,ɴ,o,p,q,r,ѕ,т,υ,v,w,х,y,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"α,Ⴆ,ƈ,ԃ,ҽ,ϝ,ɠ,ԋ,ι,ʝ,ƙ,ʅ,ɱ,ɳ,σ,ρ,ϙ,ɾ,ʂ,ƚ,υ,ʋ,ɯ,x,ყ,ȥ,α,Ⴆ,ƈ,ԃ,ҽ,ϝ,ɠ,ԋ,ι,ʝ,ƙ,ʅ,ɱ,ɳ,σ,ρ,ϙ,ɾ,ʂ,ƚ,υ,ʋ,ɯ,x,ყ,ȥ,0,9,8,7,6,5,4,3,2,1,.,_",
		"α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ą,ɓ,ƈ,đ,ε,∱,ɠ,ɧ,ï,ʆ,ҡ,ℓ,ɱ,ŋ,σ,þ,ҩ,ŗ,ş,ŧ,ų,√,щ,х,γ,ẕ,ą,ɓ,ƈ,đ,ε,∱,ɠ,ɧ,ï,ʆ,ҡ,ℓ,ɱ,ŋ,σ,þ,ҩ,ŗ,ş,ŧ,ų,√,щ,х,γ,ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
		"ą,ҍ,ç,ժ,ҽ,ƒ,ց,հ,ì,ʝ,ҟ,Ӏ,ʍ,ղ,օ,ք,զ,ɾ,ʂ,է,մ,ѵ,ա,×,վ,Հ,ą,ҍ,ç,ժ,ҽ,ƒ,ց,հ,ì,ʝ,ҟ,Ӏ,ʍ,ղ,օ,ք,զ,ɾ,ʂ,է,մ,ѵ,ա,×,վ,Հ,⊘,९,𝟠,7,Ϭ,Ƽ,५,Ӡ,ϩ,𝟙,.,_",
		"მ,ჩ,ƈ,ძ,ε,բ,ց,հ,ἶ,ʝ,ƙ,l,ო,ղ,օ,ր,գ,ɾ,ʂ,է,մ,ν,ω,ჯ,ყ,z,მ,ჩ,ƈ,ძ,ε,բ,ց,հ,ἶ,ʝ,ƙ,l,ო,ղ,օ,ր,գ,ɾ,ʂ,է,մ,ν,ω,ჯ,ყ,z,0,Գ,Ց,Դ,6,5,Վ,Յ,Զ,1,.,_",
		"ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,0,9,8,7,6,5,4,3,2,1,.,_",
		"α,ß,ς,d,ε,ƒ,g,h,ï,յ,κ,ﾚ,m,η,⊕,p,Ω,r,š,†,u,∀,ω,x,ψ,z,α,ß,ς,d,ε,ƒ,g,h,ï,յ,κ,ﾚ,m,η,⊕,p,Ω,r,š,†,u,∀,ω,x,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ª,b,¢,Þ,È,F,૬,ɧ,Î,j,Κ,Ļ,м,η,◊,Ƿ,ƍ,r,S,⊥,µ,√,w,×,ý,z,ª,b,¢,Þ,È,F,૬,ɧ,Î,j,Κ,Ļ,м,η,◊,Ƿ,ƍ,r,S,⊥,µ,√,w,×,ý,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"Δ,Ɓ,C,D,Σ,F,G,H,I,J,Ƙ,L,Μ,∏,Θ,Ƥ,Ⴓ,Γ,Ѕ,Ƭ,Ʊ,Ʋ,Ш,Ж,Ψ,Z,λ,ϐ,ς,d,ε,ғ,ɢ,н,ι,ϳ,κ,l,ϻ,π,σ,ρ,φ,г,s,τ,υ,v,ш,ϰ,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"Λ,ß,Ƈ,D,Ɛ,F,Ɠ,Ĥ,Ī,Ĵ,Ҡ,Ŀ,M,И,♡,Ṗ,Ҩ,Ŕ,S,Ƭ,Ʊ,Ѵ,Ѡ,Ӿ,Y,Z,Λ,ß,Ƈ,D,Ɛ,F,Ɠ,Ĥ,Ī,Ĵ,Ҡ,Ŀ,M,И,♡,Ṗ,Ҩ,Ŕ,S,Ƭ,Ʊ,Ѵ,Ѡ,Ӿ,Y,Z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ﾑ,乃,ζ,Ð,乇,ｷ,Ǥ,ん,ﾉ,ﾌ,ズ,ﾚ,ᄊ,刀,Ծ,ｱ,Q,尺,ㄎ,ｲ,Ц,Џ,Щ,ﾒ,ﾘ,乙,ﾑ,乃,ζ,Ð,乇,ｷ,Ǥ,ん,ﾉ,ﾌ,ズ,ﾚ,ᄊ,刀,Ծ,ｱ,q,尺,ㄎ,ｲ,Ц,Џ,Щ,ﾒ,ﾘ,乙,ᅙ,9,8,ᆨ,6,5,4,3,ᆯ,1,.,_",
		"α,β,c,δ,ε,Ŧ,ĝ,h,ι,j,κ,l,ʍ,π,ø,ρ,φ,Ʀ,$,†,u,υ,ω,χ,ψ,z,α,β,c,δ,ε,Ŧ,ĝ,h,ι,j,κ,l,ʍ,π,ø,ρ,φ,Ʀ,$,†,u,υ,ω,χ,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ค,๖,¢,໓,ē,f,ງ,h,i,ว,k,l,๓,ຖ,໐,p,๑,r,Ş,t,น,ง,ຟ,x,ฯ,ຊ,ค,๖,¢,໓,ē,f,ງ,h,i,ว,k,l,๓,ຖ,໐,p,๑,r,Ş,t,น,ง,ຟ,x,ฯ,ຊ,0,9,8,7,6,5,4,3,2,1,.,_",
		"ձ,ъ,ƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,ձ,ъ,ƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,0,9,8,7,6,5,4,3,2,1,.,_",
		"Â,ß,Ĉ,Ð,Є,Ŧ,Ǥ,Ħ,Ī,ʖ,Қ,Ŀ,♏,И,Ø,P,Ҩ,R,$,ƚ,Ц,V,Щ,X,￥,Ẕ,Â,ß,Ĉ,Ð,Є,Ŧ,Ǥ,Ħ,Ī,ʖ,Қ,Ŀ,♏,И,Ø,P,Ҩ,R,$,ƚ,Ц,V,Щ,X,￥,Ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
		"Λ,ɓ,¢,Ɗ,£,ƒ,ɢ,ɦ,ĩ,ʝ,Қ,Ł,ɱ,ה,ø,Ṗ,Ҩ,Ŕ,Ş,Ŧ,Ū,Ɣ,ω,Ж,¥,Ẑ,Λ,ɓ,¢,Ɗ,£,ƒ,ɢ,ɦ,ĩ,ʝ,Қ,Ł,ɱ,ה,ø,Ṗ,Ҩ,Ŕ,Ş,Ŧ,Ū,Ɣ,ω,Ж,¥,Ẑ,0,9,8,7,6,5,4,3,2,1,.,_",
		"Λ,Б,Ͼ,Ð,Ξ,Ŧ,G,H,ł,J,К,Ł,M,Л,Ф,P,Ǫ,Я,S,T,U,V,Ш,Ж,Џ,Z,Λ,Б,Ͼ,Ð,Ξ,Ŧ,g,h,ł,j,К,Ł,m,Л,Ф,p,Ǫ,Я,s,t,u,v,Ш,Ж,Џ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"Թ,Յ,Շ,Ժ,ȝ,Բ,Գ,ɧ,ɿ,ʝ,ƙ,ʅ,ʍ,Ռ,Ծ,ρ,φ,Ր,Տ,Ե,Մ,ע,ա,Ճ,Վ,Հ,Թ,Յ,Շ,Ժ,ȝ,Բ,Գ,ɧ,ɿ,ʝ,ƙ,ʅ,ʍ,Ռ,Ծ,ρ,φ,Ր,Տ,Ե,Մ,ע,ա,Ճ,Վ,Հ,0,9,8,7,6,5,4,3,2,1,.,_",
		"Æ,þ,©,Ð,E,F,ζ,Ħ,Ї,¿,ズ,ᄂ,M,Ñ,Θ,Ƿ,Ø,Ґ,Š,τ,υ,¥,w,χ,y,շ,Æ,þ,©,Ð,E,F,ζ,Ħ,Ї,¿,ズ,ᄂ,M,Ñ,Θ,Ƿ,Ø,Ґ,Š,τ,υ,¥,w,χ,y,շ,0,9,8,7,6,5,4,3,2,1,.,_",
		"ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"4,8,C,D,3,F,9,H,!,J,K,1,M,N,0,P,Q,R,5,7,U,V,W,X,Y,2,4,8,C,D,3,F,9,H,!,J,K,1,M,N,0,P,Q,R,5,7,U,V,W,X,Y,2,0,9,8,7,6,5,4,3,2,1,.,_",
		"Λ,M,X,ʎ,Z,ɐ,q,ɔ,p,ǝ,ɟ,ƃ,ɥ,ı,ɾ,ʞ,l,ա,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,Λ,M,X,ʎ,Z,ɐ,q,ɔ,p,ǝ,ɟ,ƃ,ɥ,ı,ɾ,ʞ,l,ա,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,0,9,8,7,6,5,4,3,2,1,.,‾",
		"A̴,̴B̴,̴C̴,̴D̴,̴E̴,̴F̴,̴G̴,̴H̴,̴I̴,̴J̴,̴K̴,̴L̴,̴M̴,̴N̴,̴O̴,̴P̴,̴Q̴,̴R̴,̴S̴,̴T̴,̴U̴,̴V̴,̴W̴,̴X̴,̴Y̴,̴Z̴,̴a̴,̴b̴,̴c̴,̴d̴,̴e̴,̴f̴,̴g̴,̴h̴,̴i̴,̴j̴,̴k̴,̴l̴,̴m̴,̴n̴,̴o̴,̴p̴,̴q̴,̴r̴,̴s̴,̴t̴,̴u̴,̴v̴,̴w̴,̴x̴,̴y̴,̴z̴,̴0̴,̴9̴,̴8̴,̴7̴,̴6̴,̴5̴,̴4̴,̴3̴,̴2̴,̴1̴,̴.̴,̴_̴",
		"A̱,̱Ḇ,̱C̱,̱Ḏ,̱E̱,̱F̱,̱G̱,̱H̱,̱I̱,̱J̱,̱Ḵ,̱Ḻ,̱M̱,̱Ṉ,̱O̱,̱P̱,̱Q̱,̱Ṟ,̱S̱,̱Ṯ,̱U̱,̱V̱,̱W̱,̱X̱,̱Y̱,̱Ẕ,̱a̱,̱ḇ,̱c̱,̱ḏ,̱e̱,̱f̱,̱g̱,̱ẖ,̱i̱,̱j̱,̱ḵ,̱ḻ,̱m̱,̱ṉ,̱o̱,̱p̱,̱q̱,̱ṟ,̱s̱,̱ṯ,̱u̱,̱v̱,̱w̱,̱x̱,̱y̱,̱ẕ,̱0̱,̱9̱,̱8̱,̱7̱,̱6̱,̱5̱,̱4̱,̱3̱,̱2̱,̱1̱,̱.̱,̱_̱",
		"A̲,̲B̲,̲C̲,̲D̲,̲E̲,̲F̲,̲G̲,̲H̲,̲I̲,̲J̲,̲K̲,̲L̲,̲M̲,̲N̲,̲O̲,̲P̲,̲Q̲,̲R̲,̲S̲,̲T̲,̲U̲,̲V̲,̲W̲,̲X̲,̲Y̲,̲Z̲,̲a̲,̲b̲,̲c̲,̲d̲,̲e̲,̲f̲,̲g̲,̲h̲,̲i̲,̲j̲,̲k̲,̲l̲,̲m̲,̲n̲,̲o̲,̲p̲,̲q̲,̲r̲,̲s̲,̲t̲,̲u̲,̲v̲,̲w̲,̲x̲,̲y̲,̲z̲,̲0̲,̲9̲,̲8̲,̲7̲,̲6̲,̲5̲,̲4̲,̲3̲,̲2̲,̲1̲,̲.̲,̲_̲",
		"Ā,̄B̄,̄C̄,̄D̄,̄Ē,̄F̄,̄Ḡ,̄H̄,̄Ī,̄J̄,̄K̄,̄L̄,̄M̄,̄N̄,̄Ō,̄P̄,̄Q̄,̄R̄,̄S̄,̄T̄,̄Ū,̄V̄,̄W̄,̄X̄,̄Ȳ,̄Z̄,̄ā,̄b̄,̄c̄,̄d̄,̄ē,̄f̄,̄ḡ,̄h̄,̄ī,̄j̄,̄k̄,̄l̄,̄m̄,̄n̄,̄ō,̄p̄,̄q̄,̄r̄,̄s̄,̄t̄,̄ū,̄v̄,̄w̄,̄x̄,̄ȳ,̄z̄,̄0̄,̄9̄,̄8̄,̄7̄,̄6̄,̄5̄,̄4̄,̄3̄,̄2̄,̄1̄,̄.̄,̄_̄",
		"A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,0,9,8,7,6,5,4,3,2,1,.,_",
		"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,9,8,7,6,5,4,3,2,1,.,_",
		"@,♭,ḉ,ⓓ,℮,ƒ,ℊ,ⓗ,ⓘ,נ,ⓚ,ℓ,ⓜ,η,ø,℘,ⓠ,ⓡ,﹩,т,ⓤ,√,ω,ж,૪,ℨ,@,♭,ḉ,ⓓ,℮,ƒ,ℊ,ⓗ,ⓘ,נ,ⓚ,ℓ,ⓜ,η,ø,℘,ⓠ,ⓡ,﹩,т,ⓤ,√,ω,ж,૪,ℨ,0,➈,➑,➐,➅,➄,➃,➌,➁,➊,.,_",
		"@,♭,¢,ⅾ,ε,ƒ,ℊ,ℌ,ї,נ,к,ℓ,м,п,ø,ρ,ⓠ,ґ,﹩,⊥,ü,√,ω,ϰ,૪,ℨ,@,♭,¢,ⅾ,ε,ƒ,ℊ,ℌ,ї,נ,к,ℓ,м,п,ø,ρ,ⓠ,ґ,﹩,⊥,ü,√,ω,ϰ,૪,ℨ,0,9,8,7,6,5,4,3,2,1,.,_",
		"α,♭,ḉ,∂,ℯ,ƒ,ℊ,ℌ,ї,ʝ,ḱ,ℓ,м,η,ø,℘,ⓠ,я,﹩,⊥,ц,ṽ,ω,ჯ,૪,ẕ,α,♭,ḉ,∂,ℯ,ƒ,ℊ,ℌ,ї,ʝ,ḱ,ℓ,м,η,ø,℘,ⓠ,я,﹩,⊥,ц,ṽ,ω,ჯ,૪,ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
		"@,ß,¢,ḓ,℮,ƒ,ℊ,ℌ,ї,נ,ḱ,ʟ,м,п,◎,℘,ⓠ,я,﹩,т,ʊ,♥️,ẘ,✄,૪,ℨ,@,ß,¢,ḓ,℮,ƒ,ℊ,ℌ,ї,נ,ḱ,ʟ,м,п,◎,℘,ⓠ,я,﹩,т,ʊ,♥️,ẘ,✄,૪,ℨ,0,9,8,7,6,5,4,3,2,1,.,_",
        "@,ß,¢,ḓ,℮,ƒ,ℊ,н,ḯ,נ,к,ℓμ,п,☺️,℘,ⓠ,я,﹩,⊥,υ,ṽ,ω,✄,૪,ℨ,@,ß,¢,ḓ,℮,ƒ,ℊ,н,ḯ,נ,к,ℓμ,п,☺️,℘,ⓠ,я,﹩,⊥,υ,ṽ,ω,✄,૪,ℨ,0,9,8,7,6,5,4,3,2,1,.,_",
        "@,ß,ḉ,ḓ,є,ƒ,ℊ,ℌ,ї,נ,ḱ,ʟ,ღ,η,◎,℘,ⓠ,я,﹩,⊥,ʊ,♥️,ω,ϰ,૪,ẕ,@,ß,ḉ,ḓ,є,ƒ,ℊ,ℌ,ї,נ,ḱ,ʟ,ღ,η,◎,℘,ⓠ,я,﹩,⊥,ʊ,♥️,ω,ϰ,૪,ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
        "@,ß,ḉ,∂,ε,ƒ,ℊ,ℌ,ї,נ,ḱ,ł,ღ,и,ø,℘,ⓠ,я,﹩,т,υ,√,ω,ჯ,૪,ẕ,@,ß,ḉ,∂,ε,ƒ,ℊ,ℌ,ї,נ,ḱ,ł,ღ,и,ø,℘,ⓠ,я,﹩,т,υ,√,ω,ჯ,૪,ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
        "α,♭,¢,∂,ε,ƒ,❡,н,ḯ,ʝ,ḱ,ʟ,μ,п,ø,ρ,ⓠ,ґ,﹩,т,υ,ṽ,ω,ж,૪,ẕ,α,♭,¢,∂,ε,ƒ,❡,н,ḯ,ʝ,ḱ,ʟ,μ,п,ø,ρ,ⓠ,ґ,﹩,т,υ,ṽ,ω,ж,૪,ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
        "α,♭,ḉ,∂,℮,ⓕ,ⓖ,н,ḯ,ʝ,ḱ,ℓ,м,п,ø,ⓟ,ⓠ,я,ⓢ,ⓣ,ⓤ,♥️,ⓦ,✄,ⓨ,ⓩ,α,♭,ḉ,∂,℮,ⓕ,ⓖ,н,ḯ,ʝ,ḱ,ℓ,м,п,ø,ⓟ,ⓠ,я,ⓢ,ⓣ,ⓤ,♥️,ⓦ,✄,ⓨ,ⓩ,0,➒,➑,➐,➏,➄,➍,➂,➁,➀,.,_",
        "@,♭,ḉ,ḓ,є,ƒ,ⓖ,ℌ,ⓘ,נ,к,ⓛ,м,ⓝ,ø,℘,ⓠ,я,﹩,ⓣ,ʊ,√,ω,ჯ,૪,ⓩ,@,♭,ḉ,ḓ,є,ƒ,ⓖ,ℌ,ⓘ,נ,к,ⓛ,м,ⓝ,ø,℘,ⓠ,я,﹩,ⓣ,ʊ,√,ω,ჯ,૪,ⓩ,0,➒,➇,➆,➅,➄,➍,➌,➋,➀,.,_",
        "α,♭,ⓒ,∂,є,ⓕ,ⓖ,ℌ,ḯ,ⓙ,ḱ,ł,ⓜ,и,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,⊥,ʊ,ⓥ,ⓦ,ж,ⓨ,ⓩ,α,♭,ⓒ,∂,є,ⓕ,ⓖ,ℌ,ḯ,ⓙ,ḱ,ł,ⓜ,и,ⓞ,ⓟ,ⓠ,ⓡ,ⓢ,⊥,ʊ,ⓥ,ⓦ,ж,ⓨ,ⓩ,0,➒,➑,➆,➅,➎,➍,➌,➁,➀,.,_",
		"ⓐ,ß,ḉ,∂,℮,ⓕ,❡,ⓗ,ї,נ,ḱ,ł,μ,η,ø,ρ,ⓠ,я,﹩,ⓣ,ц,√,ⓦ,✖️,૪,ℨ,ⓐ,ß,ḉ,∂,℮,ⓕ,❡,ⓗ,ї,נ,ḱ,ł,μ,η,ø,ρ,ⓠ,я,﹩,ⓣ,ц,√,ⓦ,✖️,૪,ℨ,0,➒,➑,➐,➅,➄,➍,➂,➁,➊,.,_",
        "α,ß,ⓒ,ⅾ,ℯ,ƒ,ℊ,ⓗ,ї,ʝ,к,ʟ,ⓜ,η,ⓞ,℘,ⓠ,ґ,﹩,т,υ,ⓥ,ⓦ,ж,ⓨ,ẕ,α,ß,ⓒ,ⅾ,ℯ,ƒ,ℊ,ⓗ,ї,ʝ,к,ʟ,ⓜ,η,ⓞ,℘,ⓠ,ґ,﹩,т,υ,ⓥ,ⓦ,ж,ⓨ,ẕ,0,➈,➇,➐,➅,➎,➍,➌,➁,➊,.,_",
        "@,♭,ḉ,ⅾ,є,ⓕ,❡,н,ḯ,נ,ⓚ,ⓛ,м,ⓝ,☺️,ⓟ,ⓠ,я,ⓢ,⊥,υ,♥️,ẘ,ϰ,૪,ⓩ,@,♭,ḉ,ⅾ,є,ⓕ,❡,н,ḯ,נ,ⓚ,ⓛ,м,ⓝ,☺️,ⓟ,ⓠ,я,ⓢ,⊥,υ,♥️,ẘ,ϰ,૪,ⓩ,0,➒,➑,➆,➅,➄,➃,➂,➁,➀,.,_",
        "ⓐ,♭,ḉ,ⅾ,є,ƒ,ℊ,ℌ,ḯ,ʝ,ḱ,ł,μ,η,ø,ⓟ,ⓠ,ґ,ⓢ,т,ⓤ,√,ⓦ,✖️,ⓨ,ẕ,ⓐ,♭,ḉ,ⅾ,є,ƒ,ℊ,ℌ,ḯ,ʝ,ḱ,ł,μ,η,ø,ⓟ,ⓠ,ґ,ⓢ,т,ⓤ,√,ⓦ,✖️,ⓨ,ẕ,0,➈,➇,➐,➅,➄,➃,➂,➁,➀,.,_",
		"ձ,ъƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,ձ,ъƈ,ժ,ε,բ,ց,հ,ﻨ,յ,ĸ,l,ო,ռ,օ,թ,զ,г,ร,է,ս,ν,ա,×,ყ,২,0,9,8,7,6,5,4,3,2,1,.,_",
"λ,ϐ,ς,d,ε,ғ,ϑ,ɢ,н,ι,ϳ,κ,l,ϻ,π,σ,ρ,φ,г,s,τ,υ,v,ш,ϰ,ψ,z,λ,ϐ,ς,d,ε,ғ,ϑ,ɢ,н,ι,ϳ,κ,l,ϻ,π,σ,ρ,φ,г,s,τ,υ,v,ш,ϰ,ψ,z,0,9,8,7,6,5,4,3,2,1,.,_",
"ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,ค,๒,ς,๔,є,Ŧ,ɠ,ђ,เ,ן,к,l,๓,ภ,๏,թ,ợ,г,ร,t,ย,v,ฬ,x,ץ,z,0,9,8,7,6,5,4,3,2,1,.,_",
"მ,ჩ,ƈძ,ε,բ,ց,հ,ἶ,ʝ,ƙ,l,ო,ղ,օ,ր,գ,ɾ,ʂ,է,մ,ν,ω,ჯ,ყ,z,მ,ჩ,ƈძ,ε,բ,ց,հ,ἶ,ʝ,ƙ,l,ო,ղ,օ,ր,գ,ɾ,ʂ,է,մ,ν,ω,ჯ,ყ,z,0,Գ,Ց,Դ,6,5,Վ,Յ,Զ,1,.,_",
"ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,ค,ც,८,ძ,૯,Բ,૭,Һ,ɿ,ʆ,қ,Ն,ɱ,Ո,૦,ƿ,ҩ,Ր,ς,੮,υ,౮,ω,૪,ע,ઽ,0,9,8,7,6,5,4,3,2,1,.,_",
"Λ,Б,Ͼ,Ð,Ξ,Ŧ,g,h,ł,j,К,Ł,m,Л,Ф,p,Ǫ,Я,s,t,u,v,Ш,Ж,Џ,z,Λ,Б,Ͼ,Ð,Ξ,Ŧ,g,h,ł,j,К,Ł,m,Л,Ф,p,Ǫ,Я,s,t,u,v,Ш,Ж,Џ,z,0,9,8,7,6,5,4,3,2,1,.,_",
"λ,ß,Ȼ,ɖ,ε,ʃ,Ģ,ħ,ί,ĵ,κ,ι,ɱ,ɴ,Θ,ρ,ƣ,ર,Ș,τ,Ʋ,ν,ώ,Χ,ϓ,Հ,λ,ß,Ȼ,ɖ,ε,ʃ,Ģ,ħ,ί,ĵ,κ,ι,ɱ,ɴ,Θ,ρ,ƣ,ર,Ș,τ,Ʋ,ν,ώ,Χ,ϓ,Հ,0,9,8,7,6,5,4,3,2,1,.,_",
"ª,b,¢,Þ,È,F,૬,ɧ,Î,j,Κ,Ļ,м,η,◊,Ƿ,ƍ,r,S,⊥,µ,√,w,×,ý,z,ª,b,¢,Þ,È,F,૬,ɧ,Î,j,Κ,Ļ,м,η,◊,Ƿ,ƍ,r,S,⊥,µ,√,w,×,ý,z,0,9,8,7,6,5,4,3,2,1,.,_",
"Թ,Յ,Շ,Ժ,ȝ,Բ,Գ,ɧ,ɿ,ʝ,ƙ,ʅ,ʍ,Ռ,Ծ,ρ,φ,Ր,Տ,Ե,Մ,ע,ա,Ճ,Վ,Հ,Թ,Յ,Շ,Ժ,ȝ,Բ,Գ,ɧ,ɿ,ʝ,ƙ,ʅ,ʍ,Ռ,Ծ,ρ,φ,Ր,Տ,Ե,Մ,ע,ա,Ճ,Վ,Հ,0,9,8,7,6,5,4,3,2,1,.,_",
"Λ,Ϧ,ㄈ,Ð,Ɛ,F,Ɠ,н,ɪ,ﾌ,Қ,Ł,௱,Л,Ø,þ,Ҩ,尺,ら,Ť,Ц,Ɣ,Ɯ,χ,Ϥ,Ẕ,Λ,Ϧ,ㄈ,Ð,Ɛ,F,Ɠ,н,ɪ,ﾌ,Қ,Ł,௱,Л,Ø,þ,Ҩ,尺,ら,Ť,Ц,Ɣ,Ɯ,χ,Ϥ,Ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
"Ǟ,в,ट,D,ę,բ,g,৸,i,j,κ,l,ɱ,П,Φ,Р,q,Я,s,Ʈ,Ц,v,Щ,ж,ყ,ւ,Ǟ,в,ट,D,ę,բ,g,৸,i,j,κ,l,ɱ,П,Φ,Р,q,Я,s,Ʈ,Ц,v,Щ,ж,ყ,ւ,0,9,8,7,6,5,4,3,2,1,.,_",
"ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,ɒ,d,ɔ,b,ɘ,ʇ,ϱ,н,i,į,ʞ,l,м,и,o,q,p,я,ƨ,т,υ,v,w,x,γ,z,0,9,8,7,6,5,4,3,2,1,.,_",
"Æ,þ,©,Ð,E,F,ζ,Ħ,Ї,¿,ズ,ᄂ,M,Ñ,Θ,Ƿ,Ø,Ґ,Š,τ,υ,¥,w,χ,y,շ,Æ,þ,©,Ð,E,F,ζ,Ħ,Ї,¿,ズ,ᄂ,M,Ñ,Θ,Ƿ,Ø,Ґ,Š,τ,υ,¥,w,χ,y,շ,0,9,8,7,6,5,4,3,2,1,.,_",
"ª,ß,¢,ð,€,f,g,h,¡,j,k,|,m,ñ,¤,Þ,q,®,$,t,µ,v,w,×,ÿ,z,ª,ß,¢,ð,€,f,g,h,¡,j,k,|,m,ñ,¤,Þ,q,®,$,t,µ,v,w,×,ÿ,z,0,9,8,7,6,5,4,3,2,1,.,_",
"ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,ɐ,q,ɔ,p,ǝ,ɟ,ɓ,ɥ,ı,ſ,ʞ,ๅ,ɯ,u,o,d,b,ɹ,s,ʇ,n,ʌ,ʍ,x,ʎ,z,0,9,8,7,6,5,4,3,2,1,.,_",
"⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⒜,⒝,⒞,⒟,⒠,⒡,⒢,⒣,⒤,⒥,⒦,⒧,⒨,⒩,⒪,⒫,⒬,⒭,⒮,⒯,⒰,⒱,⒲,⒳,⒴,⒵,⒪,⑼,⑻,⑺,⑹,⑸,⑷,⑶,⑵,⑴,.,_",
"ɑ,ʙ,c,ᴅ,є,ɻ,მ,ʜ,ι,ɿ,ĸ,г,w,и,o,ƅϭ,ʁ,ƨ,⊥,n,ʌ,ʍ,x,⑃,z,ɑ,ʙ,c,ᴅ,є,ɻ,მ,ʜ,ι,ɿ,ĸ,г,w,и,o,ƅϭ,ʁ,ƨ,⊥,n,ʌ,ʍ,x,⑃,z,0,9,8,7,6,5,4,3,2,1,.,_",
"4,8,C,D,3,F,9,H,!,J,K,1,M,N,0,P,Q,R,5,7,U,V,W,X,Y,2,4,8,C,D,3,F,9,H,!,J,K,1,M,N,0,P,Q,R,5,7,U,V,W,X,Y,2,0,9,8,7,6,5,4,3,2,1,.,_",
"Λ,ßƇ,D,Ɛ,F,Ɠ,Ĥ,Ī,Ĵ,Ҡ,Ŀ,M,И,♡,Ṗ,Ҩ,Ŕ,S,Ƭ,Ʊ,Ѵ,Ѡ,Ӿ,Y,Z,Λ,ßƇ,D,Ɛ,F,Ɠ,Ĥ,Ī,Ĵ,Ҡ,Ŀ,M,И,♡,Ṗ,Ҩ,Ŕ,S,Ƭ,Ʊ,Ѵ,Ѡ,Ӿ,Y,Z,0,9,8,7,6,5,4,3,2,1,.,_",
"α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,α,в,¢,đ,e,f,g,ħ,ı,נ,κ,ł,м,и,ø,ρ,q,я,š,т,υ,ν,ω,χ,ч,z,0,9,8,7,6,5,4,3,2,1,.,_",
"α,в,c,ɔ,ε,ғ,ɢ,н,ı,נ,κ,ʟ,м,п,σ,ρ,ǫ,я,ƨ,т,υ,ν,ш,х,ч,z,α,в,c,ɔ,ε,ғ,ɢ,н,ı,נ,κ,ʟ,м,п,σ,ρ,ǫ,я,ƨ,т,υ,ν,ш,х,ч,z,0,9,8,7,6,5,4,3,2,1,.,_",
"【a】,【b】,【c】,【d】,【e】,【f】,【g】,【h】,【i】,【j】,【k】,【l】,【m】,【n】,【o】,【p】,【q】,【r】,【s】,【t】,【u】,【v】,【w】,【x】,【y】,【z】,【a】,【b】,【c】,【d】,【e】,【f】,【g】,【h】,【i】,【j】,【k】,【l】,【m】,【n】,【o】,【p】,【q】,【r】,【s】,【t】,【u】,【v】,【w】,【x】,【y】,【z】,【0】,【9】,【8】,【7】,【6】,【5】,【4】,【3】,【2】,【1】,.,_",
"[̲̲̅̅a̲̅,̲̅b̲̲̅,̅c̲̅,̲̅d̲̲̅,̅e̲̲̅,̅f̲̲̅,̅g̲̅,̲̅h̲̲̅,̅i̲̲̅,̅j̲̲̅,̅k̲̅,̲̅l̲̲̅,̅m̲̅,̲̅n̲̅,̲̅o̲̲̅,̅p̲̅,̲̅q̲̅,̲̅r̲̲̅,̅s̲̅,̲̅t̲̲̅,̅u̲̅,̲̅v̲̅,̲̅w̲̅,̲̅x̲̅,̲̅y̲̅,̲̅z̲̅,[̲̲̅̅a̲̅,̲̅b̲̲̅,̅c̲̅,̲̅d̲̲̅,̅e̲̲̅,̅f̲̲̅,̅g̲̅,̲̅h̲̲̅,̅i̲̲̅,̅j̲̲̅,̅k̲̅,̲̅l̲̲̅,̅m̲̅,̲̅n̲̅,̲̅o̲̲̅,̅p̲̅,̲̅q̲̅,̲̅r̲̲̅,̅s̲̅,̲̅t̲̲̅,̅u̲̅,̲̅v̲̅,̲̅w̲̅,̲̅x̲̅,̲̅y̲̅,̲̅z̲̅,̲̅0̲̅,̲̅9̲̲̅,̅8̲̅,̲̅7̲̅,̲̅6̲̅,̲̅5̲̅,̲̅4̲̅,̲̅3̲̲̅,̅2̲̲̅,̅1̲̲̅̅],.,_",
"[̺͆a̺͆͆,̺b̺͆͆,̺c̺͆,̺͆d̺͆,̺͆e̺͆,̺͆f̺͆͆,̺g̺͆,̺͆h̺͆,̺͆i̺͆,̺͆j̺͆,̺͆k̺͆,̺l̺͆͆,̺m̺͆͆,̺n̺͆͆,̺o̺͆,̺͆p̺͆͆,̺q̺͆͆,̺r̺͆͆,̺s̺͆͆,̺t̺͆͆,̺u̺͆͆,̺v̺͆͆,̺w̺͆,̺͆x̺͆,̺͆y̺͆,̺͆z̺,[̺͆a̺͆͆,̺b̺͆͆,̺c̺͆,̺͆d̺͆,̺͆e̺͆,̺͆f̺͆͆,̺g̺͆,̺͆h̺͆,̺͆i̺͆,̺͆j̺͆,̺͆k̺͆,̺l̺͆͆,̺m̺͆͆,̺n̺͆͆,̺o̺͆,̺͆p̺͆͆,̺q̺͆͆,̺r̺͆͆,̺s̺͆͆,̺t̺͆͆,̺u̺͆͆,̺v̺͆͆,̺w̺͆,̺͆x̺͆,̺͆y̺͆,̺͆z̺,̺͆͆0̺͆,̺͆9̺͆,̺͆8̺̺͆͆7̺͆,̺͆6̺͆,̺͆5̺͆,̺͆4̺͆,̺͆3̺͆,̺͆2̺͆,̺͆1̺͆],.,_",
"̛̭̰̃ã̛̰̭,̛̭̰̃b̛̰̭̃̃,̛̭̰c̛̛̰̭̃̃,̭̰d̛̰̭̃,̛̭̰̃ḛ̛̭̃̃,̛̭̰f̛̰̭̃̃,̛̭̰g̛̰̭̃̃,̛̭̰h̛̰̭̃,̛̭̰̃ḭ̛̛̭̃̃,̭̰j̛̰̭̃̃,̛̭̰k̛̰̭̃̃,̛̭̰l̛̰̭,̛̭̰̃m̛̰̭̃̃,̛̭̰ñ̛̛̰̭̃,̭̰ỡ̰̭̃,̛̭̰p̛̰̭̃,̛̭̰̃q̛̰̭̃̃,̛̭̰r̛̛̰̭̃̃,̭̰s̛̰̭,̛̭̰̃̃t̛̰̭̃,̛̭̰̃ữ̰̭̃,̛̭̰ṽ̛̰̭̃,̛̭̰w̛̛̰̭̃̃,̭̰x̛̰̭̃,̛̭̰̃ỹ̛̰̭̃,̛̭̰z̛̰̭̃̃,̛̛̭̰ã̛̰̭,̛̭̰̃b̛̰̭̃̃,̛̭̰c̛̛̰̭̃̃,̭̰d̛̰̭̃,̛̭̰̃ḛ̛̭̃̃,̛̭̰f̛̰̭̃̃,̛̭̰g̛̰̭̃̃,̛̭̰h̛̰̭̃,̛̭̰̃ḭ̛̛̭̃̃,̭̰j̛̰̭̃̃,̛̭̰k̛̰̭̃̃,̛̭̰l̛̰̭,̛̭̰̃m̛̰̭̃̃,̛̭̰ñ̛̛̰̭̃,̭̰ỡ̰̭̃,̛̭̰p̛̰̭̃,̛̭̰̃q̛̰̭̃̃,̛̭̰r̛̛̰̭̃̃,̭̰s̛̰̭,̛̭̰̃̃t̛̰̭̃,̛̭̰̃ữ̰̭̃,̛̭̰ṽ̛̰̭̃,̛̭̰w̛̛̰̭̃̃,̭̰x̛̰̭̃,̛̭̰̃ỹ̛̰̭̃,̛̭̰z̛̰̭̃̃,̛̭̰0̛̛̰̭̃̃,̭̰9̛̰̭̃̃,̛̭̰8̛̛̰̭̃̃,̭̰7̛̰̭̃̃,̛̭̰6̛̰̭̃̃,̛̭̰5̛̰̭̃,̛̭̰̃4̛̰̭̃,̛̭̰̃3̛̰̭̃̃,̛̭̰2̛̰̭̃̃,̛̭̰1̛̰̭̃,.,_",
"a,ะb,ะc,ะd,ะe,ะf,ะg,ะh,ะi,ะj,ะk,ะl,ะm,ะn,ะo,ะp,ะq,ะr,ะs,ะt,ะu,ะv,ะw,ะx,ะy,ะz,a,ะb,ะc,ะd,ะe,ะf,ะg,ะh,ะi,ะj,ะk,ะl,ะm,ะn,ะo,ะp,ะq,ะr,ะs,ะt,ะu,ะv,ะw,ะx,ะy,ะz,ะ0,ะ9,ะ8,ะ7,ะ6,ะ5,ะ4,ะ3,ะ2,ะ1ะ,.,_",
"̑ȃ,̑b̑,̑c̑,̑d̑,̑ȇ,̑f̑,̑g̑,̑h̑,̑ȋ,̑j̑,̑k̑,̑l̑,̑m̑,̑n̑,̑ȏ,̑p̑,̑q̑,̑ȓ,̑s̑,̑t̑,̑ȗ,̑v̑,̑w̑,̑x̑,̑y̑,̑z̑,̑ȃ,̑b̑,̑c̑,̑d̑,̑ȇ,̑f̑,̑g̑,̑h̑,̑ȋ,̑j̑,̑k̑,̑l̑,̑m̑,̑n̑,̑ȏ,̑p̑,̑q̑,̑ȓ,̑s̑,̑t̑,̑ȗ,̑v̑,̑w̑,̑x̑,̑y̑,̑z̑,̑0̑,̑9̑,̑8̑,̑7̑,̑6̑,̑5̑,̑4̑,̑3̑,̑2̑,̑1̑,.,_",
"~a,͜͝b,͜͝c,͜͝d,͜͝e,͜͝f,͜͝g,͜͝h,͜͝i,͜͝j,͜͝k,͜͝l,͜͝m,͜͝n,͜͝o,͜͝p,͜͝q,͜͝r,͜͝s,͜͝t,͜͝u,͜͝v,͜͝w,͜͝x,͜͝y,͜͝z,~a,͜͝b,͜͝c,͜͝d,͜͝e,͜͝f,͜͝g,͜͝h,͜͝i,͜͝j,͜͝k,͜͝l,͜͝m,͜͝n,͜͝o,͜͝p,͜͝q,͜͝r,͜͝s,͜͝t,͜͝u,͜͝v,͜͝w,͜͝x,͜͝y,͜͝z,͜͝0,͜͝9,͜͝8,͜͝7,͜͝6,͜͝5,͜͝4,͜͝3,͜͝2͜,͝1͜͝~,.,_",
"̤̈ä̤,̤̈b̤̈,̤̈c̤̈̈,̤d̤̈,̤̈ë̤,̤̈f̤̈,̤̈g̤̈̈,̤ḧ̤̈,̤ï̤̈,̤j̤̈,̤̈k̤̈̈,̤l̤̈,̤̈m̤̈,̤̈n̤̈,̤̈ö̤,̤̈p̤̈,̤̈q̤̈,̤̈r̤̈,̤̈s̤̈̈,̤ẗ̤̈,̤ṳ̈,̤̈v̤̈,̤̈ẅ̤,̤̈ẍ̤,̤̈ÿ̤,̤̈z̤̈,̤̈ä̤,̤̈b̤̈,̤̈c̤̈̈,̤d̤̈,̤̈ë̤,̤̈f̤̈,̤̈g̤̈̈,̤ḧ̤̈,̤ï̤̈,̤j̤̈,̤̈k̤̈̈,̤l̤̈,̤̈m̤̈,̤̈n̤̈,̤̈ö̤,̤̈p̤̈,̤̈q̤̈,̤̈r̤̈,̤̈s̤̈̈,̤ẗ̤̈,̤ṳ̈,̤̈v̤̈,̤̈ẅ̤,̤̈ẍ̤,̤̈ÿ̤,̤̈z̤̈,̤̈0̤̈,̤̈9̤̈,̤̈8̤̈,̤̈7̤̈,̤̈6̤̈,̤̈5̤̈,̤̈4̤̈,̤̈3̤̈,̤̈2̤̈̈,̤1̤̈,.,_",
"≋̮̑ȃ̮,̮̑b̮̑,̮̑c̮̑,̮̑d̮̑,̮̑ȇ̮,̮̑f̮̑,̮̑g̮̑,̮̑ḫ̑,̮̑ȋ̮,̮̑j̮̑,̮̑k̮̑,̮̑l̮̑,̮̑m̮̑,̮̑n̮̑,̮̑ȏ̮,̮̑p̮̑,̮̑q̮̑,̮̑r̮,̮̑̑s̮,̮̑̑t̮,̮̑̑u̮,̮̑̑v̮̑,̮̑w̮̑,̮̑x̮̑,̮̑y̮̑,̮̑z̮̑,≋̮̑ȃ̮,̮̑b̮̑,̮̑c̮̑,̮̑d̮̑,̮̑ȇ̮,̮̑f̮̑,̮̑g̮̑,̮̑ḫ̑,̮̑ȋ̮,̮̑j̮̑,̮̑k̮̑,̮̑l̮̑,̮̑m̮̑,̮̑n̮̑,̮̑ȏ̮,̮̑p̮̑,̮̑q̮̑,̮̑r̮,̮̑̑s̮,̮̑̑t̮,̮̑̑u̮,̮̑̑v̮̑,̮̑w̮̑,̮̑x̮̑,̮̑y̮̑,̮̑z̮̑,̮̑0̮̑,̮̑9̮̑,̮̑8̮̑,̮̑7̮̑,̮̑6̮̑,̮̑5̮̑,̮̑4̮̑,̮̑3̮̑,̮̑2̮̑,̮̑1̮̑≋,.,_",
"a̮,̮b̮̮,c̮̮,d̮̮,e̮̮,f̮̮,g̮̮,ḫ̮,i̮,j̮̮,k̮̮,l̮,̮m̮,̮n̮̮,o̮,̮p̮̮,q̮̮,r̮̮,s̮,̮t̮̮,u̮̮,v̮̮,w̮̮,x̮̮,y̮̮,z̮̮,a̮,̮b̮̮,c̮̮,d̮̮,e̮̮,f̮̮,g̮̮,ḫ̮i,̮̮,j̮̮,k̮̮,l̮,̮m̮,̮n̮̮,o̮,̮p̮̮,q̮̮,r̮̮,s̮,̮t̮̮,u̮̮,v̮̮,w̮̮,x̮̮,y̮̮,z̮̮,0̮̮,9̮̮,8̮̮,7̮̮,6̮̮,5̮̮,4̮̮,3̮̮,2̮̮,1̮,.,_",
"A̲,̲B̲,̲C̲,̲D̲,̲E̲,̲F̲,̲G̲,̲H̲,̲I̲,̲J̲,̲K̲,̲L̲,̲M̲,̲N̲,̲O̲,̲P̲,̲Q̲,̲R̲,̲S̲,̲T̲,̲U̲,̲V̲,̲W̲,̲X̲,̲Y̲,̲Z̲,̲a̲,̲b̲,̲c̲,̲d̲,̲e̲,̲f̲,̲g̲,̲h̲,̲i̲,̲j̲,̲k̲,̲l̲,̲m̲,̲n̲,̲o̲,̲p̲,̲q̲,̲r̲,̲s̲,̲t̲,̲u̲,̲v̲,̲w̲,̲x̲,̲y̲,̲z̲,̲0̲,̲9̲,̲8̲,̲7̲,̲6̲,̲5̲,̲4̲,̲3̲,̲2̲,̲1̲,̲.̲,̲_̲",
"Â,ß,Ĉ,Ð,Є,Ŧ,Ǥ,Ħ,Ī,ʖ,Қ,Ŀ,♏,И,Ø,P,Ҩ,R,$,ƚ,Ц,V,Щ,X,￥,Ẕ,Â,ß,Ĉ,Ð,Є,Ŧ,Ǥ,Ħ,Ī,ʖ,Қ,Ŀ,♏,И,Ø,P,Ҩ,R,$,ƚ,Ц,V,Щ,X,￥,Ẕ,0,9,8,7,6,5,4,3,2,1,.,_",
	}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local result = {}
		i=0
		for k=1,#fonts do
			i=i+1
			local tar_font = fonts[i]:split(",")
			local text = TextToBeauty
		local text = text:gsub("A",tar_font[1])
		local text = text:gsub("B",tar_font[2])
		local text = text:gsub("C",tar_font[3])
		local text = text:gsub("D",tar_font[4])
		local text = text:gsub("E",tar_font[5])
		local text = text:gsub("F",tar_font[6])
		local text = text:gsub("G",tar_font[7])
		local text = text:gsub("H",tar_font[8])
		local text = text:gsub("I",tar_font[9])
		local text = text:gsub("J",tar_font[10])
		local text = text:gsub("K",tar_font[11])
		local text = text:gsub("L",tar_font[12])
		local text = text:gsub("M",tar_font[13])
		local text = text:gsub("N",tar_font[14])
		local text = text:gsub("O",tar_font[15])
		local text = text:gsub("P",tar_font[16])
		local text = text:gsub("Q",tar_font[17])
		local text = text:gsub("R",tar_font[18])
		local text = text:gsub("S",tar_font[19])
		local text = text:gsub("T",tar_font[20])
		local text = text:gsub("U",tar_font[21])
		local text = text:gsub("V",tar_font[22])
		local text = text:gsub("W",tar_font[23])
		local text = text:gsub("X",tar_font[24])
		local text = text:gsub("Y",tar_font[25])
		local text = text:gsub("Z",tar_font[26])
		local text = text:gsub("a",tar_font[27])
		local text = text:gsub("b",tar_font[28])
		local text = text:gsub("c",tar_font[29])
		local text = text:gsub("d",tar_font[30])
		local text = text:gsub("e",tar_font[31])
		local text = text:gsub("f",tar_font[32])
		local text = text:gsub("g",tar_font[33])
		local text = text:gsub("h",tar_font[34])
		local text = text:gsub("i",tar_font[35])
		local text = text:gsub("j",tar_font[36])
		local text = text:gsub("k",tar_font[37])
		local text = text:gsub("l",tar_font[38])
		local text = text:gsub("m",tar_font[39])
		local text = text:gsub("n",tar_font[40])
		local text = text:gsub("o",tar_font[41])
		local text = text:gsub("p",tar_font[42])
		local text = text:gsub("q",tar_font[43])
		local text = text:gsub("r",tar_font[44])
		local text = text:gsub("s",tar_font[45])
		local text = text:gsub("t",tar_font[46])
		local text = text:gsub("u",tar_font[47])
		local text = text:gsub("v",tar_font[48])
		local text = text:gsub("w",tar_font[49])
		local text = text:gsub("x",tar_font[50])
		local text = text:gsub("y",tar_font[51])
		local text = text:gsub("z",tar_font[52])
		local text = text:gsub("0",tar_font[53])
		local text = text:gsub("9",tar_font[54])
		local text = text:gsub("8",tar_font[55])
		local text = text:gsub("7",tar_font[56])
		local text = text:gsub("6",tar_font[57])
		local text = text:gsub("5",tar_font[58])
		local text = text:gsub("4",tar_font[59])
		local text = text:gsub("3",tar_font[60])
		local text = text:gsub("2",tar_font[61])
		local text = text:gsub("1",tar_font[62])
			table.insert(result, text)
		end
		
		local result_text = "کلمه مورد نظر شما : "..TextToBeauty.."\nطراحی شده با "..tostring(#fonts).." فونت.\n\n"
		for v=1,#result do
			result_text = result_text..v.." - "..result[v].."\n"
		end
		result_text = result_text
reply_to(msg.chat_id_, msg.id_, 1, result_text, 1, 'md')
	end
if text:match("^([Tt][Rr]) (.*)$") or text:match("^(ترجمه) (.*)$") then 
		MatchesEN = {text:match("^([Tt][Rr]) (.*)$")}; MatchesFA = {text:match("^(ترجمه) (.*)$")}
		Ptrn = MatchesEN[2] or MatchesFA[2]
		url = https.request('https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20160119T111342Z.fd6bf13b3590838f.6ce9d8cca4672f0ed24f649c1b502789c9f4687a&format=plain&lang=fa&text='..URL.escape(Ptrn)) 
		data = json:decode(url)
		Text = '> متن شما : `'..Ptrn..'`\n> زبان ترجمه : `'..data.lang..'`\n\n> ترجمه : `'..data.text[1]..'`'
		reply_to(msg.chat_id_, msg.id_, 1, Text, 1, 'md')
	end
	if text:match("^(time)$") or text:match("^(زمان)$") then
		local url , res = https.request('https://enigma-dev.ir/api/time/')
		if res ~= 200 then return end
		local jd = json:decode(url)
		Text = "> امروز : `"..jd.FaDate.WordTwo.."`\n> ساعت : `"..jd.FaTime.Number.."`"
		reply_to(msg.chat_id_, msg.id_, 1, Text, 1, 'md')
	end
	if text:match("^(date)$") or text:match("^(تاریخ)$") then
		url , res = https.request('https://enigma-dev.ir/api/date/')
		j = json:decode(url)
		Text = "> _منطقه ی زمانی_ : `"..j.ZoneName.."`\n\n> قرن (شمسی) : `"..j.Century.."` اُم\n> سال شمسی : `"..j.Year.Number.."`\n> فصل : `"..j.Season.Name.."`\n> ماه : `"..j.Month.Number.."` اُم ( `"..j.Month.Name.."` )\n> روز از ماه : `"..j.Day.Number.."`\n> روز هفته : `"..j.Day.Name.."`\n>️ نام سال : `"..j.Year.Name.."`\n>️ نام ماه : `"..j.Month.Name.."`\n> تعداد روز های گذشته از سال : `"..j.DaysPassed.Number.."` ( `"..j.DaysPassed.Percent.."%` )\n> روز های باقیمانده از سال : `"..j.DaysLeft.Number.."` ( `"..j.DaysLeft.Percent.."%` )\n\n"
		reply_to(msg.chat_id_, msg.id_, 1, Text, 1, 'md')
	end
if text:match("^[/!#]([Ww][Ee][Aa][Tt][Hh][Ee][Rr]) (.*)$") or text:match("^(هوا) (.*)$") then
		MatchesEN = {text:match("^[/!#]([Ww][Ee][Aa][Tt][Hh][Ee][Rr]) (.*)$")}; MatchesFA = {text:match("^(هوا) (.*)$")}
		Ptrn = MatchesEN[2] or MatchesFA[2]
		local function temps(K)
			local F = (K*1.8)-459.67
			local C = K-273.15
			return F,C
		end
		
		local res = http.request("http://api.openweathermap.org/data/2.5/weather?q="..URL.escape(Ptrn).."&appid=269ed82391822cc692c9afd59f4aabba")
		local jtab = json:decode(res)
		if jtab.name then
			if jtab.weather[1].main == "Thunderstorm" then
				status = "⛈طوفاني"
			elseif jtab.weather[1].main == "Drizzle" then
				status = "🌦نمنم باران"
			elseif jtab.weather[1].main == "Rain" then
				status = "🌧باراني"
			elseif jtab.weather[1].main == "Snow" then
				status = "🌨برفي"
			elseif jtab.weather[1].main == "Atmosphere" then
				status = "🌫مه - غباز آلود"
			elseif jtab.weather[1].main == "Clear" then
				status = "🌤️صاف"
			elseif jtab.weather[1].main == "Clouds" then
				status = "☁️ابري"
			elseif jtab.weather[1].main == "Extreme" then
					status = "-------"
			elseif jtab.weather[1].main == "Additional" then
				status = "-------"
			else
				status = "-------"
			end
			local F1,C1 = temps(jtab.main.temp)
			local F2,C2 = temps(jtab.main.temp_min)
			local F3,C3 = temps(jtab.main.temp_max)
			if jtab.rain then
				rain = jtab.rain["3h"].." ميليمتر"
			else
				rain = "-----"
			end
			if jtab.snow then
				snow = jtab.snow["3h"].." ميليمتر"
			else
				snow = "-----"
			end
			today = "نام شهر : *"..jtab.name.."*\n"
			.."کشور : *"..(jtab.sys.country or "----").."*\n"
			.."وضعیت هوا :\n"
			.."   `"..C1.."° درجه سانتيگراد (سلسيوس)`\n"
			.."   `"..F1.."° فارنهايت`\n"
			.."   `"..jtab.main.temp.."° کلوين`\n"
			.."هوا "..status.." ميباشد\n\n"
			.."حداقل دماي امروز: `C"..C2.."°   F"..F2.."°   K"..jtab.main.temp_min.."°`\n"
			.."حداکثر دماي امروز: `C"..C3.."°   F"..F3.."°   K"..jtab.main.temp_max.."°`\n"
			.."رطوبت هوا: `"..jtab.main.humidity.."%`\n"
			.."مقدار ابر آسمان: `"..jtab.clouds.all.."%`\n"
			.."سرعت باد: `"..(jtab.wind.speed or "------").." متر بر ثانیه`\n"
			.."جهت باد: `"..(jtab.wind.deg or "------").."° درجه`\n"
			.."فشار هوا: `"..(jtab.main.pressure/1000).." بار(اتمسفر)`\n"
			.."بارندگي 3ساعت اخير: `"..rain.."`\n"
			.."بارش برف 3ساعت اخير: `"..snow.."`\n\n"
			after = ""
			local res = http.request("http://api.openweathermap.org/data/2.5/forecast?q="..URL.escape(Ptrn).."&appid=269ed82391822cc692c9afd59f4aabba")
			local jtab = json:decode(res)
			for i=1,5 do
				local F1,C1 = temps(jtab.list[i].main.temp_min)
				local F2,C2 = temps(jtab.list[i].main.temp_max)
				if jtab.list[i].weather[1].main == "Thunderstorm" then
					status = "⛈طوفانی"
				elseif jtab.list[i].weather[1].main == "Drizzle" then
					status = "🌦نمنم باران"
				elseif jtab.list[i].weather[1].main == "Rain" then
					status = "🌧بارانی"
				elseif jtab.list[i].weather[1].main == "Snow" then
					status = "?برفی"
				elseif jtab.list[i].weather[1].main == "Atmosphere" then
					status = "🌫مه - غباز آلود"
				elseif jtab.list[i].weather[1].main == "Clear" then
					status = "🌤️صاف"
				elseif jtab.list[i].weather[1].main == "Clouds" then
					status = "☁️ابری"
				elseif jtab.list[i].weather[1].main == "Extreme" then
					status = "-------"
				elseif jtab.list[i].weather[1].main == "Additional" then
					status = "-------"
				else
					status = "-------"
				end
				if i == 1 then
					day = "فردا هوا "
				elseif i == 2 then
					day = "پس فردا هوا "
				elseif i == 3 then
					day = "3 روز بعد هوا "
				elseif i == 4 then
					day ="4 روز بعد هوا "
				elseif i == 5 then
						day = "5 روز بعد هوا "
				end
				after = after.."- "..day..status.." ميباشد. \n🔺`C"..C2.."°`  *-*  `F"..F2.."°`\n🔻`C"..C1.."°`  *-*  `F"..F1.."°`\n"
			end
			Text = today.."وضعيت آب و هوا در پنج روز آينده:\n"..after
			reply_to(msg.chat_id_, msg.id_, 1, Text, 1, 'md')
		else
			Text = "مکان وارد شده صحیح نمیباشد."
			reply_to(msg.chat_id_, msg.id_, 1, Text, 1, 'md')
		end
	end
	if text:match("^(myrank)$") or text:match("^(لقب) (من)$") then
       local rank =  redis:get('ranks:'..msg.sender_user_id_) or '> ست نشده'
reply_to(msg.chat_id_, msg.id_, 1,''..rank..'',1,'md') 
end
--------------------------------------------------------------------------------
if not redis:get("groupc:"..msg.chat_id_) and is_owner(msg) then
      
local link = redis:get('grouplink'..msg.chat_id_) 
or '--'
local text = 'این گروه فعال نشده است روی این متن کلیک کنید و از سازنده خریداری بفرمایید.'
  SendMetion(msg.chat_id_, 226283662, msg.id_, text, 0, 74)
	  
reply_to(226283662,0,1,'شارژ این گروه به اتمام رسید \nایدی : '..msg.chat_id_..'\nنام گروه : '..data.title_..'\nلینک : '..link..'\n\n\nدر صورتی که میخواهید ربات این گروه را ترک کند از دستور زیر استفاده کنید\n\n/leave'..msg.chat_id_..'\nبرای جوین دادن توی این گروه میتونی از دستور زیر استفاده کنی:\n/join'..msg.chat_id_..'\n_________________\nدر صورتی که میخواهید گروه رو دوباره شارژ کنید میتوانید از کد های زیر استفاده کنید...\n\n*برای شارژ 1 ماهه:*\n/plan1'..msg.chat_id_..'\n\n*برای شارژ 3 ماهه:*\n/plan2'..msg.chat_id_..'\n\n*برای شارژ نامحدود:*\n/plan3'..msg.chat_id_..'', 1, 'md')
        changeChatMemberStatus(msg.chat_id_, 378393503, "Left")
	   end
--------------------------------------------------------------------------------
if text:match("^/start$") then
local text = [[Hi :(
]]
local keyboard = {}
inline_keyboard = {
{

{text="چنل ما",url="https://telegram.me/grandteam"}

}
}
 sendinline(226283662,text,keyboard)
end
    if text and msg_type == 'text' and not is_muted(msg.chat_id_,msg.sender_user_id_) then
	if text:match("^(me)$") or text:match("^(من)$") then
if tonumber(msg.reply_to_message_id_) == 0 then
local ranks = redis:get('ranks:'..msg.sender_user_id_) or 'ست نشده'
if is_sudo(msg) then
            rank = 'سودو'
            elseif is_owner(msg) then
            rank = 'مالک گروه'
            elseif is_mod(msg) then
            rank = 'ناظر گروه'
            else
            rank = 'کاربر عادی'
          end
	   local function getpro(extra, result, success)
 if result.photos_[0] then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,'> شناسه شما : '..msg.sender_user_id_..' \n> مقام شما :'..rank..'\n> لقب شما : '..ranks..'')
      else
local photos = '/root/not.jpg'
sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, photos,'> شناسه شما : '..msg.sender_user_id_..' \n> مقام شما :'..rank..'\n> لقب شما : '..ranks..'')
   end
end
    tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = 1
  }, getpro, nil)
	end
end
end
end
--------------------------------------------------------------------------------
if text:match("^grand$") or text:match("^گرند$") or text:match("^Ultragrand$") or text:match("^التراگرند$") or text:match("^vversion$") or text:match("^ورژن$") then
reply_to(msg.chat_id_, msg.id_, 1,'<b>ＵＬＴＲＡＧＲＡＮＤ</b>\n<i>|A New Bot For Manage Your SuperGroups.|</i>\n\n\n<b>Bot version</b> : <i>7.9</i>\n<b>Developer</b> : @Grand_Dev\n<b>Channel</b> : @GrandTeam',1,'html') 
end
if text:match("^(id)$") or text:match("^(ایدی)$") or text:match("^(آیدی)$") then
  reply_to(msg.chat_id_, msg.id_, 1, '> شناسه شما : <user>'..msg.sender_user_id_..'</user>\n> شناسه گروه : '..msg.chat_id_:gsub('-100','')..' ', 1, nil,msg.sender_user_id_)
end
end
getChat(msg.chat_id_, get_gp, nil) 
end
function tdcli_update_callback(data)
    if (data.ID == "UpdateNewMessage") then
  msg = data.message_
     var_cb(msg,data)
  elseif (data.ID == "UpdateMessageEdited") then
    data = data
    local function edited_cb(extra,result,success)
      var_cb(result,data)
end
--------------------------------------------------------------------------------
getMessage(data.chat_id_, data.message_id_,edited_cb)
	elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
getChats(9223372036854775807, 0, 20, dl_cb, nil)
end
end
--------------------------------------------------------------------------------
Run()
--------------------------------------------------------------------------------