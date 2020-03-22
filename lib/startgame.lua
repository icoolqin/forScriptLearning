-- !!!!!脚本上传前的注意事项：

--[[ 游戏思路：
 - loopBoss:负责发现现在应该去哪个任务流；
 - loopCaptain：负责执行此任务流任务：小任务循环n遍后没发现东西就返回到Boss。
 --------
 整个游戏过程就是在loopBoss与loopCaptain间循环往复
 [loopBoss]               [loopCaptain]
            |--------------任务流1
            |--------------任务流2
识别界面    |--------------任务流3
            |--------------任务流4
            |--------------任务流5
            |--------------...
--]]

-- require 一些文件
package.path=package.path .. ";/var/touchelf/tmp/snow.tep/lib/?.lua"  --这里也要加上游戏文件
require("picll")  -- 不同机型的色彩位置方案 pic's longitude and latitude

-- 声明一些全局变量
ver = 152 --脚本版本号，需要与evan.txt相同
checkTime = os.time() -- 按时间判断是否该更新了ordosomething；
checkLoop = 0 --按循环次数判断是否卡住了，每进入一个任务函数前都要重新归0；
stuckTime = os.time() -- 按时间判断是否卡住了
stuckPoint = getColor(358,318) -- 获取一个点的颜色
--======== 开始前的一些准备 --
-- 免责声明

--检查脚本是否有更新，有的话返回主函数
-- function checkVersion(  )
--     if os.difftime(os.time(), checkTime) > 120 then  -- 1分钟检查一次更新
--         math.randomseed(tostring(os.time()):reverse():sub(1, 6))  -- 更新随机种子
--         onlineVar = httpGet("http://online.juhepeisong.com/sh/version.txt") --获取服务器脚本版本号
--         if onlineVar and tonumber(onlineVar) > tonumber(ver) then
--             logDebug("发现新版本，返回到main函数执行更新")
--             return main()
--         else
--             checkTime = os.time()
--         end
--     end
-- end

-- 初始化脚本，判断手机分辨率、触摸版本，不对的话统统不给用
function init( ... )
    rotateScreen(90); --将屏幕坐标系设置为Home键在右的模式
    local height, width = getScreenResolution()
    local version = getVersion(); -- 将触摸精灵版本号保存在变量version中
    if tonumber(string.sub(version, 1, 1)..string.sub(version, 3,3)..string.sub(version, 5,5)) < 332 then
        notifyMessage("请使用332版本以上的触摸精灵");
        os.exit();
    elseif width ~= 750 or height ~= 1334 then
        notifyMessage("暂只支持iPhone 6(s)设备使用")
    end
end

---======这里开始游戏了，findMe，doxx，taskxx都在这里定义=====----
-- 判断是否卡住了，即40s了，某点颜色一直不变
function checkStuck(  )
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  -- 更新随机种子
    if os.difftime(os.time(), stuckTime) > 10 then  --10s检查一次更新
        if getColor(358,318) == stuckPoint then
            logDebug("i'm stucking,do something")
            if math.random( 1,2 ) == 2 then
                tMove((220+math.random(5, 15)),(500+math.random(5, 15)),(62+math.random(5, 15)),(451+math.random(5, 15)),math.random(5, 8)) --向左上角走
            else
                tMove((220+math.random(5, 15)),(500+math.random(5, 15)),(378+math.random(5, 15)),(451+math.random(5, 15)),math.random(5, 8)) --向右上角走
            end
            tMove((388+math.random(5, 15)),(215+math.random(5, 15)),(558+math.random(5, 15)),(215+math.random(5, 15)),math.random(5, 8)) --再滑动一下视角
        else
            stuckTime = os.time() -- 按时间判断是否卡住了
            stuckPoint = getColor(358,318) -- 获取一个点的颜色
        end
    end
end
-- 循环识别全部图片，识别到就去对应小任务流（二级表循环），每循环一遍logDebug并加1，识别5次还没结果就卡住了，logDebug一下。
function loopBoss(  )
    if not (appRunning("com.android.browser")) then --如果游戏不在运行，就启动游戏
        appRun("com.tencent.vgame") -- 运行游戏
    end
    fishTime = 0 --钓鱼次数清零
    logDebug("come in Boss")
    -- checkVersion() --暂时不联网，所以不check
    checkLoop = 0
    while true do
        spotNumber = 0
        for boss_k, boss_v in pairs(pic) do
            for boss_j, boss_i in pairs(boss_v) do
                boss_i(2)
            end
        end
        if spotNumber ==0 then -- 如果一圈下来还是啥也没瞅到，可能在打斗中卡住了，去打斗区域看看
            checkStuck(  ) --检查是否卡住了
            loopCaptain(pic.battle)
        end
    end
end

-- 二级表（各小任务流程）循环执行
function loopCaptain( table )
    logDebug("come to captain "..getTableName_p2(table, pic))
    checkLoop = 0
    repeat
        spotNumber = 0 
        for captain_k, captain_v in pairs(table) do
            captain_v(1)
        end 
    until spotNumber == 0 --说明一圈下来啥也没识别到，就退出循环，接着下面回到loopBoss
    if table == pic.battle then --如果一圈下来啥也没找到，就上移下摇杆，并且打一下 而且 又是在打斗场景里，就摇上摇杆&打斗一下
        tMove((230+math.random(5, 15)),(466+math.random(5, 15)),(230+math.random(5, 15)),(371+math.random(5, 15)),math.random(4, 8))
        mSleep(math.random(700, 1550))
        rTab(1051,514,8)
    end
    logDebug(getTableName_p2(table, pic).."have nothing,go back to Boss")
    return loopBoss()        
end
 
--bic表的任务循环，table传bic的二级表，table2传pic的二级表
function loopIronMan( table,table2 )
    logDebug("come to ironMan "..getTableName_p2(table, bic))
    repeat
        spotNumber = 0 
        for ironMan_k, ironMan_v in pairs(table) do
            ironMan_v(1)
        end 
    until spotNumber == 0 --说明一圈下来啥也没识别到，就退出循环，接着下面回到一个pic的子任务
    repeat
        rTab(48,595) --点击返回任务小镇
        mSleep(1500)
        local x,y = findMultiColorInRegionFuzzy({ 0xFFFFFF, -3, -5, 0xFBD566, -3, 9, 0xFAD56C, -9, 5, 0x865330, -9, 1, 0x865330, -9, -4, 0x795734 }, 90,34, 591, 43, 605)
    until x == -1 or y == -1  --直到找不到返回点（说明点击成功了）
    loopCaptain( table2 )
end


-- 中循环函数：判断在此大循环页面里的哪个任务中，然后return到相应的小循环，找不到就返回大循环


-- 小循环函数：判断在此小任务的哪个任务里，做完后返回到中循环



--======start函数主体
function start(  )
    init()
    logDebug("the game is start")
    notifyMessage("免责声明：代码仅为本人学习交流编程所写，如偶得之请自行删除",3000)
    appRun("com.tencent.vgame") -- 运行游戏
    mSleep(5000)
    loopBoss( )
end

start()

