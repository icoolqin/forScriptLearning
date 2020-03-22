rotateScreen(90) -- 设置屏幕坐标系
require("lib")  -- 加载基础方法库
math.randomseed(tostring(os.time()):reverse():sub(1, 6))  --放置随机种子

---定义全局变量：
spotNumber = 0  --当识别到图片就会加1
sandClock = 1 --循环识别图片次数过多即跳过，说明可能卡死了(因为一直找不到点，不能进行相应动作)打印log
fishTime = 0 --钓鱼次数

--获取pic子表的名称
function getTableName_p(tb)
    local tbtb = {}
    if tb.parent == bic then
        tbtb = bic
    else
        tbtb = pic
    end
    for k, v in pairs(tbtb) do
        for j, i in pairs(v) do
            if i == tb then
            return j
            end
        end
    end
    return nil
end
--获取pic子表的名称
function getTableName_p2(tb,tb2)
    for k, v in pairs(tb2) do
        if v == tb then
            return k
        end
    end
    return nil
end

-- ====颜色坐标都在此longitude and latitude=====----

--[[
    识别到东西  --》》点击/滑动操作 --》》验证是否工作 
    > 工作：结束这个操作，进入下个识别
    > 不工作：循环操作，直到work为止 或者 循环次数过多就截图上传服务器
        > 如果是游戏开启也就重启游戏；
        > 如果是任务小镇就：
        > 如果是battle区域就打斗一下；
--]]

pic = {} -- 图标集合
pic.launch = {} -- 从打开游戏到进入 parent = pic.launch

-- (bS)beforeStart==== 游戏开始前，比如登录、选区域、选人物等 ====
--[[
    TODO: 加0 
    table = {{动作标识, [有：图片就算识别到], 延迟时间},{没有图即0，或者[无：图片才算识别到]},{没有图即0，或者[有：图片才算识别到]}{父表标识}}
    取色代码for IDE：" {{1,{ %s }, 90,%d, %d, %d, %d},{0},{0},parent = pic.launch} "% (pointList,xMin, yMin, xMax, yMax)
    取色代码for 中控：{{1,{pointList},90,xMin, yMin, xMax, yMax},{0},{0},parent = pic.launch}
▶table[1][1]用于判断识别到后执行的动作：
    1，识别到就点击；
    2，识别到就跳转到func函数里；
    3，识别到就打架；
    4，识别到就走路；
    ...
▶table[1][8]用于赋值给mSleep，即每次动作完之后延时的时间；第一个表的最后一位数；
--]]
-- launch:开场
-- pic.launch.sysPop = {{1,{0x007AFF, -30, -4, 0x007AFF, 44, 3, 0x007AFF, -91, -139, 0x000000, -20, -142, 0x000000 }, 90, 275, 132, 857,497},{0},{0}, parent = pic.launch}  --IOS推送通知
-- pic.launch.updata = {{1,{ 0x007AFF, -289, -9, 0x007AFF, -236, 18, 0x007AFF, -120, -186, 0x000000, -96, -186, 0x000000 }, 90, 272,150, 861,490, 40000 },{0},{0}, parent = pic.launch}  --更新游戏
pic.launch.animationA = {{6,{0x8BBAD1, -76, -62, 0x7FADC6, 106, 94, 0x98C8DC, 8, -6, 0x88B7CE, 24, 47, 0x8EBBD2, 58, 21, 0x92BED5},90,369, 149, 551, 305},{0},{0},parent = pic.launch}  --开场动画点击一下
pic.launch.animationB = {{1,{0xFFFFFF, -20, -7, 0xFFFFFF, -20, -2, 0xFFFFFF, -20, 5, 0xFFFFFF, -13, 4, 0xFFFFFF, 15, 7, 0xFFFFFF, 8, 5, 0x37667F},90,1181, 24, 1216, 38},{0},{0},parent = pic.launch}-- 开场动画跳过点击
-- pic.launch.loginA =  {{1,{ 0xFFFFFF, 107, -2, 0x4B7FBB, -77, 13, 0xFF5809, -91, 0, 0xE80025, -84, -14, 0x1B1A25 }, 90,  717,475 , 974,536, 8000  },{0},{0}, parent = pic.launch} -- 用QQ登录
-- pic.launch.loginB =  {{1,{ 0xFFFFFF, 1, -111, 0x00ACED, -2, -280, 0x00ACED, -2, 103, 0x00ACED, 7, 259, 0x00ACED }, 90, 1023,13  ,1129,628  },{0},{0}, parent = pic.launch} 
-- pic.launch.nameConfirm=  {{1,{ 0xECDAAD, 17, -3, 0xE7D4A8, -47, -22, 0x945248, 61, -22, 0x945248, -45, 23, 0x642E24, 60, 23, 0x652E25 }, 90, 488,341 , 644,413   },{0},{0}, parent = pic.launch}-- 实名认证弹窗
-- pic.launch.agreement =  {{1,{ 0xE4D1A6, 4, -21, 0x98554B, 60, -21, 0x97544B, -28, -48, 0xF5F403, 6, -50, 0xF9F901, 68, -42, 0xFFFE00 }, 90, 615,331 , 771,421   },{0}, {0},parent = pic.launch}--同意用户协议
pic.launch.enterGame = {{1,{0xFFFFFF, 6, 0, 0xFFFFFF, 6, 6, 0xFFFFFF, -17, -3, 0xFFFFFF, 318, 7, 0x76DAEF, 326, 13, 0x87E7F5, 338, 3, 0x6ACCE9, 480, 9, 0x1EFF61, 486, 9, 0x1EFF61},90,652, 596, 1155, 612},{0},{0},parent = pic.launch} --点击【进入游戏】按钮
-- pic.launch.tutorialA = {{1,{ 0xFFF9EF, -12, -20, 0xFFF9EF, 62, -17, 0xFFF9EF, 54, 36, 0x3E3134, 1, 37, 0x413637 }, 90,  788,269 , 927,372},{{ 0xFEDD4D, 5, 0, 0xFEE252, 10, 0, 0xFFEB64, 10, 3, 0xFDEB5B }, 90,583, 479, 593, 482}, {0},parent = pic.launch } -- 新手引导--摇杆
-- pic.launch.chooseActor =  {{1,{ 0xFFF0B0, -21, 16, 0xFFF5C8, 20, 18, 0xFFF6CC, 2, 48, 0x1E212B, 0, 94, 0xFFEEAA, -22, 114, 0xFFF4C6, 7, 122, 0xFFF7D3, -1, 146, 0x1F212B, -3, 209, 0xFDF1BF, -3, 245, 0x1D1E2C, -19, 313, 0xFFF4C6, 1, 445, 0x1A1C28 }, 90,   7,23  , 128,539 ,4000},{0}, {0},parent = pic.launch} --选角色1
pic.launch.playVideoFromLaunch = {{1,{0x000000, 0, 44, 0x000000, -41, 44, 0x000000, -83, 44, 0x000000, -68, 28, 0x000000, -24, 28, 0x000000},90,1182, 32, 1265, 76},{{0x789696, -4, -3, 0xFFFFFF, 0, -3, 0x7A9595, 4, -3, 0xFFFFFF, 4, 0, 0x7A9191},90,1290, 36, 1298, 39},{{0x000000, 40, -4, 0x000000, 107, 0, 0x000000, 146, 2, 0x000000},90,564, 690, 710, 696},parent = pic.launch} --播放动画了
pic.launch.announcement = {{1,{0x9AD0CE, 0, -3, 0x97CBCB, -2, -3, 0xFFFFFF, 2, -3, 0xFFFFFF, 2, 2, 0xFEFFFF, 0, 2, 0x9AD0CE, -3, 2, 0xFDFFFF},90,1199, 74, 1204, 79},{0},{{0xFFFFFF, 1, 3, 0x1E252D, -3, 4, 0xFFFFFF, -1, 5, 0x202529, 3, 7, 0xFFFFFF, 9, 7, 0x1F262B, 12, 7, 0xFFFFFF, 12, 10, 0x282C2F, 1, 10, 0xFFFFFF, -7, 10, 0x1A2227, -4, 16, 0xFFFFFF, 1, 16, 0xFFFFFF, 7, 17, 0x121618, 8, 17, 0x0D1216, 11, 18, 0xFFFFFF, 13, 18, 0x1D262C, 7, 19, 0x26333C},90,147, 118, 167, 137},parent = pic.launch}--游戏公告
pic.launch.chooseActorToGoIn =  {{1,{0x2A3C54, -12, 0, 0x2A3C54, -36, -7, 0xC0CCD2, -33, -1, 0x2A3C54, -28, 3, 0xC6D1D6, -23, 3, 0x2A3C54, 19, 1, 0xC9D5D9, 19, -2, 0x2A3C54, 27, -2, 0x2A3C54, 27, 5, 0x35475E, 34, 1, 0xDCE7EC},90,1144, 691, 1214, 703},{0},{0},parent = pic.launch}-- 选好角色进入游戏
pic.launch.chooseFaceToGoIn =  {{1,{0x2A3C54, -1, -3, 0xECF5F4, 7, 5, 0xEEF5F5, 8, 0, 0x2A3C54, 16, -2, 0x2A3C54, 19, -8, 0x37495F, 16, -8, 0xEFF7F6, 24, -8, 0xEEF6F5, 28, -8, 0x2A3C54, 28, -6, 0x2A3C54, 28, -2, 0x2A3C54, 28, 3, 0x3A4C62, 39, 5, 0xECF4F3, 39, -2, 0x2A3C54},90,1178, 690, 1218, 703},{0},{0},parent = pic.launch}-- 选好角色脸型进入游戏
pic.launch.chooseAdornToGoIn = {{1,{0x34465D, 1, -7, 0x32445B, 6, -1, 0x36485E, 6, 5, 0x2B3E55, 11, 5, 0x304259, 17, -1, 0x2A3C54, 19, 6, 0x2A3C54, 26, -3, 0xDFE8E8, 29, -1, 0x2F4159, 32, -1, 0xD2D9DA, 39, -4, 0xDCE4E4, 41, -2, 0x2C3E56, 46, 1, 0xDDE5E5, 45, 7, 0x2A3C54},90,1180, 691, 1226, 705},{0},{0},parent = pic.launch} --选好装饰进入游戏
pic.launch.ConfirmManToGoIn = {{1,{0xFCFCFC, -3, -1, 0x689DB5, -3, 3, 0x538FAB, 5, 3, 0xF4F5F5, 7, -1, 0x4B89A7, 10, -8, 0xFFFFFF, 19, -8, 0xFEFEFE, 23, -10, 0x4B8AA7, 19, -10, 0xFFFFFF, 15, -10, 0x4C8BA7, 20, -6, 0x213D4A, 20, -1, 0xF5F6F6, 20, 3, 0xFFFFFF, 22, 6, 0x4B8AA7, 25, 6, 0x4B8AA7, 27, 5, 0x23404D},90,751, 424, 781, 440},{0},{0},parent = pic.launch} --确定形象进入游戏
pic.launch.animationC = {{1,{ 0xF3C193, 8, -2, 0xF2C192, -22, -18, 0x000001, 9, 19, 0x000001 }, 90, 1015,4   ,1118,61  },{0},{0}, parent = pic.launch} --又是动画
pic.launch.BuyHorseAd = {{1,{0xFAEDA5, -10, 1, 0x67977C, -10, -10, 0xFFFDB5, 1, -13, 0x578B81, 11, -11, 0xFFF7B1, 11, 0, 0x6C9C81, 10, 8, 0xF7E49C, 1, 10, 0x6F9F85},90,1266, 63, 1287, 86},{0},{{0x503A07, -4, 4, 0xDFC0AA, -8, 4, 0x543608, -8, 10, 0xE0C4AF, -8, 15, 0x602D09, -1, 15, 0x602D08, 7, 15, 0x612D07, 7, 18, 0xE8CFBD, 0, 18, 0x642B08, -7, 18, 0xE0C8B5, -7, 22, 0x692B0D, 9, 22, 0x6A2A09, 9, 24, 0xECD6C4, -7, 24, 0xE4D0BD},90,776, 128, 793, 152},parent = pic.launch} --出现兑换坐骑广告
pic.launch.loggingAward = {{1,{0xD2B4A4, -3, -2, 0xFFFFFF, 3, -2, 0xFFFFFF, 3, 0, 0xD4B6A4, 3, 3, 0xFDFDFD, 0, 3, 0xD3B5A3, -3, 3, 0xFEFFFE},90,1300, 105, 1306, 110},{0},{{0xEAC76A, 1, 6, 0xFFFFFF, -1, 12, 0xFFFFFF, 3, 15, 0xF3CD7A, 7, 16, 0xFFFFFF, 4, 26, 0xFFFFFF, -1, 30, 0xEDD37D, 3, 33, 0xFFFFFF, 7, 34, 0xEFD37D},90,1172, 647, 1180, 681},parent = pic.launch} --登录奖励弹窗
-- pic.launch.chooseVision = {{1,{ 0x612C30, 20, -12, 0x612C30, 20, -3, 0x612C30, 269, -244, 0x37211D, 430, -242, 0x37201C, 355, -238, 0xFFFFFF, 363, -239, 0xFFFFFF, 416, -233, 0xFFFFFF, 416, -226, 0x34211A, 360, -226, 0x34201B }, 90,  74,137 , 735,467 ,5000},{{ 0xECDAA9, 0, -6, 0xF0DFB2, 0, -20, 0xF8EBC1 }, 90,353, 518, 353, 538},{0},parent = pic.launch} --选择视角，2.5D
-- pic.launch.toGoIn =  {{1,{ 0xFFFFFF, -13, -7, 0x000000, -11, -4, 0x000000, -10, 2, 0xFFFFFF, -14, 2, 0x000000, -17, 7, 0x2E2E2E, -3, 9, 0x000000, -5, 5, 0x000000, -6, 3, 0x0A0A0A, -31, 5, 0x222222, -31, 0, 0x0B0B0B, -31, -8, 0x000000, -36, -12, 0xFFFFFF, -35, -7, 0x000000, -35, -4, 0x000000, -36, 2, 0x000000, -35, 10, 0x000000, -30, 11, 0x000000, -31, 16, 0xFFFFFF }, 90, 954,573 ,1026,607 ,12000},{0},{0},parent = pic.launch} -- 进入游戏


-- (mT)missionTown=== 任务小镇，用来领任务，升级装备等 ===
-- TODO: 使用table[1][1]=5 的动作时，需要将Y轴下移坐标填上。
pic.town = {}
pic.town.adoptAPet = {{5,{0xFFFFFF, -5, 4, 0x21353C, -2, 7, 0x142024, 0, 7, 0xFFFFFF, 3, 7, 0x20333B, 7, 7, 0xFFFFFF, 10, 7, 0x3B4A4F, 11, 7, 0xFFFFFF, 11, 7, 0xFFFFFF, 16, 7, 0xFFFFFF, 16, 12, 0xFFFFFF, 12, 12, 0xFFFFFF, 8, 12, 0xFFFFFF, 3, 12, 0xFFFFFF, -1, 12, 0x10191D, -3, 12, 0x0B1214, -3, 15, 0xF9F9F9, 0, 15, 0xFFFFFF, 2, 15, 0x22292C, 4, 15, 0x233840, 10, 15, 0xFFFFFF, 16, 18, 0xFFFFFF, 12, 19, 0x233940, 8, 19, 0xFFFFFF, 29, 19, 0xFFFFFF, 30, 17, 0xFFFFFF, 33, 17, 0x233840, 39, 17, 0xFFFFFF, 39, 15, 0xFFFFFF, 39, 13, 0xFEFEFE, 42, 13, 0xFFFFFF, 44, 13, 0xFFFFFF, 44, 10, 0x18262C, 44, 8, 0xFFFFFF, 41, 8, 0xFFFFFF, 31, 8, 0xFFFFFF, 33, 5, 0xFFFFFF, 37, 5, 0xFFFFFF, 41, 5, 0xFFFFFF, 37, 1, 0xFFFFFF, 31, 0, 0xFFFFFF, 28, 0, 0x23373E, 39, -1, 0xFFFFFF, 43, -1, 0x22363E},90,669, 25, 718, 45},{0},{0},parent = pic.town} --领养（两个字）宠物
pic.town.showLoveSymbol = {{1,{0xB4EFED, -8, 0, 0xB4EFED, -12, -2, 0xBEF3EF, -15, -10, 0xA2BBB5, -15, -12, 0xAFCAC4, -13, -14, 0x171A19, -12, -15, 0x101111, -15, -15, 0xDFFFF8, -13, -17, 0xDFFFF7, -10, -17, 0xDFFFF7, -8, -17, 0xDFFFF7, -8, -15, 0xDFFFF7, -9, -14, 0xDFFFF7, -5, -13, 0xE1FFF9, 7, -13, 0xDFFFF7},90,775, 311, 797, 328},{0},{0},parent = pic.town} -- 看到爱心标志
pic.town.dontLike = {{1,{0x4C8AA8, -8, -9, 0xEDEFF0, -3, -9, 0xFFFFFF, -5, -8, 0x5E6D74, -6, -7, 0x3C6F87, -8, -5, 0xE8ECEE, -10, -4, 0x4D849E, -7, -3, 0xF5F6F7, -5, -3, 0x7FA5B8, -4, -3, 0xF6F7F8, -1, -3, 0x587581, -1, -7, 0x5B92AA, 2, -9, 0xFDFDFD, 11, -8, 0xFAFAFB, 13, -7, 0x4B89A6, 10, -5, 0xF7F8F8, 8, -5, 0x5892AC, 5, -3, 0xF5F6F6, 2, -2, 0x4E8EA9, -5, 0, 0xFFFFFF, -8, 0, 0x4985A1, -8, 5, 0xEBEFF1, -5, 5, 0x467B93, -2, 5, 0xDADEDF, 2, 5, 0xF7F8F8, 4, 5, 0x4B6E7E, 5, 5, 0x4987A3, 8, 5, 0xF9FAFA, 11, 5, 0x508DAA, 11, 6, 0xA3C2D1, 9, 6, 0xFBFCFC, 8, 6, 0xA6AEB1, 6, 6, 0x4985A1, 5, 6, 0x4B8AA7, 3, 6, 0x5C737E, 1, 6, 0xF8F9F9, -2, 6, 0x677981, -4, 6, 0x4C86A0, -8, 6, 0xF2F3F4, -11, 8, 0x5799B0, -9, 8, 0x838F94, -6, 8, 0x4C8CA8, -2, 8, 0xEDF1F2, 1, 8, 0x5D717A, 4, 8, 0x4B8BA7, 11, 8, 0xF2F3F4, 14, 8, 0x4B8BA7, 14, 10, 0x4B8CA8, 11, 10, 0x406D80, 2, 10, 0x4B8CA8, -1, 10, 0x476978},90,767, 534, 792, 553},{0},{0},parent = pic.town} -- 有人喜欢就点不鸟他
pic.town.checkHand = {{1,{0x12150E, 4, 0, 0xFDFDFD, 9, 4, 0xFFFFFF, 10, 4, 0xA4A5A3, 9, 6, 0x4A4C47, 9, 8, 0xF4F4F3, 18, 15, 0xE6E6E6, 9, 15, 0x15170F, 2, 7, 0x10130D, -13, 5, 0xF7F7F7, -13, 3, 0x0D100A, -14, 21, 0x040403, -12, 22, 0xFFFFFF, -9, 21, 0x020201, -12, 23, 0xFFFFFF, -3, 23, 0xB0B0AF, -7, 24, 0x000000, -11, 24, 0xFFFFFF, -16, 25, 0x111111, -12, 25, 0xFFFFFF, -5, 25, 0x000000, -5, 26, 0xD2D2D2, -7, 26, 0xFFFFFF, -9, 26, 0x616161, -11, 26, 0xFFFFFF, -15, 26, 0xFFFFFF, -18, 26, 0x040505, -18, 28, 0xFFFFFF, -15, 28, 0x000000, -10, 28, 0x0C0C0C, -9, 28, 0x000000, -5, 28, 0xFFFFFF, -4, 28, 0xFFFFFF, -5, 33, 0x1A1A1A, -6, 33, 0xFFFFFF, -9, 33, 0x000000, -10, 32, 0xFFFFFF, -13, 32, 0xFFFFFF, -16, 32, 0xFFFFFF, -19, 32, 0x0E100D, -19, 34, 0x0E100B, -19, 35, 0x0E0E0E, -18, 35, 0x363636, -16, 35, 0xFFFFFF, -15, 36, 0x191919, -12, 36, 0x030303, -12, 37, 0xACACAC, -9, 37, 0xC0C0C0, -4, 37, 0xFFFFFF},90,879, 332, 916, 369},{0},{0},parent = pic.town} -- 出现查看的手
pic.town.wanted = {{1,{0xC36271, -8, -11, 0xB35361, -17, -18, 0xBF5E6D, 4, -17, 0xF5EADC, 12, -17, 0xBE5E6C, 17, -17, 0xBA5A67, 10, -9, 0xC16170, 9, 0, 0xECDDDB, 9, 8, 0xAF5262, -13, 12, 0xC8636E, -18, 14, 0xEDE2E0},90,1094, 103, 1129, 135},{0},{{0xD25B5B, -1, 7, 0xF4E9DE, -14, 7, 0xD25B5B, -12, 14, 0xECE6D6, -3, 14, 0xCF5C5C, 7, 15, 0xEFEFDE, 18, 16, 0xC96060, 24, 16, 0xEDE7D9, -6, 24, 0xD16260, -6, 29, 0xF1EADB, -13, 30, 0xEEEEDD, -13, 35, 0xCD5E5E, 8, 37, 0xEFE7DE, -1, 42, 0xD25B5B, 0, 51, 0xF4E9DE},90,859, 602, 897, 653},parent = pic.town} --通缉令出现
pic.town.noticeOfMySpace = {{1,{0xF5F6F6, 5, 0, 0xFBFBFB, 5, -1, 0xFFFFFF, -1, -5, 0xFDFDFD, -3, -9, 0x2A2827, 2, -18, 0xFFFFFF, 25, -22, 0xD44242, 24, -25, 0xD54242},90,420, 602, 448, 627},{0},{{0xEF5C51, 4, 0, 0xEC5A50, 20, 0, 0xEC5A50},90,111, 62, 131, 62},parent = pic.town} --提示点击空间
pic.town.closeMySpace = {{1,{0xA1D3D1, -4, -3, 0xFFFFFF, -7, -6, 0xFCFDFD, -9, -8, 0xFFFFFF, 0, -8, 0x6E9EA7, 8, -8, 0xFEFFFF, 4, -4, 0xFFFFFF, 7, 1, 0x7DB5B5, 6, 7, 0xF7FDFD, 0, 7, 0x85C1BE, -6, 7, 0xF7FFFF, -8, 0, 0x76AFAF},90,1270, 72, 1287, 87},{0},{{0xFFFFFF, 0, 2, 0xFFFFFF, -5, 2, 0xF6F9F9, -5, 4, 0x4D9185, -3, 4, 0x4D8E83, -1, 4, 0xFFFFFF, 2, 4, 0x4B8980, 7, 4, 0x49837D, 9, 4, 0x48827C, 9, 7, 0xFFFFFF, 8, 9, 0xFFFFFF, 4, 9, 0x4C8A81, 0, 9, 0xF1F6F5, -1, 9, 0x69A098, -2, 9, 0xF9FBFB, -5, 9, 0x4F9387, -6, 12, 0x54998D, -4, 12, 0xFFFFFF, -1, 12, 0x52948A, 0, 12, 0x519289, 6, 12, 0xFCFDFD, 8, 12, 0x4E8983, 8, 14, 0x5A938D, 3, 14, 0xFDFEFE, -2, 14, 0x55978D, -2, 16, 0xFEFEFE, 0, 16, 0xF7FAF9, 4, 16, 0x54948B, 8, 16, 0xF5F8F8, 10, 16, 0xFCFDFD, 12, 16, 0x578D89},90,1266, 201, 1284, 217},parent = pic.town} --关闭我的空间
pic.town.showCollectHand = {{1,{0xF1F2F2, -4, 0, 0x0B2925, -4, -3, 0x040F0C, -7, 6, 0x081412, -14, 5, 0x0D1E1C, -17, 5, 0x091210, -17, 6, 0xF8F9F8, -17, 7, 0xF8F9F9, -17, 10, 0x061713, -16, 10, 0x071714, -13, 11, 0x09201C, -8, 18, 0xFFFFFF, -11, 18, 0xFFFFFF, -10, 20, 0x000000, -8, 20, 0xFFFFFF, -8, 21, 0xFFFFFF, -7, 21, 0xFFFFFF, -15, 21, 0x000000, -18, 22, 0xFFFFFF, -20, 22, 0x050B0B, -19, 23, 0x050707, -17, 23, 0xFFFFFF, -15, 23, 0x000101, -11, 23, 0x070707, -7, 23, 0x000202, -12, 25, 0xFFFFFF, -12, 26, 0xFFFFFF, -9, 26, 0xFFFFFF, -7, 26, 0xFBFBFB, -9, 27, 0x0E0F0F, -12, 27, 0xFFFFFF, -13, 27, 0xFFFFFF, -18, 28, 0x020606, -17, 28, 0x010101, -13, 28, 0xFFFFFF, -12, 28, 0xFFFFFF, -8, 28, 0x000101},90,879, 333, 899, 364, 5000},{0},{0},parent = pic.town} --出现采集按钮
pic.town.showActivatedSymbol = {{1,{0xF8F9F9, 0, -2, 0x666B6E, -2, -1, 0x54585D, -4, 0, 0x7E7F7F, -5, 1, 0x686B6D, -7, 2, 0x474A4B, -7, 1, 0xEDEDED, -7, 3, 0xEDEDED, 0, 4, 0xECECEC, 3, 4, 0x414345, 4, 4, 0xF0F0F0, 5, 4, 0x414345, 7, 4, 0xF0F0F0, 7, -5, 0xF7F7F7, 4, -5, 0x9D9FA1, 1, -5, 0xF3F4F4, 1, -6, 0x676B6E, 1, -7, 0xF4F4F5, 1, -10, 0x2E363B, -1, -10, 0x454545, -1, -12, 0xFDFDFD, 2, -12, 0x2B3238, 4, -12, 0xFFFFFF, 4, -16, 0xFDFCFD, 3, -18, 0xFCFCFC, 2, -20, 0x525253, 3, -23, 0xFCFBFB, 3, -25, 0xFCFCFD, 1, -26, 0x0C1015, 3, -27, 0xFCFDFD, 3, -28, 0xD9D9DA, 15, -10, 0xF4F5F5, 17, -7, 0xF6F8F9, -11, -7, 0xEEEEEE, -12, -4, 0xF1F2F2, -11, 8, 0xE9E9E9},90,882, 306, 911, 342},{0},{0},parent = pic.town} --出现激活按钮
pic.town.showMap = {{7,{0xCBCFD9, 21, 2, 0xCED2DB, 31, 2, 0xD1D5DF, 14, 15, 0xCDD2E1, 28, 16, 0xCFD4DD, 59, 18, 0xD2D6E1, 52, 50, 0xCFD2DD},90,814, 281, 873, 331},{0},{{0x9AD0CE, -3, -3, 0xFFFFFF, -8, -3, 0x73A7AB, -8, -8, 0xFFFFFF, 0, -8, 0x72A1AB, 8, -8, 0xFFFFFF, 8, -1, 0x71AEAE, 8, 8, 0xF9FFFF, 0, 8, 0x79B8B4},90,1224, 93, 1240, 109},parent = pic.town} --发现地图
pic.town.acceptMission = {{1,{0x4B8BA7, -3, 0, 0xFFFFFF, -3, -10, 0xFFFFFF, -6, -10, 0x49585E, -6, -7, 0x4B8AA7, -10, -7, 0xFFFFFF, -10, -2, 0xFFFFFF, -12, -2, 0x4B8AA7, -16, -2, 0xFFFFFF, -20, -2, 0xFFFFFF, -21, -2, 0xFFFFFF, -21, 2, 0xFFFFFF, -19, 2, 0x4B8AA7, -19, 5, 0xFFFFFF, -21, 5, 0xFFFFFF, -20, 7, 0x213A45, -18, 7, 0x4988A3, -16, 7, 0x4B8BA7, -10, 7, 0xFFFFFF, -8, 7, 0x4B8BA8, -1, 7, 0x4B8BA7, 3, 7, 0xFFFFFF, 5, 7, 0x4B8BA7, 7, 7, 0xFFFFFF, 7, 5, 0x4B8AA7, 7, 4, 0x2A4D5D, 7, 2, 0xFFFFFF, 7, 1, 0x5691AC, 7, 0, 0x30596C, 7, -1, 0x8B9498, 7, -2, 0xFFFFFF, 7, -3, 0x6DA0B8, 7, -4, 0x325D70, 7, -5, 0x848E92, 7, -6, 0xFFFFFF, 7, -7, 0x94BACB, 7, -10, 0xFFFFFF, 12, -10, 0xFFFFFF, 17, -10, 0xFFFFFF, 18, -7, 0x4B8AA7, 18, 1, 0x4B8AA7, 20, 1, 0xFFFFFF},90,1153, 655, 1194, 672},{0},{0},parent = pic.town} --接受任务
pic.town.acceptMissionForsure = {{1,{0x4B8BA7, -11, -5, 0x3E7289, -9, -5, 0xFFFFFF, -6, -5, 0x3E7289, -4, -5, 0xFFFFFF, -4, -2, 0xFFFFFF, -9, -2, 0xFFFFFF, -12, -2, 0xDDE0E2, -12, 0, 0x4B8AA7, -9, 0, 0xFFFFFF, -6, 0, 0x4B89A7, -4, 0, 0xFFFFFF, -4, 2, 0xFFFFFF, -6, 2, 0xFFFFFF, -12, 2, 0xFFFFFF, -12, 5, 0x4B8AA7, -9, 5, 0xFFFFFF, -7, 5, 0x5DA1B7, -4, 5, 0xFFFFFF},90,768, 395, 780, 405},{0},{{0x2B3544, 1, 1, 0x262F3F, 0, 3, 0xA7B9C7, 5, 3, 0xA8B9C7, 6, 5, 0xA8B9C7, 3, 5, 0x202939, 0, 5, 0xA7B9C7, -1, 8, 0xA6B7C5, 1, 8, 0x293242, 3, 8, 0x95A5B4, 5, 8, 0x252F3F, 8, 8, 0xA8B9C7, 9, 10, 0xA8B9C7, 6, 10, 0x232C3C, 3, 10, 0xA7B9C7, 0, 10, 0x242D3D, -3, 10, 0xA7B9C7, -5, 13, 0xA7B9C7, -2, 13, 0x212A3A, 1, 13, 0xA7B9C7, 5, 13, 0xA8B9C7, 8, 13, 0x222B3B, 11, 13, 0xA8B9C7},90,647, 307, 663, 320},parent = pic.town} --确认进入任务
pic.town.showWhip = {{1,{0xCAEDE6, -7, 5, 0x778C81, -9, 9, 0xCEEEE9, -14, 13, 0xCEEEE8, -16, 24, 0xCCECE6, -25, 25, 0xCBEFE7, -25, 28, 0x596C61, -22, 30, 0x4F685D, -26, 33, 0xCBEAE5, 31, -8, 0xCFEFE9, 31, -13, 0x475548, 31, -22, 0xD2F2EA, 4, -25, 0xD1F1EB, -12, -21, 0x222D1F, -26, -21, 0xD2F2EA, -31, -29, 0x1D2916, -32, -40, 0xD2F2EC, -20, -48, 0x2C382B, -10, -48, 0xD3F4EC},90,1162, 592, 1225, 673},{0},{{0xED5A50, 10, 0, 0xEC5A50, 19, 0, 0xEC5A50},90,113, 62, 132, 62},parent = pic.town} --发现鞭子
pic.town.showWhipSign = {{1,{0xFFFFFF, -6, 5, 0xFFFFFF, -16, 10, 0x1F1D17, -12, 5, 0x201D17, -10, 3, 0x0E0D0B, -4, 3, 0x1A1616, 0, 2, 0x1B1816, 4, 2, 0x1C1A15, 11, -2, 0xFDFDFD, 15, -7, 0x232020, 13, -9, 0xFFFFFF, 11, -10, 0x2A2926, 11, -13, 0x1C1919, 9, -15, 0x1E1B1B, -1, -14, 0xFFFFFF, -3, -12, 0xFEFEFE, -3, -11, 0x171414, -6, -11, 0x171415, -13, -11, 0xFFFFFF, -19, -14, 0x110E0E, -19, -16, 0x201C1A, -20, -17, 0xFFFFFF, -20, -22, 0xF9F9F9, -20, -26, 0x1D191D, -17, -25, 0xFAF9FA},90,881, 312, 916, 348, 5000},{0},{{0xEF5C51, 3, 0, 0xED5A50, 11, 0, 0xEC5A50},90,724, 250, 973, 441},parent = pic.town} --出现驯服按钮
pic.town.tapAnywhere = {{1,{0xF0F8FB, -2, -1, 0x8C8E8D, 0, -8, 0xF0F8FB, -7, -8, 0x1E1B14, -9, -8, 0xF0F8FB, -12, -5, 0x2E2922, -12, -2, 0xF0F8FB, -12, 1, 0x1C170E, -10, 1, 0xF0F8FB, -7, 1, 0x565450, -10, 3, 0xF0F8FB, -10, 7, 0xF0F8FB, -10, 8, 0xF0F8FB, -8, 8, 0x211D1B, -6, 8, 0xF0F8FB, -1, 8, 0xF0F8FB, 3, 8, 0xF0F8FB, 6, 8, 0xF0F8FB, 7, 8, 0x23201D, 3, 4, 0x191410, -3, 4, 0x1E1B18},90,624, 645, 643, 661},{0},{0},parent = pic.town} --点击任意区域
pic.town.goByHorse = {{1,{0xFDFDFD, 0, 3, 0xFCFCFC, 3, 3, 0x4B8AA7, -2, 3, 0x4B8AA7, -7, 5, 0xE9EBEC, -7, 8, 0xFAFBFB, -7, 10, 0x3A687C, 0, 10, 0x3A687C, 0, 8, 0xFEFEFE, 7, 8, 0xF4F6F6, 8, 5, 0xD9DDDF, 7, -4, 0xECEEEF, 4, -4, 0x4B8AA7, 0, -4, 0xFCFCFC, 0, -6, 0xFCFCFC, -3, -6, 0x4B8AA7, -6, -5, 0xD6DCDE, 76, -24, 0xCF4F50, 71, -28, 0xCE4F50},90,1131, 630, 1214, 668},{0},{0},parent = pic.town} --点击出战
pic.town.closeHore = {{1,{0xA1D4D2, -3, -3, 0xFFFFFF, 0, -3, 0xAAD5D5, 3, -3, 0xFFFFFF, 3, -8, 0x70A0A6, -2, -8, 0x6F9EA8, -9, -8, 0xFFFFFF, -13, -8, 0x528490},90,1266, 72, 1282, 80},{0},{{0x84ABAE, 2, 0, 0xFFFFFF, 4, 0, 0x86ADB0, 6, 0, 0xFFFFFF, 8, 0, 0x7DA3A7, 10, 0, 0xFFFFFF, 10, 3, 0xFFFFFF, 10, 7, 0xFFFFFF, 8, 7, 0x7EA2A5, 6, 7, 0xFFFFFF, 4, 7, 0x80A6A8, 2, 7, 0xFFFFFF, 0, 7, 0x89AEB1, -2, 7, 0xFFFFFF},90,1284, 168, 1296, 175},parent = pic.town} --关闭马匹管理
pic.town.closePayTips = {{1,{0x9AD0CE, -3, 0, 0x9AD0CE, -3, -3, 0xFFFFFF, 0, -3, 0x97CBCB, 2, -3, 0xFFFFFF, 2, 0, 0x9ACECD, 2, 2, 0xFEFFFF, 0, 2, 0x9AD0CE, -2, 2, 0xFDFFFF},90,1004, 143, 1009, 148},{0},{{0x202939, -10, 0, 0x202939, -21, 0, 0x202939, -21, 4, 0xC3DEE9, -14, 4, 0x202939, -9, 4, 0xC3DEE9, -5, 4, 0x202939, 0, 4, 0xC3DEE9, 0, 9, 0x202939, -7, 9, 0x202939, -18, 9, 0x202939, -18, 13, 0xBAD8E6, -14, 13, 0x202939, -10, 13, 0xBAD8E6, -7, 13, 0x202939, -2, 13, 0xBAD8E6, -2, 19, 0x202939, -11, 19, 0xB6D6E4, -19, 19, 0x202939, -24, 19, 0xB6D6E4},90,684, 577, 708, 596},parent = pic.town} --关闭充值弹窗

-- (bp)battlePlace=== 打斗区域 ===
-- TODO: 注意【target】【direction】这里的图片要在giveyscss & 摇杆走路那里添加一下
pic.battle = {} -- 在打斗区域
pic.battle.tabMission = {{3,{0xFFFFFF, 28, 0, 0xFFFFFF, 63, 0, 0xFFFFFF, 89, -24, 0x5BEAF3, 89, -17, 0x54D8DF, 95, -20, 0x56DDE5, 101, -9, 0x5BEAF3, 116, -21, 0x5BEAF3, 119, -21, 0x5BEAF3, 123, -9, 0x56DEE6, 167, -18, 0x5BEAF3, 181, -18, 0x5BEAF3, 186, -19, 0x59E7EF, 197, -22, 0x5BEAF3},90,58, 158, 255, 182},{0},{{0x1C3445, 0, 9, 0x1C3445, -2, 19, 0x1C3445},90,23, 208, 25, 227},parent = pic.battle} --发现“任务、见闻、奇遇”三字+任务书
pic.battle.conversation1 = {{4,{0x85CAE7, 10, 0, 0x85CAE7, 9, 1, 0x57869B, 5, 1, 0x5B92A3, -1, 4, 0x86CCE9, 10, 4, 0x87CDEB, 10, 8, 0x87CDEB, 4, 8, 0x77B5D1, -1, 8, 0x86CBE9, -1, 12, 0x86CBE8, 5, 13, 0x5D92A8, 10, 12, 0x87CDEA, 17, 11, 0x88CEEC, 22, 9, 0x699FB9, 22, 4, 0x88CEEC, 22, 0, 0x669DB5, 22, -1, 0x76B4CF, 26, 2, 0x88CEEC, 27, 3, 0x4B7489, 39, -1, 0x88CEEC, 39, 4, 0x446B7B, 38, 7, 0x88CEEC, 38, 12, 0x86CCE9, 47, 2, 0x88CEEC, 48, 2, 0x37576B, 49, 2, 0x83C7E5},90,1198, 722, 1248, 736},{0},{0},parent = pic.battle} --发现自动跳过四个字
pic.battle.conversation2 = {{4,{0xE5FAFF, -4, -3, 0xE5FAFF, -8, -6, 0xE4FFFF, 0, -9, 0xE4F9FD, 5, -5, 0xE4FEFF, 10, -8, 0xE1FFFF},90,1280, 709, 1324, 744},{0},{{0x86CAE8, 0, 4, 0x86CBE9, 6, 4, 0x7BB6D2, 11, 4, 0x87CDEB, 11, 5, 0x86CAE8, 5, 5, 0x628AA1, 5, 8, 0x79B4CF, 0, 8, 0x86CBE9, 6, 9, 0x628AA1, 11, 9, 0x86CAE8},90,1198, 723, 1209, 732},parent = pic.battle} --发现对话白色箭头&自动跳过
pic.battle.tabTarget = {{3,{0xBF9D54, 3, -1, 0xC4AA5E, 6, -1, 0xC8AC5F, 11, 4, 0xC1A35B, 6, 4, 0xAA8D4D, -1, 4, 0xC9A859, 0, 8, 0xE2BA61, 5, 8, 0xCDA859, 10, 8, 0xE3BA61, 10, 12, 0xD8B15D, 19, 12, 0xAE904E, 22, 11, 0xCBA85A, 27, 12, 0xCEAE60, 27, 5, 0xE0B85F, 25, -1, 0xA6894A, 28, -1, 0xA6894A, 30, -1, 0xA6894B},90,92, 160, 123, 173},{0},{{0x1C3445, 0, 4, 0x1C3445, 8, 4, 0x1C3445, 13, 4, 0x1C3445, 13, 8, 0x1C3445, 8, 8, 0x1C3445, 0, 8, 0x1C3445, 1, 19, 0x1F3748, 1, 33, 0x1F3647, 10, 33, 0x1C3445, 11, 30, 0x1E3647, 15, 31, 0x1D3546, 15, 24, 0x273F4D, 11, 19, 0x263D4C},90,15, 198, 30, 231},parent = pic.battle} --有目标任务，识别到“目标”
pic.battle.ckickAssing1 = {{2,{0x18518A, 16, 0, 0x18518A, 32, 0, 0x18518A, 46, 0, 0x18518A},90,453, 146, 499, 146},{0},{{0xED5A50, 8, 0, 0xEC5A50, 25, 0, 0xEC5A50},90,113, 62, 138, 62},parent = pic.battle} --发现有怪兽蓝色血条+左上角猪脚红色血条，就等5s
pic.battle.ckickAssing2 = {{2,{0x7E4900, 15, 0, 0x7E4900, 41, 0, 0x7E4900},90,451, 147, 492, 147},{0},{{0xED5A50, 8, 0, 0xEC5A50, 25, 0, 0xEC5A50},90,113, 62, 138, 62},parent = pic.battle} --发现怪兽淡红色血条
pic.battle.ckickAssing3 = {{2,{0x00D485, 15, 0, 0x00D485, 41, 0, 0x00D485},90,451, 147, 492, 147},{0},{{0xED5A50, 8, 0, 0xEC5A50, 25, 0, 0xEC5A50},90,113, 62, 138, 62},parent = pic.battle} --发现怪兽绿色色血条
pic.battle.jumpToCastle = {{1,{0xED5A50, 8, 0, 0xEC5A50, 25, 0, 0xEC5A50, 1075, 464, 0xFFFFFF, 1070, 454, 0xFFFFFF, 1074, 446, 0xFFFFFF, 1083, 455, 0xFFFFFF, 1077, 490, 0xFFFFFF, 1049, 485, 0xFFFFFF, 1071, 422, 0x9CF0FE, 1063, 423, 0x9CEFFE},90,113, 62, 1196, 552},{0},{0},parent = pic.battle} --跳上城堡-向上箭头
pic.battle.interactedConversation1 = {{1,{0xE5EFF3, -72, 0, 0xE7F1F4, -123, -45, 0xD2E4EC, -94, -47, 0xBAD2DC, -37, -47, 0xBAD2DC, 106, -46, 0xBDD3DD, 65, 3, 0xE9F1F5, 154, 8, 0xEAF6FC, 130, 0, 0xEAF6FC, 131, -7, 0xC6D3D7},90,1007, 360, 1284, 415},{0},{0},parent = pic.battle} --发现交互式对话
pic.battle.playVideoFromBattle = {{1,{0x000000, 0, 44, 0x000000, -41, 44, 0x000000, -83, 44, 0x000000, -68, 28, 0x000000, -24, 28, 0x000000},90,1182, 32, 1265, 76},{{0x789696, -4, -3, 0xFFFFFF, 0, -3, 0x7A9595, 4, -3, 0xFFFFFF, 4, 0, 0x7A9191},90,1290, 36, 1298, 39},{{0x000000, 40, -4, 0x000000, 107, 0, 0x000000, 146, 2, 0x000000},90,564, 690, 710, 696},parent = pic.battle} --播放动画了
pic.battle.shakeHand = {{1,{0xB9EFEC, -16, -2, 0x283133, -18, -4, 0xCBFDFD, -23, -9, 0xD8FDF6, -8, -4, 0x4D5E5D, 13, -4, 0xCDF7F4, 17, -4, 0x202525, 13, -16, 0x171B1E, -7, -16, 0x1B2021, -5, 8, 0x3E6264, 20, 8, 0x1C2326},90,766, 311, 809, 335},{0},{0},parent = pic.battle} --出现握手图标
pic.battle.friendRequest = {{1,{0x4D8DA9, -3, -7, 0xFBFBFB, -3, 4, 0xFBFBFB, 7, 1, 0xFFFFFF, 7, 0, 0x638FA2, 7, -1, 0x49585E, 7, -2, 0xFFFFFF},90,758, 464, 768, 475},{0},{{0x2A3C54, 4, 0, 0x2A3C54, 11, 0, 0x2A3C54, 17, 0, 0x2A3C54, 21, 0, 0xA3B3C2, 19, 3, 0xA5B6C5, 10, 3, 0xA8B9C8, 5, 3, 0x2C3F57, 1, 3, 0xA7B9C7, 3, 8, 0x2B3E55, 5, 10, 0xAABBC9, 5, 13, 0xAABCCA, 1, 12, 0x2B3E56, -1, 15, 0x2A3C54, 1, 16, 0xA2B3C2, 5, 16, 0x2C3F57, 11, 16, 0xA8B8C7, 15, 16, 0x2A3C54, 16, 16, 0x2A3C54, 21, 16, 0xAABAC8, 11, 18, 0xA8BBC8},90,729, 347, 926, 387},parent = pic.battle} --好友请求同意
pic.battle.choosePicValue = {{1,{0x4B8BA7, 8, -43, 0x202939, 8, -62, 0x202939, 8, -67, 0xC0CDD9, 8, -71, 0x202939, 23, -71, 0x202939, 37, -71, 0x202939, 37, -68, 0xC2CEDA, 35, -62, 0x202939, 31, -60, 0xC1CDDA, 25, -54, 0xC2CFDB, 22, -54, 0x202939, 20, -52, 0xC6D3DF, 15, -52, 0x202939, 19, -46, 0xC6D3DF, 31, -46, 0xC6D3DF, 35, -46, 0x202939, 35, -38, 0xC6D3E0, 25, -40, 0xC6D3DF, 25, -43, 0x212A3A, 14, -42, 0x202939},90,666, 480, 703, 551},{0},{0},parent = pic.battle} --选择画质，中间的
pic.battle.showCollectHand = {{1,{0xF4F4F4, -4, -2, 0x252525, -6, -6, 0x202021, -9, -11, 0x000000, -10, -12, 0x212223, -11, -13, 0x212223, -11, -16, 0xFFFFFF, -16, -19, 0xFFFFFF, -19, -20, 0xFFFFFF, -12, -20, 0x252627, -8, -20, 0xFEFEFE, -8, -19, 0x202021, -4, -18, 0xFFFFFF, -1, -16, 0xFEFFFF, 1, -13, 0xFFFFFF, 5, -15, 0xFFFFFF, 3, -16, 0xFFFFFF, 3, -17, 0xFFFFFF, 5, -17, 0x1E1F21, 8, -15, 0xFFFFFF, 9, -15, 0xFFFFFF, 13, -12, 0x474A4D, 14, -10, 0x2E2F31, 14, -8, 0xFFFFFF, 14, -6, 0xFFFFFF, 17, -5, 0x2D2E30, 18, -1, 0xF4F4F4, 19, -1, 0x212121, 19, 2, 0xF4F4F4, 21, 3, 0x2B2C2C, -18, 9, 0xF9F9F9, -18, 11, 0x262728, -16, 11, 0x232426, -17, 6, 0x1B1B1C, -15, 7, 0xF5F5F5, -14, 9, 0xEEEEEE, -12, 8, 0xF7F7F7, -10, 8, 0xF7F7F7, -8, 7, 0x292A2B, -6, 7, 0x292A2B, -6, 9, 0xE7EFEF, -6, 12, 0xE7E7E7, -1, 12, 0xE7E7E7},90,719, 258, 1009, 442, 5000},{0},{0},parent = pic.battle} --发现采摘的手
pic.battle.showTheMagic = {{1,{0x434240, 0, -4, 0x393836, -2, -3, 0xF8F8F8, -4, -4, 0x504E4D, -7, -2, 0x676665, -9, 0, 0xEDEDED, -9, -1, 0x4D4C4B, -6, -6, 0xFFFFFF, -6, -8, 0x464545, -6, -10, 0xFFFFFF, -1, -11, 0xFFFFFF, 2, -11, 0xFFFFFF, 2, -13, 0xFFFFFF, 0, -13, 0x211F1D, -2, -13, 0x191716, -6, -13, 0xFFFFFF, -4, -15, 0xFCFCFC, -2, -17, 0xFCFCFC, -1, -17, 0x18181A, 2, -17, 0xC7C7C8, 2, -18, 0xFEFEFE, 2, -21, 0xFCFCFC, 1, -23, 0x9D9D9E, 1, -25, 0xFBFBFB, 1, -28, 0xFCFCFC, 6, -12, 0xFCFCFC, 6, -8, 0xF6F6F6, 6, -4, 0xF4F4F3, 10, -4, 0x242321, 11, 2, 0xC7C7C7, 11, 4, 0x272625, 11, 7, 0xEDEDED, 11, 9, 0xFFFFFF, 3, 9, 0x626464, 2, 9, 0x2F2F2F, 0, 9, 0xDFDFDF, -3, 9, 0xDFE1E1, -8, 9, 0x403E3D, -9, 9, 0xEDEDED},90,745, 260, 990, 438, 5000},{0},{0},parent = pic.battle} --施法
pic.battle.showHand1 = {{1,{0xF0F2F2, -5, 0, 0xF0F2F2, -9, 0, 0x676669, -10, -10, 0xF9F9F9, -12, -10, 0x747477, -15, -14, 0x000000, -17, -16, 0x060609, -17, -19, 0xFFFFFF, -14, -20, 0xFBFBFB, -11, -19, 0x131216, -10, -18, 0x131216, -9, -17, 0x1E1D21, -6, -17, 0xFDFDFD, -9, -20, 0xFDFDFD, -7, -22, 0x06040B, -5, -19, 0x57565A, -3, -19, 0xFFFFFF, 0, -16, 0xFFFFFF, 0, -19, 0x1F1E21, 2, -18, 0xFFFFFF, 4, -16, 0xFEFEFE, 6, -13, 0xFEFEFE, 10, -10, 0x030205, 10, -7, 0xF7FAFA, 13, -4, 0x212121, 13, -1, 0xF4F4F4, 15, 0, 0x030306, 15, 2, 0xF9F9F9, 17, 3, 0x06070A},90,727, 245, 957, 451, 4000},{0},{0},parent = pic.battle} --出现拿去按钮
pic.battle.showHand2 = {{1,{0xF5F6F6, 4, 11, 0xE7E9E9, 1, 19, 0x010001, 5, 19, 0x000001, 5, 22, 0xFFFFFF, 2, 22, 0x000000, 0, 22, 0xFFFFFF, 0, 26, 0xFFFFFF, 2, 26, 0x000000, 5, 26, 0xFFFFFF, 5, 29, 0xFFFFFF, 2, 29, 0x101010, 0, 29, 0xFFFFFF, -2, 29, 0x030303, -2, 31, 0x090909, 0, 32, 0xFFFFFF, 2, 32, 0xFFFFFF, 2, 34, 0x000001, 4, 34, 0xFFFFFF, 6, 34, 0x000000, 8, 34, 0xFFFFFF, 10, 34, 0x090909, 13, 34, 0xFFFFFF, 12, 32, 0xFFFFFF, 13, 30, 0x010101, 8, 30, 0x030405, 9, 27, 0xFFFFFF, 10, 26, 0x131313, 13, 26, 0xFFFFFF, 15, 25, 0x060808, 13, 25, 0xFFFFFF, 10, 23, 0x010102},90,898, 334, 915, 368, 4000},{0},{0},parent = pic.battle} --出现拿去按钮
pic.battle.checkHandFromBattle = {{1,{0xFFFFFF, 2, 0, 0x242C2D, 2, 4, 0x525555, 2, 7, 0xF3F4F4, -2, 9, 0x292F30, -2, 11, 0xEBEBEB, 0, 11, 0x1F312B, 4, 11, 0xE3E4E4, 3, 14, 0x081611, 9, 10, 0x2E3532, 9, 9, 0xECEDED, 9, 12, 0xEBEBEB, 11, 12, 0xEAEBEB, 12, 5, 0xF6F7F7, 11, 4, 0xF4F4F4, 12, 3, 0x050A08, 14, 4, 0x081410, 14, 7, 0xEDEDED, 17, 7, 0xECEDED, 19, 7, 0x081410, 19, 9, 0xECECED, 20, 9, 0x343A3C, 12, 16, 0xE2E2E2, 6, 18, 0x141616, 6, 21, 0xFFFFFF, 8, 22, 0x0F0F0F, 1, 22, 0xFFFFFF, -2, 23, 0x000101, 1, 23, 0xFFFFFF, 4, 23, 0x060606, 7, 24, 0xFAFAFA, 4, 26, 0x212121, 1, 26, 0xFFFFFF, -3, 26, 0x000101, -3, 27, 0xC3C3C3, 0, 27, 0xFFFFFF, 4, 27, 0xE2E2E2, 4, 28, 0x020202, -1, 28, 0xFFFFFF},90,729, 273, 960, 447, 5000},{0},{0},parent = pic.battle} --出现查看的手
pic.battle.awsomeSign = {{1,{0x5090AB, 0, -2, 0x466C7E, 0, -13, 0xFFFFFF, 0, -10, 0xFFFFFF, -4, -10, 0x4B8BA7, -4, -8, 0xFFFFFF, -8, -8, 0xFFFFFF, -8, -7, 0x667378, -12, -7, 0x4B8AA7, 4, -7, 0x667378, 4, -8, 0xFFFFFF, 7, -8, 0xFFFFFF, 11, -8, 0x4B8AA7, 4, -4, 0x4B8AA7, 1, -4, 0xFFFFFF, -2, -4, 0xFFFFFF, -5, -4, 0x4B8AA7, -6, -1, 0x4B8AA7, -3, -1, 0xFFFFFF, -11, 3, 0x4B8AA7, -7, 3, 0xFFFFFF, -5, 4, 0x2B4A57, -4, 4, 0x45819B, -3, 4, 0x3E535D, -1, 4, 0xFFFFFF, 2, 4, 0x4B8AA7, 4, 4, 0x2B4855, 6, 4, 0xFFFFFF, 8, 4, 0xF2F6F8, 10, 4, 0x508DA9, 9, 6, 0xFFFFFF, 7, 6, 0x44535B, 4, 6, 0x4B8BA7, -9, 7, 0x2B414A},90,632, 423, 655, 443},{0},{0},parent = pic.battle} -- 自动任务，太棒了
pic.battle.startChallenge = {{1,{0x4E8DA9, 0, -3, 0x1D2F38, 1, -3, 0x1D3038, 1, -4, 0xFFFFFF, 3, -4, 0xFFFFFF, 3, -8, 0xFFFFFF, 5, -8, 0x4C8BA7, 5, -4, 0xFFFFFF, 5, -3, 0x1D3038, 5, -1, 0x4E8EAA, 3, 0, 0xFFFFFF, 3, 9, 0xFFFFFF, 3, 12, 0x3E4F56, 5, 12, 0x4A8AA6, 7, 11, 0xFFFFFF, 10, 10, 0x455A64, 10, 7, 0xFFFFFF, 8, 5, 0x43535B, 9, 3, 0xFFFFFF, 11, 3, 0xFFFFFF, 14, 3, 0x4B8AA7, 16, 3, 0xFFFFFF, 16, 12, 0x273A43, 18, 11, 0xFFFFFF, 21, 9, 0xFFFFFF, 18, 9, 0x4B8AA7, 18, 6, 0x4B8AA7, 19, 5, 0x24404D, 19, 3, 0xFFFFFF, 18, 2, 0xFCFDFD, 18, 0, 0x2E5566, 18, -2, 0xFFFFFF, 19, -4, 0xFFFFFF, 18, -5, 0x4E8CA8, 16, -7, 0xFFFFFF, 13, -7, 0x4B8AA7, 11, -7, 0xFFFFFF, 11, -9, 0xFFFFFF, 9, -8, 0x4B8AA7, 6, -8, 0x4C8BA7},90,1027, 635, 1048, 656},{0},{0},parent = pic.battle} --开始挑战
pic.battle.leaveChallenge = {{1,{0xF5F7F8, 0, -14, 0xFDFDFD, -4, -14, 0x4B8AA7, -9, -11, 0xEAEDEE, -8, -10, 0x4D5F67, -8, -9, 0x3F758D, -4, -9, 0xF3F4F5, 0, -9, 0x3E738B, 0, -10, 0x51626A, 0, -11, 0xEAEBEC, 4, -11, 0xEBEEEF, 4, -8, 0xF3F5F6, 8, -8, 0x4C8AA7, 8, -9, 0x3F758D, 8, -10, 0x4D5F67, 8, -11, 0xEAEDEE, 11, -5, 0x4B89A7, 8, -5, 0xFAFBFC, 3, -6, 0xF9FBFB, 0, -6, 0xF6F9FA, 0, -7, 0x6198B2, -4, -7, 0x556D77, -6, -7, 0xFEFEFE, -10, -6, 0x4C8AA7, -10, -2, 0x538FAB, -5, -2, 0xECEEEF, -1, -2, 0x538FAB, 4, -2, 0xE9EBEC, 8, -2, 0x4E85A0, 8, 0, 0xF5F7F8, 0, 0, 0xF5F7F8, -9, 0, 0xF5F7F8, -11, 2, 0x335E71, -11, 3, 0x4B8AA7, -6, 3, 0xEDEFF0, -1, 3, 0x4B8AA7, -1, 2, 0x2F576A, 0, 2, 0x2F576A, 4, 2, 0xE7E9EA, 4, 4, 0xE7E9EB, 7, 4, 0x508FAB, 7, 7, 0x4C8BA8, 5, 7, 0x8A9BA2, 1, 7, 0x4C8CA8, -7, 7, 0x365461, -11, 7, 0x4987A2, -9, 8, 0x294A59, -2, 9, 0x4D8DA9},90,784, 623, 806, 646},{0},{0},parent = pic.battle} --放弃挑战
pic.battle.leaveChallengeForsure = {{1,{0xFCFCFC, -2, -2, 0x4A7A91, 2, -2, 0x40768F, 5, -2, 0xF3F4F5, 5, 2, 0xF3F5F5, 3, 2, 0x2E4C5B, 0, 2, 0xECEEEE, -3, 2, 0x274756, -3, 5, 0xEAEFF1, 0, 5, 0xFDFDFD, 3, 5, 0xEAEFF1, 2, 8, 0x61A2B8, 0, 8, 0xECEEEF, -3, 8, 0x4B8AA7, -6, 8, 0xEDEFF0, -11, 7, 0xEDF2F5, -11, 5, 0x508BA6, -11, 2, 0x508BA6, -11, -2, 0xEDF2F5, -10, -5, 0x4B8AA7, -10, -7, 0x253F4B},90,743, 427, 759, 442},{0},{{0xA4B7C5, 2, 0, 0x3F5268, 5, 0, 0xA4B7C5, 5, 2, 0x506378, 2, 2, 0x30435B, 0, 2, 0x506378, 0, 4, 0xA5B7C5, 2, 4, 0x405269, 5, 4, 0xA5B7C5, 5, 5, 0x67798C, 2, 5, 0x35475E, 0, 5, 0x67798C, 0, 8, 0xA7B8C7, 5, 8, 0xA7B8C7},90,670, 340, 675, 348},parent = pic.battle} --确定离开副本
pic.battle.startMission = {{1,{0xF8D480, -15, 5, 0xF9DA83, -21, 10, 0x584B3A, -24, 16, 0x584B3A, -18, 16, 0xFADF86, -18, 19, 0x584A3A, -23, 19, 0x584B3A, -23, 24, 0x5A4A39, -19, 24, 0xFCE88A, -20, 31, 0xFFEC8A, -23, 31, 0x584B3A, -27, 31, 0xFDF18E, -15, 32, 0xFCEB8B, -15, 30, 0x584B3A, -13, 30, 0x584B3A, -7, 31, 0xFBE789, -3, 31, 0xFCE688, -3, 29, 0x584B3A, -6, 29, 0x584B3A, -9, 26, 0x584B3A, -6, 26, 0xFBE287, -6, 24, 0xFAE186, -6, 22, 0xFADF85, -6, 19, 0x584B3A, -6, 16, 0xFADB83, -6, 13, 0xF9DA82, -9, 13, 0x584B3A, -9, 11, 0x584B3A, -6, 10, 0x584B3A, -3, 10, 0x584B3A, -1, 10, 0x665741, 1, 10, 0xF9D782, -1, 19, 0x584A39, -1, 21, 0xFADD85, -1, 27, 0xFCE287, -1, 29, 0x685C3D, -1, 32, 0xFCE789},90,323, 578, 351, 610},{0},{0},parent = pic.battle} --开启任务
pic.battle.receiveMission = {{1,{0x75C0CA, 0, -3, 0xFFFFFF, -5, -3, 0xFFFFFF, -5, -4, 0x9AD2D9, -2, -4, 0x9AD2D9, 2, -4, 0x9AD2D9, 7, -4, 0xFEFEFF, 7, -6, 0xFEFEFF, 1, -6, 0xFFFFFF, -7, -6, 0xFFFFFF, -11, -6, 0x61BBC4, -11, -8, 0x60BAC4, -8, -8, 0x72C2CB, -6, -8, 0xFFFFFF, -3, -8, 0x68BEC7, -1, -8, 0xFFFFFF, 2, -8, 0x70C1CB, 4, -8, 0xFFFFFF, 7, -8, 0x5FBAC4, 7, -9, 0x64BCC5, 9, -11, 0x5DBAC3, 6, -11, 0xFFFFFF, 2, -11, 0xFFFFFF, -3, -11, 0xFFFFFF, -7, -11, 0xFFFFFF, -10, -11, 0x6EC1C9, -1, -13, 0x5ABAC3},90,204, 567, 224, 580},{0},{{0xEF5C51, 7, 0, 0xEC5A50, 24, 0, 0xEC5A50},90,112, 62, 136, 62},parent = pic.battle} --接受任务
pic.battle.getMissionDone = {{1,{0x6EBDC7, -2, 0, 0xFCFEFE, -5, 0, 0x69BBC5, -8, 0, 0xFDFEFE, -10, 0, 0x69BBC5, -10, -3, 0x65BBC5, -6, -3, 0xFFFFFF, -4, -3, 0xFFFFFF, 0, -3, 0x79C4CD, -1, -6, 0x61BAC5, -4, -6, 0x60BBC4, -7, -6, 0xFBFDFE, -10, -6, 0x60BBC4, -10, -9, 0x5DBAC3, -7, -8, 0xFFFFFF, -3, -8, 0xFFFFFF, -3, -10, 0x5DBAC3, 1, -10, 0xFFFFFF, 4, -10, 0x71C2CA, 9, -10, 0x5DBAC3, 6, -8, 0xFFFFFF, 6, -10, 0xFAFDFD, 2, -8, 0xFFFFFF, 2, -5, 0xFBFDFE, 4, -5, 0x64BBC6, 6, -4, 0xFFFFFF, 4, -4, 0x71C0CA, 4, -1, 0xFFFFFF, 3, 2, 0xFFFFFF, 6, 2, 0x88C9D1, 7, 3, 0xFFFFFF, 10, 3, 0x6FBCC6, 10, 5, 0x72BDC7, 6, 5, 0xFFFFFF},90,203, 569, 223, 584},{0},{{0xEF5C51, 6, 0, 0xEC5A50, 19, 0, 0xEC5A50},90,112, 62, 131, 62},parent = pic.battle} --完成任务
pic.battle.giftConfirm = {{1,{0x4B8BA7, 0, -4, 0x34444C, 0, -5, 0xFFFFFF, 3, -5, 0xFFFFFF, 5, -5, 0x4E8EAA, 3, 0, 0xFFFFFF, 3, 5, 0xFFFFFF, 3, 7, 0x294B59, 5, 7, 0x4B8BA7, 7, 7, 0xFDFDFD, 10, 4, 0xFFFFFF, 14, 4, 0x4B8AA7, 18, 4, 0xFFFFFF, 21, 4, 0x4B8AA7, 18, 0, 0x4B8AA7, 16, 0, 0xFFFFFF, 14, 0, 0x4A88A5, 12, 0, 0xFFFFFF, 10, 0, 0x4B8AA7, 11, -3, 0x4B8AA7, 14, -5, 0xFFFFFF, 14, -8, 0xFFFFFF, 14, -10, 0xFFFFFF, 12, -10, 0x4B8AA7, 16, -10, 0x4B8AA7},90,668, 465, 689, 482},{0},{{0xE2EEF4, -6, 0, 0x202939, -4, -3, 0x202939, -9, -2, 0xE2EEF4, -11, -3, 0x212A3A, -13, -3, 0xE2EEF4, -10, -5, 0xE2EEF4, -6, -7, 0x202939, -3, -7, 0xE2EEF4, 3, -7, 0x202939, 3, 1, 0x202939, 6, 1, 0xE2EEF4, 6, 9, 0xE2EEF4, 3, 9, 0x202939, 9, 9, 0x202939, 9, 12, 0x202939, 13, 12, 0xE2EEF4, 5, 12, 0x202939, 1, 13, 0xE2EEF4, -4, 13, 0xE2EEF4, -6, 13, 0x202939, -6, 9, 0x202939, -6, 7, 0x202939, -9, 7, 0xE2EEF4, -10, 5, 0x202939, -11, 3, 0xE2EEF4, -6, 3, 0x202939, -2, 4, 0x202939, -2, 1, 0xE2EEF4},90,749, 216, 775, 236},parent = pic.battle} --收礼确认
pic.battle.matchingByMyself = {{1,{0x4A87A4, -3, 0, 0xFBFBFC, -6, 0, 0x4B89A6, -6, 3, 0xFBFBFC, -9, 3, 0x4B89A6, -9, 6, 0xFAFBFC, -9, 8, 0x273F49, -9, 9, 0x4B88A3, -1, 5, 0x4B89A6, 6, 5, 0xFAFAFB, 8, 6, 0xFAFAFB, 9, 7, 0xF7F8F9, 8, 8, 0x25414F, 2, 0, 0xFAFBFC, 3, -4, 0x4B88A6, -4, -4, 0x4B88A6, -3, -6, 0x4B88A6, 2, -6, 0x4B88A6, 2, -9, 0x4B88A6, 0, -9, 0xFAFBFC, -3, -9, 0x4B89A6, -3, -11, 0x4B89A6, -1, -11, 0xFAFBFC, 2, -11, 0x4B88A6, 2, -12, 0x518FAC, 0, -12, 0xFAFBFC, -3, -12, 0x4B89A6, -25, -29, 0xE1F6FB, -3, -29, 0xE2F6FB, 14, -29, 0xE2F6FB},90,887, 636, 926, 674},{0},{0},parent = pic.battle} --3v3时点击“个人匹配”
pic.battle.readyToFightWith3people = {{1,{0x4987A3, -2, 0, 0xEDEFEF, -5, 4, 0xFBFCFC, -9, 4, 0x4B8AA7, -3, 4, 0x496775, -1, 4, 0x4B8AA7, 2, 4, 0x4B8AA7, 4, 4, 0x546E79, 6, 4, 0xFCFDFD, 9, 4, 0x4E8CA9, 9, 7, 0xFEFEFE, 7, 7, 0xAAB2B5, 4, 7, 0x4B8AA7, -4, 7, 0x4B8AA7, -8, 7, 0xFDFDFD, -11, 7, 0x5B94AE, -9, 10, 0x475F6A, -6, 10, 0x4C8CA8, 8, 10, 0x4985A0, 10, 10, 0x35525F, -3, -6, 0x4B89A6, 0, -6, 0xFFFFFF, 3, -6, 0x4B8AA7, 2, -9, 0x4B8AA7, -1, -9, 0xEDF1F2, -4, -9, 0x3E677A, -5, -9, 0x4885A1},90,738, 426, 759, 445},{0},{{0xA4B6C4, 6, 0, 0x35475E, 11, 0, 0x9BAEBD, 11, 3, 0x485B70, 10, 5, 0x2D4057, 7, 5, 0xA4B6C4, 4, 5, 0xA4B6C4, 2, 8, 0xA4B6C4, 5, 8, 0x34465E, 7, 8, 0x2C3F57, 12, 8, 0xA4B6C5, 11, 11, 0x2F4259, 11, 13, 0x2B3D55, 11, 17, 0xA4B6C5, 8, 16, 0x384B62, 5, 16, 0x405269, 0, 16, 0xA4B5C4, 1, 14, 0x3F5168, 5, 14, 0xA4B6C4, 6, 12, 0xA4B6C4, 4, 12, 0xA4B6C4, 4, 10, 0xA4B6C4},90,688, 314, 700, 331},parent = pic.battle} -- 3V3排位赛加入
pic.battle.okToFightWith3people = {{1,{0xB79252, 0, -5, 0xFFFFFF, -3, -5, 0xB89354, 2, -5, 0xB89353, 0, -9, 0xB99454, -2, -9, 0xFDFDFD, -5, -9, 0x7C6338, -6, -9, 0xB89353, -7, 2, 0xB89353, -3, 3, 0x7C643B, -1, 3, 0xB89353, 4, 3, 0xFFFFFF, 7, 3, 0xB99353, 7, 6, 0xFFFFFF, 3, 6, 0xB89353, -4, 6, 0xB89352, -7, 6, 0xFFFFFF, -11, 6, 0xB99353, -13, 9, 0xB99353, -10, 9, 0xFCFCFB, -7, 9, 0xB89353, -3, 9, 0xB99453, 6, 9, 0xB89555, 9, 9, 0xF7F7F6, 12, 9, 0xB99453, -36, -7, 0xB89353, -33, -7, 0xFFFFFF, -30, -7, 0xFFFFFF, -27, -7, 0xFFFFFF, -24, -7, 0xB89353, -24, -4, 0xB99353, -26, -4, 0xFFFFFF, -26, 0, 0xFFFFFF, -29, 0, 0xB89353, -32, 0, 0xFFFFFF, -35, 0, 0xB89353, -35, 8, 0xFCFCFB, -32, 8, 0xB18D50, -30, 9, 0xFFFFFF, -25, 9, 0xB99453, -26, 6, 0xFFFFFF, -22, 6, 0xFFFFFF, -22, -2, 0xFFFFFF, -22, -8, 0xFFFFFF, -22, -10, 0xB89353, -19, -8, 0xFFFFFF, -19, -7, 0x564C3D, -17, -7, 0x564C3D, -15, -7, 0xFFFFFF, -13, -7, 0xB89353, -13, 0, 0xB89353, -15, 0, 0xFFFFFF, -15, 6, 0xFFFFFF, -15, 12, 0xBB9655, -17, 10, 0xB99454, -17, 8, 0x564C3D, -19, 8, 0x564C3D, -22, 8, 0xFFFFFF},90,903, 454, 951, 476},{0},{0},parent = pic.battle} -- 3V3排位赛加入

--- 零散小任务的图片
bic = {}
bic.dressWeapon = {} -- 穿装备
-- bic.dressWeapon.seeProperty =  {{13,{ 0x361D24, 0, 3, 0xEBC58B, -2, 3, 0x351C24, -2, 6, 0xE0BB85, -1, 6, 0x593E38, 0, 6, 0xEBC58B, 0, 8, 0xEBC58B, -1, 8, 0x493030, -2, 8, 0xE4BE87, -2, 10, 0xD5B17F, -1, 10, 0x462D2E, 0, 10, 0xEBC58B, 0, 16, 0xEBC58B, -2, 16, 0x382027, 9, 0, 0x331C22, 9, 2, 0xE3BD86, 7, 2, 0x371F24, 5, 2, 0xC7A477, 5, 4, 0xE0BB85, 9, 4, 0xEDC78C, 7, 7, 0x351D24, 9, 10, 0xECC68C, 7, 10, 0xC4A275, 9, 13, 0xE3BD87, 7, 13, 0x341C23, 9, 17, 0xD3AF7E, 7, 17, 0xCAA779, 4, 17, 0xC2A075 }, 90,614, 250, 625, 267},{0},{0},parent = bic} --识别到属性
-- bic.dressWeapon.dressUp = {{1,{ 0x4C2933, -2, 3, 0x4A2831, 0, 3, 0xD8C49D, 0, 5, 0xDCC8A0, -2, 5, 0x492630, -2, 7, 0x482530, 0, 7, 0xE6D3A8, 0, 9, 0xD8C49D, -2, 9, 0x45242F, -2, 11, 0x43242E, 0, 11, 0xD7C39D, 0, 13, 0xD7C39D, -2, 13, 0x41222D, -2, 15, 0x3F222C, 0, 17, 0xEBD9AC, -3, 17, 0xD8C59E, -5, 17, 0xD8C59E, -8, 17, 0x3D202B }, 90,593, 597, 601, 614},{0},{0},parent = bic} --穿上装备
-- bic.Fishing.f1 =  {{1,{ 0x281410, -7, -2, 0xC33A4B, -8, -8, 0xC04148, 7, -17, 0x7C4929 }, 90, 293,178 , 989,566 },{0},{0},parent = bic} 

--===封装函数区域===---

-- pic's action 识别到图片后做相应的动作
function picAction( tablex )
    if tablex[1][1] == 1 then -- 点击直到效果产生（即图片消失了）
        repeat
            sandClock = sandClock + 1
            rTab(xa, ya)
            mSleep(tablex[1][8] or math.random( 1000, 2000 ) )
            xa, ya = findMultiColorInRegionFuzzy(tablex[1][2], tablex[1][3], tablex[1][4], tablex[1][5], tablex[1][6], tablex[1][7])
        until xa == -1 or xb ~= -1 or sandClock>6
        if sandClock > 6 then
            logDebug("pic的子表"..getTableName_p(tablex).."可能卡住了")
        end
    elseif tablex[1][1] == 2 then  -- 默默等待5s
        mSleep(5000)
    elseif tablex[1][1] == 3 then  -- 点击任务位置，自动干啥
        rTab(126, 215)
        mSleep(math.random( 2500, 5000 ))
    elseif tablex[1][1] == 4 then --发现对话，点击屏幕中心任意区域跳过
        rTab(674, 362, 180)
    elseif tablex[1][1] == 5 then --领养宠物
        local petNub = math.random( 1, 3 )
        if petNub == 1 then
            rTab(264, 524)
        elseif petNub == 2 then
            rTab(656, 526)
        else 
            rTab(1053, 526)
        end
        mSleep(1500)
        rTab(667, 547) --点击确定
    elseif tablex[1][1] == 6 then --识别到图片就点一下，而不是点到图片没有
        rTab(xa, ya)
    elseif tablex[1][1] == 7 then --打开地图了，准备划
        tMove(182, 160,1142, 172,math.random( 5,8 )) --向右划一下
        tMove(361, 291,921, 304,math.random( 5,8 )) --向右划一下
        tMove(362, 385,939, 388,math.random( 5,8 )) --向右划一下
        tMove(364, 513,946, 501,math.random( 5,8 )) --向右划一下
        kTab({{0x9AD0CE, -3, 0, 0x9AD0CE, -3, -3, 0xFFFFFF, 0, -3, 0x97CBCB, 2, -3, 0xFFFFFF, 2, 0, 0x9ACECD, 2, 2, 0xFEFFFF, 0, 2, 0x9AD0CE, -3, 2, 0xFDFFFF},90,1229, 98, 1234, 103}) --关闭
    elseif tablex[1][1] == 8 then --发现就点击，不验证有没有点上，用来点任务村的任务
        rTab(xa, ya)
        mSleep(tablex[1][8] or math.random( 2000, 3000 ) )
    elseif tablex[1][1] == 9 then --发现是对话，就点击一个位置
        rTab(695,366,30)
    elseif tablex[1][1] == 10 then --发现是拍照，就拍照
        rTab(1059,73)
        mSleep(2000)
        rTab(936,136)
    elseif tablex[1][1] == 11 then --转职的的弹窗，选择左边那个
        rTab(379,492)
    elseif tablex[1][1] == 12 then --识别到是升级装备
        rTab(393,504) --点击进入
        mSleep(math.random( 1500, 2000 ))
        loopIronMan(bic.dressWeapon, pic.town)
    elseif tablex[1][1] == 13 then --识别到是升级装备里的查看属性
        rTab(774,168)
    elseif tablex[1][1] == 14 then --识别到是升级装备里的查看属性
        rTab(563,462,40)
    elseif tablex[1][1] == 15 then --垂钓
        fishTime = fishTime + 1
        if fishTime > 3 then  -- 如果钓鱼次数大于3次就点任务
            rTab(120,212)
            return loopCaptain( pic.town )
        end
        rTab(744,417)
        mSleep(6000)
        loopIronMan(bic.Fishing, pic.town)
    elseif tablex[1][1] == 16 then --接受三倍任务
        tab(461,409) --先把默认选中
        mSleep(math.random( 1000, 1500 ))
        rTab(551,347) --点击领取
    elseif tablex[1][1] == 17 then --拾取物品
        rTab(748,419) -- 拾取
        mSleep(math.random( 4000, 5000 ))--给5s取东西时间
    elseif tablex[1][1] == 18 then --清理红色背包（满
        rTab(678,537) --点击背包
        mSleep(math.random( 1000, 1500 ))
        rTab(1042,548) --点击分解
        mSleep(math.random( 1000, 1500 ))
        tab(596,111)  --点击蓝色
        mSleep(math.random( 1000, 1500 ))
        rTab(630,205) --点击分解
        mSleep(math.random( 1000, 1500 ))
        rTab(695,378) --确认分解
        mSleep(math.random( 1000, 1500 ))
        rTab(990,36) --点击材料
        mSleep(math.random( 1000, 1500 ))
        rTab(990,36) --点击材料
        mSleep(math.random( 800, 1000 ))
        rTab(1041,548) --点击出售
        mSleep(math.random( 800, 1000 ))
        tab(431,78) --点击杂物
        mSleep(math.random( 800, 1000 ))
        tab(636,76) --点击声望材料
        mSleep(math.random( 800, 1000 ))
        tab(445,117) --点击白色装备
        mSleep(math.random( 800, 1000 ))
        tab(623,117) --点击蓝色装备
        mSleep(math.random( 800, 1000 ))
        rTab(546,491) --点击出售
        mSleep(math.random( 800, 1000 ))
        rTab(717,28) --点击关闭
        mSleep(math.random( 800, 1000 ))
        rTab(1085,39) --点击消耗（去掉消耗红点）
        mSleep(math.random( 800, 1000 ))
        rTab(731,325) --退出背包
        mSleep(math.random( 800, 1000 ))
    end
    
end

--[[
(superMeta)找到某界面特有标识，点击对应按钮并检查是否work，不断循环直到点击任务完成
wtd(what to do)找到这个界面时做啥：
    - 1:执行这个界面该有的动作
    - 2:return到对应的小任务里

--]]
function superMeta( table )
    table = setmetatable(table, {
        __call = function ( table, wtd ) --wtd,用于标识调用表的元表方法干嘛。1--识别到图片后执行动作；2--识别到图片后进入图片所在小任务流。
                    -- logDebug("我开始找了")
                    if table[2][1] == 0 and table[3][1] == 0 then -- 当取反图片、取正图片都没有时候
                        xa, ya = findMultiColorInRegionFuzzy(table[1][2], table[1][3], table[1][4], table[1][5], table[1][6], table[1][7])
                        xb, yb = -1, -1
                        xc, yc = 1, 1
                    elseif  table[2][1] ~= 0 and table[3][1] == 0 then --当取反图片有，取正图片没有时候
                        keepScreen(true)
                        xa, ya = findMultiColorInRegionFuzzy(table[1][2], table[1][3], table[1][4], table[1][5], table[1][6], table[1][7])
                        xb, yb = findMultiColorInRegionFuzzy(table[2][1], table[2][2], table[2][3], table[2][4], table[2][5], table[2][6])
                        keepScreen(false)
                        xc, yc = 1, 1
                    elseif table[2][1] == 0 and table[3][1] ~= 0 then --当取反图片没有，取正图片有的时候
                        keepScreen(true)
                        xa, ya = findMultiColorInRegionFuzzy(table[1][2], table[1][3], table[1][4], table[1][5], table[1][6], table[1][7])
                        xc, yc = findMultiColorInRegionFuzzy(table[3][1], table[3][2], table[3][3], table[3][4], table[3][5], table[3][6])
                        keepScreen(false)
                        xb, yb = -1, -1
                    elseif table[2][1] ~= 0 and table[3][1] ~= 0 then --当取反图片，取正图片都有的时候
                        keepScreen(true)
                        xa, ya = findMultiColorInRegionFuzzy(table[1][2], table[1][3], table[1][4], table[1][5], table[1][6], table[1][7])
                        xb, yb = findMultiColorInRegionFuzzy(table[2][1], table[2][2], table[2][3], table[2][4], table[2][5], table[2][6])
                        xc, yc = findMultiColorInRegionFuzzy(table[3][1], table[3][2], table[3][3], table[3][4], table[3][5], table[3][6])
                        keepScreen(false)
                    end             
                    if xa ~= -1 and ya ~= -1 and xb == -1 and yb == -1 and xc ~= -1 and yc ~= -1 then
                        logDebug("find the pic "..getTableName_p(table))
                        spotNumber = spotNumber +1 --识别到图片就+1
                        if wtd == 1 then -- wtd=1是识别到然后做点划啥的动作
                            picAction(table)  -- 执行此图片的动作
                        elseif wtd == 2 then -- wtd=2是识别到就在这个二级表里循环任务
                            picAction(table) -- 执行此图片的动作
                            loopCaptain(table.parent)
                        end
                    end
                    -- logDebug("我没找到"..getTableName_p(table))
                end 
    })
end



--===调用区域===---

-- 将pic表的所有子子表设置元表__call函数
for pic_k, pic_v in pairs(pic) do
    for pic_j, pic_i in pairs(pic_v) do
        superMeta(pic_i)
    end
end

-- 将bic表的所有子子表设置元表__call函数吧
for bic_k, bic_v in pairs(bic) do
    for bic_j, bic_i in pairs(bic_v) do
        superMeta(bic_i)
    end
end
