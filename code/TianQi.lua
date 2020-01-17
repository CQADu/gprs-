--[[
�����û�վ��λ ��ȡ��ǰλ����Ϣ
����λ����Ϣ ��ѯ��������
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
                "name": "����",
                "country": "CN",
                "path": "����,����,�й�",
                "timezone": "Asia/Shanghai",
                "timezone_offset": "+08:00"
            },
            "daily": [
                {
                    "date": "2020-01-16",
                    "text_day": "����",
                    "code_day": "4",
                    "text_night": "����",
                    "code_night": "4",
                    "high": "2",
                    "low": "-7",
                    "precip": "",
                    "wind_direction": "����",
                    "wind_direction_degree": "45",
                    "wind_speed": "16.20",
                    "wind_scale": "3",
                    "humidity": "37"
                },
                {
                    "date": "2020-01-17",
                    "text_day": "����",
                    "code_day": "4",
                    "text_night": "��",
                    "code_night": "1",
                    "high": "3",
                    "low": "-7",
                    "precip": "",
                    "wind_direction": "��",
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
	
	if result and type(tjsondata["results"])=="table" then -- Ϊ���ʱ��
		log.info( "��ȡ������λ��" .. tjsondata["results"][1]["location"]["path"] )
		TOnePath = tjsondata["results"][1]["location"]["path"]
		log.info("��ȡ�����ĵ�һ�� ����" .. tjsondata["results"][1]["daily"][1]["text_day"])
		log.info("��ȡ�����ĵ�һ�� ��������" .. tjsondata["results"][1]["daily"][1]["code_day"])
		log.info("��ȡ�����ĵ�һ�� ����" .. tjsondata["results"][1]["daily"][1]["high"])
		log.info("��ȡ�����ĵ�һ�� ����" .. tjsondata["results"][1]["daily"][1]["low"])
		OneTianQiS = tjsondata["results"][1]["daily"][1]["text_day"]
		OneTianQiC = tjsondata["results"][1]["daily"][1]["code_day"]
		OneWenH = tjsondata["results"][1]["daily"][1]["high"]
		OneWenL = tjsondata["results"][1]["daily"][1]["low"]
		
		log.info("��ȡ�����ĵ�2�� ����" .. tjsondata["results"][1]["daily"][2]["text_day"])
		log.info("��ȡ�����ĵ�2�� ��������" .. tjsondata["results"][1]["daily"][2]["code_day"])
		log.info("��ȡ�����ĵ�2�� ����" .. tjsondata["results"][1]["daily"][2]["high"])
		log.info("��ȡ�����ĵ�2�� ����" .. tjsondata["results"][1]["daily"][2]["low"])
		TwoTianQiS = tjsondata["results"][1]["daily"][2]["text_day"]
		TwoTianQiC = tjsondata["results"][1]["daily"][2]["code_day"]
		TwoWenH = tjsondata["results"][1]["daily"][2]["high"]
		TwoWenL = tjsondata["results"][1]["daily"][2]["low"]
		
		local strList={} 
		string.gsub(TOnePath,"[^,]+", function(w) table.insert(strList,w) end) -- ���ַ���һ���Բ�ַŵ���������
		OnePath = strList[3] .. strList[2]
		UiUpdate()
	else
		if result and type(tjsondata["status"])=="string" then
			log.info("��ȡ�������ݳ���",tjsondata["status"].. tjsondata["status_code"] )
		else
			log.info(" HttpRDataJson.decode error",errinfo)
		end
	end
end
--[[
����  �����Ͳ�ѯλ������
����  ����
����ֵ����
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
����  ����ȡ��վ��Ӧ�ľ�γ�Ⱥ�Ļص�����
����  ��
		result��number���ͣ�0��ʾ�ɹ���1��ʾ���绷����δ������2��ʾ���ӷ�����ʧ�ܣ�3��ʾ��������ʧ�ܣ�4��ʾ���շ�����Ӧ��ʱ��5��ʾ���������ز�ѯʧ�ܣ�Ϊ0ʱ�������3��������������
		lat��string���ͣ�γ�ȣ���������3λ��С������7λ������031.2425864
		lng��string���ͣ����ȣ���������3λ��С������7λ������121.4736522
����ֵ����
]]
function getLocCb(result,lat,lng)
    log.info("testLbsLoc.getLocCb",result,lat,lng)
    --��ȡ��γ�ȳɹ�
    if result==0 then
		GetTianQi = string.format("https://api.seniverse.com/v3/weather/daily.json?key=%s&location=%s:%s&language=zh-Hans&unit=c&start=0&days=2",TianQiKey,lat,lng)
		http.request("GET",GetTianQi,nil,nil,nil,nil,cbFnc)
    --ʧ��
    else
	
    end
    sys.timerStart(reqLbsLoc,60000) -- һ��Сʱͬ��һ������
end

--[[
disp.puttext("2020/01/16",1,0)
disp.puttext(" 14:32:50 ",1,16)

disp.puttext("�й� ����",81,1)
disp.puttext("������",81,16)

disp.putimage("/ldata/0.png",1,31)
disp.puttext("   ����  ",1,80)
disp.puttext("����/����",1,96)
disp.puttext(" 07~28��C ",1,112)

disp.putimage("/ldata/14.png",81,31)
disp.puttext("   ����  ",81,80)
disp.puttext("����/����",81,96)
disp.puttext(" 07~28��C ",81,112)

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
	disp.drawrect(0, 0, 160, 128, 0xfff) -- ����һ����������
	disp.puttext(NianYue,1,0)
	disp.puttext(TimeStr,1,16)
	-- �����ź�����
	disp.puttext("�ź�" .. net.getRssi(),90,1) -- 81
	
	----------------
	-- ������ʾ����
	--disp.puttext("�й� ����",81,1)
	disp.puttext(common.utf8ToGb2312(OnePath),81,16)

	StrTmp = string.format("/ldata/%d.png" , OneTianQiC)
	disp.putimage(StrTmp,1,31) -- ��ʾ����ͼƬ
	disp.puttext("   ����  ",1,80)
	disp.puttext(common.utf8ToGb2312(OneTianQiS),1,96) -- "����/����"
	StrTmp = string.format(" %02d-%02dC " ,OneWenL, OneWenH)
	disp.puttext(StrTmp,1,112)

	StrTmp = string.format("/ldata/%d.png" , OneTianQiC)		
	disp.putimage(StrTmp,81,31) -- "/ldata/14.png"
	disp.puttext("   ����  ",81,80)
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
�����ȴ����� ����ʱ��ͬ��
��ѯ��վ��λ ������������
��ʱ������
--]]
GprsStatus = 1 
TcpConnectCnt = 0 
FlyCnt = 0 
function TianTask()
	UiTimeUp()
	sys.timerLoopStart(UiTimeUp,3000) -- ����һ���Ӹ���һ��ʱ��
	while true do 
		if GprsStatus == 1 then --�ڷ���ģʽ
				if FlyCnt >= 5 then
						log.warn(ModeName,"Mod restart")
						rtos.restart() --�������
					
				end
				net.switchFly(false) --�˳�����ģʽ
				GprsStatus = 2 -- �������绷���ȴ�״̬
				log.info("GprsStatus = 1")
		end
		if GprsStatus == 2 then --�ڵȴ����绷��ģʽ
			if sys.waitUntil("IP_READY_IND",300000) == true then --�ȴ����绷����ʱ5����
				--���յ�����Ϣ
				GprsStatus = 3 --����TCP����״̬
				-- ��ѯʱ�� ntp ͬ��
				ntp.ntpTime()
				reqLbsLoc() -- ͬ������
				sys.wait(4000)
				log.info("GprsStatus = 2")
			end
		end
		if GprsStatus == 3 then --��TCP����������
			log.info("GprsStatus = 3")
			sys.wait(200)
		end
		sys.wait(200)
		log.info("mem:",_G.collectgarbage("count"))  -- ��ӡռ�õ�RAM
		log.info("flash",rtos.get_fs_free_size()) -- ��ӡʣ��FALSH����λByte
	end	
end

sys.taskInit(TianTask)