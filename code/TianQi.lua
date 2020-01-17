--[[
先利用基站定位 获取当前位置信息
利用位置信息 查询当地天气
--]]
module(...,package.seeall)
require"lbsLoc"
require "color_std_spi_st7735"
require"http"
require"ntp"
require"misc"

GetTianQi = ""
TianQiKey= "SBYMlHXU7aOPeTHt2"

--[[
{
    "status": "The API key is invalid.",
    "status_code": "AP010003"
}

{
    "results": [
        {
            "location": {
                "id": "WX4FBXXFKE4F",
                "name": "北京",
                "country": "CN",
                "path": "北京,北京,中国",
                "timezone": "Asia/Shanghai",
                "timezone_offset": "+08:00"
            },
            "daily": [
                {
                    "date": "2020-01-16",
                    "text_day": "多云",
                    "code_day": "4",
                    "text_night": "多云",
                    "code_night": "4",
                    "high": "2",
                    "low": "-7",
                    "precip": "",
                    "wind_direction": "东北",
                    "wind_direction_degree": "45",
                    "wind_speed": "16.20",
                    "wind_scale": "3",
                    "humidity": "37"
                },
                {
                    "date": "2020-01-17",
                    "text_day": "多云",
                    "code_day": "4",
                    "text_night": "晴",
                    "code_night": "1",
                    "high": "3",
                    "low": "-7",
                    "precip": "",
                    "wind_direction": "南",
                    "wind_direction_degree": "191",
                    "wind_speed": "16.20",
                    "wind_scale": "3",
                    "humidity": "42"
                }
            ],
            "last_update": "2020-01-16T11:17:54+08:00"
        }
    ]
}
--]]
OnePath = ""
OneTianQiS = ""
OneTianQiC = 99 
OneWenH = 0 
OneWenL = 0 
TwoTianQiS = ""
TwoTianQiC = 99 
TwoWenH = 0 
TwoWenL = 0 
local function HttpRData( Json)
	tjsondata,result,errinfo = json.decode(Json)
	
	if result and type(tjsondata["results"])=="table" then -- 为表的时候
		log.info( "获取出来的位置" .. tjsondata["results"][1]["location"]["path"] )
		TOnePath = tjsondata["results"][1]["location"]["path"]
		log.info("获取出来的第一天 天气" .. tjsondata["results"][1]["daily"][1]["text_day"])
		log.info("获取出来的第一天 天气代码" .. tjsondata["results"][1]["daily"][1]["code_day"])
		log.info("获取出来的第一天 高温" .. tjsondata["results"][1]["daily"][1]["high"])
		log.info("获取出来的第一天 低温" .. tjsondata["results"][1]["daily"][1]["low"])
		OneTianQiS = tjsondata["results"][1]["daily"][1]["text_day"]
		OneTianQiC = tjsondata["results"][1]["daily"][1]["code_day"]
		OneWenH = tjsondata["results"][1]["daily"][1]["high"]
		OneWenL = tjsondata["results"][1]["daily"][1]["low"]
		
		log.info("获取出来的第2天 天气" .. tjsondata["results"][1]["daily"][2]["text_day"])
		log.info("获取出来的第2天 天气代码" .. tjsondata["results"][1]["daily"][2]["code_day"])
		log.info("获取出来的第2天 高温" .. tjsondata["results"][1]["daily"][2]["high"])
		log.info("获取出来的第2天 低温" .. tjsondata["results"][1]["daily"][2]["low"])
		TwoTianQiS = tjsondata["results"][1]["daily"][2]["text_day"]
		TwoTianQiC = tjsondata["results"][1]["daily"][2]["code_day"]
		TwoWenH = tjsondata["results"][1]["daily"][2]["high"]
		TwoWenL = tjsondata["results"][1]["daily"][2]["low"]
		
		local strList={} 
		string.gsub(TOnePath,"[^,]+", function(w) table.insert(strList,w) end) -- 把字符串一次性拆分放到数组里面
		OnePath = strList[3] .. strList[2]
		UiUpdate()
	else
		if result and type(tjsondata["status"])=="string" then
			log.info("获取天气数据出错",tjsondata["status"].. tjsondata["status_code"] )
		else
			log.info(" HttpRDataJson.decode error",errinfo)
		end
	end
end
--[[
功能  ：发送查询位置请求
参数  ：无
返回值：无
]]
local function reqLbsLoc()   
    lbsLoc.request(getLocCb)
	
end

local function cbFnc(result,prompt,head,body)
    log.info("testHttp.cbFnc",result,prompt)
    if result and head then
        for k,v in pairs(head) do
            log.info("testHttp.cbFnc",k..": "..v)
        end
    end
    if result and body then
        log.info("testHttp.cbFnc","body= "..body)
		HttpRData(body)
    end
    
end

--[[
功能  ：获取基站对应的经纬度后的回调函数
参数  ：
		result：number类型，0表示成功，1表示网络环境尚未就绪，2表示连接服务器失败，3表示发送数据失败，4表示接收服务器应答超时，5表示服务器返回查询失败；为0时，后面的3个参数才有意义
		lat：string类型，纬度，整数部分3位，小数部分7位，例如031.2425864
		lng：string类型，经度，整数部分3位，小数部分7位，例如121.4736522
返回值：无
]]
function getLocCb(result,lat,lng)
    log.info("testLbsLoc.getLocCb",result,lat,lng)
    --获取经纬度成功
    if result==0 then
		GetTianQi = string.format("https://api.seniverse.com/v3/weather/daily.json?key=%s&location=%s:%s&language=zh-Hans&unit=c&start=0&days=2",TianQiKey,lat,lng)
		http.request("GET",GetTianQi,nil,nil,nil,nil,cbFnc)
    --失败
    else
	
    end
    sys.timerStart(reqLbsLoc,60000) -- 一个小时同步一次数据
end

--[[
disp.puttext("2020/01/16",1,0)
disp.puttext(" 14:32:50 ",1,16)

disp.puttext("中国 重庆",81,1)
disp.puttext("江津区",81,16)

disp.putimage("/ldata/0.png",1,31)
disp.puttext("   今天  ",1,80)
disp.puttext("多云/多云",1,96)
disp.puttext(" 07~28°C ",1,112)

disp.putimage("/ldata/14.png",81,31)
disp.puttext("   今天  ",81,80)
disp.puttext("多云/多云",81,96)
disp.puttext(" 07~28°C ",81,112)

disp.update()
--]]
function UiUpdate()
	Time = misc.getClock()
	local NianYue = string.format("%4d/%02d/%02d",Time.year,Time.month,Time.day)
	local TimeStr = string.format("%02d:%02d:%02d",Time.hour,Time.min,Time.sec)
--	disp.puttext("          ",1,0)
	--disp.puttext("          ",1,16)
	--disp.update()
	disp.clear()
	disp.drawrect(0, 0, 160, 128, 0xfff) -- 绘制一个矩形区域
	disp.puttext(NianYue,1,0)
	disp.puttext(TimeStr,1,16)
	-- 更新信号质量
	disp.puttext("信号" .. net.getRssi(),90,1) -- 81
	
	----------------
	-- 更新显示界面
	--disp.puttext("中国 重庆",81,1)
	disp.puttext(common.utf8ToGb2312(OnePath),81,16)

	StrTmp = string.format("/ldata/%d.png" , OneTianQiC)
	disp.putimage(StrTmp,1,31) -- 显示天气图片
	disp.puttext("   今天  ",1,80)
	disp.puttext(common.utf8ToGb2312(OneTianQiS),1,96) -- "多云/多云"
	StrTmp = string.format(" %02d-%02dC " ,OneWenL, OneWenH)
	disp.puttext(StrTmp,1,112)

	StrTmp = string.format("/ldata/%d.png" , OneTianQiC)		
	disp.putimage(StrTmp,81,31) -- "/ldata/14.png"
	disp.puttext("   明天  ",81,80)
	disp.puttext(common.utf8ToGb2312(TwoTianQiS),81,96)
	StrTmp = string.format(" %02d-%02dC " , TwoWenL,TwoWenH)
	disp.puttext(StrTmp,81,112)
	disp.update()
end
function UiTimeUp()
	UiUpdate()
	log.info("Time Update s")
end
--[[
开机等待网络 开启时间同步
查询基站定位 发送数据请求
定时器更新
--]]
GprsStatus = 1 
TcpConnectCnt = 0 
FlyCnt = 0 
function TianTask()
	UiTimeUp()
	sys.timerLoopStart(UiTimeUp,3000) -- 开启一秒钟更新一次时间
	while true do 
		if GprsStatus == 1 then --在飞行模式
				if FlyCnt >= 5 then
						log.warn(ModeName,"Mod restart")
						rtos.restart() --软件重启
					
				end
				net.switchFly(false) --退出飞行模式
				GprsStatus = 2 -- 进入网络环境等待状态
				log.info("GprsStatus = 1")
		end
		if GprsStatus == 2 then --在等待网络环境模式
			if sys.waitUntil("IP_READY_IND",300000) == true then --等待网络环境超时5分钟
				--接收到了消息
				GprsStatus = 3 --进入TCP建立状态
				-- 查询时间 ntp 同步
				ntp.ntpTime()
				reqLbsLoc() -- 同步网络
				sys.wait(4000)
				log.info("GprsStatus = 2")
			end
		end
		if GprsStatus == 3 then --在TCP建立连接中
			log.info("GprsStatus = 3")
			sys.wait(200)
		end
		sys.wait(200)
		log.info("mem:",_G.collectgarbage("count"))  -- 打印占用的RAM
		log.info("flash",rtos.get_fs_free_size()) -- 打印剩余FALSH，单位Byte
	end	
end

sys.taskInit(TianTask)