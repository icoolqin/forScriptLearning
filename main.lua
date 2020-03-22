-- +++判断版本号及从云端更新脚本+++ --

--===主函数(网络更新版)
-- function main()
--     logDebug("脚本主程序开始运行")
--     local time = getNetTime()
--     local http = require("socket.http")
--     while true do 
--         local count_1 = 0  --下载超时用的
--         local script = io.open("/var/touchelf/snow/startgame.lua")
--         if script then  --如果有startgame文件就dofile
--             dofile("/var/touchelf/snow/startgame.lua")
--             script:close()
--         end
--         ver = ver or 0
--         logDebug("当前版本是"..ver)
--         onlineVer = http.request("http://online.juheps.com/shA/version.txt") --获取服务器脚本版本号
--         timeover = http.request("http://online.juheps.com/shA/endtime.txt")  --获取到期时间
--         if tonumber(onlineVer) == nil or tonumber(timeover) == nil then 
--             notifyMessage("您的设备可能断网了，请联网后重试",30000)
--             logDebug("未获取到版本号")
--             break 
--         end 
--         if  tonumber(onlineVer) <= tonumber(ver) and tonumber(timeover) > tonumber(getNetTime()) then 
--             logDebug("没发现更新，执行startgame函数")
--             start()
--         elseif tonumber(timeover) < tonumber(getNetTime()) then
--             notifyMessage("对不起，您的脚本已过期，请联系作者微信：sqbkf06",60000)
--             break
--         else
--             logDebug("更新脚本")
--             luaScript_1 = http.request("http://online.juheps.com/shA/snow.tep")  --使用GET方法下载脚本,也可以下载E3加密脚本
--             if luaScript_1 == nil  then  -- 没有下载到东西就弹窗提醒联网
--                 logDebug("未获取到云端脚本文件")
--                 if luaScript_1 == nil then logDebug(startgame)
--                 elseif luaScript_2 ==nil then logDebug(lib)
--                 elseif luaScript_3 ==nil then logDebug(picll)
--                 end
--                 notifyMessage("您的设备可能断网了，请联网后重试",30000)
--                 break 
--             end
--             local file1 = assert(io.open("/var/touchelf/snow/startgame.lua","w"))
--             file1:write(luaScript_1)
--             file1:close()
--             local file2 = assert(io.open("/var/touchelf/snow/lib.lua","w"))
--             file2:write(luaScript_2)
--             file2:close()
--             local file3 = assert(io.open("/var/touchelf/snow/picll.lua","w"))
--             file3:write(luaScript_3)
--             file3:close()
--         end
--     end
-- end

--===主函数(本地测试版)
function main()
    logDebug("the main has been done")
    local wd = getWorkingDirectory()
    logDebug(wd);
    dofile("/var/touchelf/tmp/snow.tep/lib/startgame.lua")
end
