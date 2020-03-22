--触摸精灵基础拓展库
-- 脚本存放路径:/var/touchelf/scripts/
-- 放入tep包后运行的工作路径：/var/touchelf/tmp/

math.randomseed(tostring(os.time()):reverse():sub(1, 6))  --放置随机种子

--点击函数  参数：坐标x,坐标y,停留时间ms
function tab(x,y)
    touchDown(0,x,y) 
    mSleep(math.random(50,600))  -- 延迟时间随机
    touchUp(0)
end

--随机点击函数,坐标随机
function rTab(x,y,r)
    if r==nil then
        r=5  --r默认为5
    end
    touchDown(0, x + math.random(-r, r), y + math.random(-r, r));
    mSleep(math.random(50, 500));
    touchUp(0);
end

--当识别到某个图片就点击它
function fTab( tablef,r )
    if r==nil then
        r=5  --r默认为5
    end
    local a,b = findMultiColorInRegionFuzzy(tablef[1], tablef[2], tablef[3], tablef[4], tablef[5], tablef[6])
    if a ~= -1 and b ~= -1 then
        rTab(a,b,r)
        mSleep(math.random(2000, 3000))
    end
end

--当识别到某个图片就点击它直到它消失或者点击次数超过默认5次
function kTab( tablef,kNum )
    local kNum = kNum or 5
    local kNuma = 0
    repeat
        kNuma = kNuma + 1
        local a,b = findMultiColorInRegionFuzzy(tablef[1], tablef[2], tablef[3], tablef[4], tablef[5], tablef[6])
        if a ~= -1 and b ~= -1 then
        rTab(a,b)
        mSleep(math.random(2000, 3000))
        end
    until a == -1 or b == -1 or kNuma == kNum 
end

-- 连续移动到指定位置函数      x1,y1为起始位置坐标，x2、y2为终点位置坐标，n是每次移动多少个像素
function tMove(x1,y1,x2,y2,n)
    local w = math.abs(x2-x1);
    local h = math.abs(y2-y1);
    touchDown(0,x1,y1);
    mSleep(math.random(20, 50));
    if x1 < x2 then
        w1 = n; 
    else
        w1 = -n;
    end
    if y1 < y2 then
        h1 = n; 
    else
        h1 = -n;
    end
    if w >= h then
        for i = 1 , w,n do 
            x1 = x1 + w1;
            if y1 == y2 then
            else
                y1 = y1 + math.ceil(h*h1/w);
            end
            touchMove(0,x1,y1);
            mSleep(math.random(20, 50));
        end
    else
        for i = 1 ,h,n do 
            y1 = y1 + h1;
            if x1 ==x2 then
            else
                x1 = x1 + math.ceil(w*w1/h);
            end
            touchMove(0,x1,y1);
            mSleep(math.random(20, 50));
        end
    end
    mSleep(math.random(20, 50));
    touchUp(0);
end

-- 计算两点之间的角度
function getAngleByPos(x1,y1,x2,y2)
    local p = {}
    p.x = x2-x1
    p.y = y2-y1
    local r = math.atan2(p.y,p.x)*180/math.pi
    return r
end

--确定起点坐标，从该点按角度直线滑动 
--可选参数速度 step，当不写默认为 10，也可自己填写，step 应为大于 0 小于距离长度的数值，建议小于 50，否则会出现滑动无效的情况
--rmd为坐标的随机偏差
function moveTowards(x,y,angle,length,step)
    local step = step or math.random( 10, 40 )
    local length = length or math.random( 88,188 )
    local angle = math.rad(angle)
    local x1 = x + math.random( -30,30 )
    local y1 = y + math.random( -30,30 )
    local x2 = x+math.ceil(length*math.cos(angle))
    local y2 = y+math.ceil(length*math.sin(angle))
    local n = math.random(3,8)
    tMove(x1,y1,x2,y2,n)
    mSleep(math.random(300,500))
end


--[[弧度滑动
function localrange(x1,y1,r)
    rangeR ={};
    for i = 1,120 do
        y = -math.ceil(r*math.cos(math.rad(i*3)))
        x = math.ceil(r*math.sin(math.rad(i*3)))
        x = x + x1
        y = y + y1
        table.insert(rangeR,{x,y})
    end
    
end
]]
--获取当前网络时间
function getCurrentTime()
    local time = getNetTime();
    local tt = ""
    if time ~= -1 then
     tt = os.date("*t", time);
    if tt.year > 2019 and tt.month > 8 and tt.day > 15 and tt.hour > 12 and tt.min > 30 then
        notifyMessage("当前时间超过");
    end
    else
     notifyMessage("请连接网络");
    end
    return tt    --[[ tt.year 年    "day"日   "hour"  小时
                     "isdst" =false     是否夏令时
                      "min"   = 0     分钟
                      "month" = 1     月
                      "sec"   = 0     秒
                      "wday"  = 5     星期5
                      "yday"  = 1     当年已过天数
                      "year" 
                   ]]
end

--单点模糊比对函数  sim值越小精确度越高，范围是 0-255
function compare_color_point(x,y,r,g,b,sim)
    local lr,lg,lb;
    lr,lg,lb = getColorRGB(x,y);
    if math.abs(lr-r) > sim then
        return false;
    end
    if math.abs(lg-g) > sim then
        return false;
    end
    if math.abs(lb-b) > sim then
        return false;
    end
    return true;
end

-- 多点模糊比色
--[[用法
g_t_Table = {
    { 1962,   52, 0xefdccf},
    { 2150,   50, 0xefd8d0},
    { 1964,   76, 0xe9d1c5},
    { 2152,   74, 0xefdcd1},
    { 2122,   62, 0xf1ddd1},
    { 2146, 1080, 0x893824},
    { 1840, 1082, 0x593724},
}
if multiColor(g_t_Table,90) then
    touchDown(100,100)
    mSleep(50)
    touchUp(100,100)
end
]]
function multiColor(array,s)
    s = math.floor(0xff*(100-s)*0.01)
    keepScreen(true)
    for var = 1, #array do
        local lr,lg,lb = getColorRGB(array[var][1],array[var][2])
        local r = math.floor(array[var][3]/0x10000)
        local g = math.floor(array[var][3]%0x10000/0x100)
        local b = math.floor(array[var][3]%0x100)
        if math.abs(lr-r) > s or math.abs(lg-g) > s or math.abs(lb-b) > s then
            keepScreen(false)
            return false
        end
    end
    keepScreen(false)
    return true
end


--遇到某些应用一次关不掉的话可用下面的方法
function kill_app(app_package)
    while true do 
        if appRunning(app_package) then 
            appKill(app_package);
            mSleep(1000);
        else
            return true;
        end
    end
end

--自定义字符串随机
function randomStr(str, num)
    local reStr ='';
    math.randomseed(tostring(os.time()):sub(5):reverse());
    for i = 1, num do
        local getStr = math.random(1, string.len(str));
        reStr = reStr .. string.sub(str, getStr, getStr);
    end
    return reStr;
end


---解压zip文件  unzip("/var/touchelf/scripts/test.zip","/var/touchelf/scripts/");
function unzip(path,to)
    return os.execute("unzip "..path.." -d "..to);
end


--删除文件、文件夹   参数说明:path为要删除文件的路径，支持*通配符。
function remove(path)
    return os.execute("rm -rf "..path);
end


--读取指定文件所有内容，返回一个数组 参数说明：path为要读取文件的路径。 返回值：返回一个table。
function readFile(path)
    local file = io.open(path,"r");--用读模式打开一个文件
    if file then
        local _list = {};
        for l in file:lines() do 
            table.insert(_list,l)
        end
        file:close();--关闭默认的输出文件
        return _list
    end
end


-- 将二进制文件转换成16进制字符串
-- 可用于httpGet函数传送文件，服务器端将16进制字符串转换成二进制文件即可
-- 实现逆向转换
function fileToHexString(file)
        local file = io.open(file, 'rb');
        local data = file:read("*all");
        file:close();
        local t = {};
        for i = 1, string.len(data),1 do
                local code = tonumber(string.byte(data, i, i));
                table.insert(t, string.format("%02x", code));
        end
        return table.concat(t, "");
end

-- 点击home键
function tHome()
    keyDown('HOME');    -- HOME键按下
    mSleep(100);        --延时100毫秒
    keyUp('HOME');      -- HOME键抬起
end

--[[
创建文件夹
参数说明：path为要创建文件夹的路径。
如要创建test文件夹，则输入：
newfolder("/var/touchelf/scripts/test");
--]]
function newfolder(path)
    return os.execute("mkdir "..path);
end

--== 百度OCR相关函数 ==--
BaiduAi = {
    Init = (function()
        local AK = 't4Lh8x0htWsdV1lcI1bbsFun';
        local SK = 'c1dMWqt7UjFn77gjNHTb5Ho9lKroTFai';
        local AccessToken = httpPost('https://aip.baidubce.com/oauth/2.0/token',{["grant_type"]="client_credentials",["client_id"]=AK,["client_secret"]=SK})
        AccessToken = jsonDecode(AccessToken);
        return AccessToken.access_token;
    end),
    Ocr = (function(ImagePath,AT,Api,Ext)
        local file = io.open(ImagePath, 'rb');
        local data = file:read("*all");
        file:close();
        local image = urlEncode(Base64.Encode(data));
        Ext = Ext or {};
        Ext["image"]=image;
        local OcrInfo = httpPost(string.format('https://aip.baidubce.com/rest/2.0/ocr/v1/%s?access_token=%s',Api,AT),Ext);
        return OcrInfo;
    end)

}
Base64 = {
    Init = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
    Encode = (function(data)
            local b = Base64.Init;
            return ((data:gsub('.', function(x)
                local r,b='',x:byte()
                for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
                return r;
            end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
                if (#x < 6) then return '' end
                local c=0
                for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
                return b:sub(c+1,c+1)
            end)..({ '', '==', '=' })[#data%3+1])
        end),
    Decode = (function(data)
        local b = Base64.Init;
        data = string.gsub(data, '[^'..b..'=]', '')
        return (data:gsub('.', function(x)
            if (x == '=') then return '' end
            local r,f='',(b:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if (#x ~= 8) then return '' end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end)
}
function urlEncode(s)
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end
function httpPost(path,data)
    local https = require("ssl.https")
    local ltn12 = require("ltn12")
    local request_body = '';
        if type(data)=='table' then
            for k,v in pairs(data) do
                request_body = request_body..k..'='..v..'&'
            end
        else
            request_body = data
        end
    local response_body = {}
    local res, code, response_headers = https.request{
        url = path,
        method = "POST",
        headers =
          {
              ["Content-Type"] = "application/x-www-form-urlencoded";
              ["Content-Length"] = string.len(request_body);
         },
          source = ltn12.source.string(request_body),
          sink = ltn12.sink.table(response_body),
    }
    if type(response_body) == "table" then
      if table.concat(response_body) ~= "error" then
          return table.concat(response_body);
      else
          return -1;
      end
    else
      logDebug("Not a table:", type(response_body))
      return -1;
    end
end

-- 使用示例
-- function main()
--     mSleep(2000)
--     --获取AccessToken,这个AccessToken有效期为30天,没必要获取很多次,可以获取一次保存下来
--     AccessToken = BaiduAi.Init()
--     logDebug(AccessToken)
--     ImagePath = '/var/touchelf/res/1.jpg'
--     --截图,也可以使用区域截图,注意图片的要求
--     --图像数据，base64编码后进行urlencode，要求base64编码和urlencode后大小不超过4M，最短边至少15px，最长边最大4096px
--     snapshotScreen(ImagePath);
--     --通用文字识别
--     Ocr = BaiduAi.Ocr(ImagePath,AccessToken,'general_basic')
--     --返回的是个json数据
--     logDebug(Ocr)
--     --通用文字识别（高精度含位置版）
--     Ocr = BaiduAi.Ocr(ImagePath,AccessToken,'accurate')
--     --返回的是个json数据
--     logDebug(Ocr)
--     --通用文字识别自定义参数写法
--     Ocr = BaiduAi.Ocr(ImagePath,AccessToken,'general_basic',{["vertexes_location"]='true',["probability"]='true'})
--     --返回的是个json数据
--     logDebug(Ocr)
--     --其他类型看文档修改BaiduAi.Ocr第三个参数即可.
-- end

--== 百度OCR结束 ==--
