--- 模块功能：ST 7735驱动芯片LCD命令配置
-- @author openLuat
-- @module qrcode.color_std_spi_st7735
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.27

--[[
注意：此文件的配置，硬件上使用的是标准的SPI引脚，不是LCD专用的SPI引脚
disp库目前仅支持SPI接口的屏，硬件连线图如下：
Air模块 LCD
GND--地
SPI_CS--片选
SPI_CLK--时钟
SPI_DO--数据
SPI_DI--数据/命令选择
VDDIO--电源
UART1_CTS--复位
注意：Air202早期的开发板，UART1的CTS和RTS的丝印反了
]]

module(...,package.seeall)

--[[
函数名：init
功能  ：初始化LCD参数
参数  ：无
返回值：无
]]
local function init()
    local para =
    {
        width = 160, --分辨率宽度，128像素；用户根据屏的参数自行修改
        height = 128, --分辨率高度，160像素；用户根据屏的参数自行修改
        bpp = 16, --位深度，彩屏仅支持16位
        bus = disp.BUS_SPI, --标准SPI接口
        xoffset = 2, --X轴偏移
        yoffset = 1, --Y轴偏移
        freq = 13000000, --spi时钟频率，支持110K到13M（即110000到13000000）之间的整数（包含110000和13000000）
        pinrst = pio.P0_3, --reset，复位引脚
        pinrs = pio.P0_12, --rs，命令/数据选择引脚
        --初始化命令
        --前两个字节表示类型：0001表示延时，0000或者0002表示命令，0003表示数据
        --延时类型：后两个字节表示延时时间（单位毫秒）
        --命令类型：后两个字节命令的值
        --数据类型：后两个字节数据的值
        initcmd =
        {
            0x00020011,
            0x00010078,
            0x000200B1,
            0x00030002,
            0x00030035,
            0x00030036,
            0x000200B2,
            0x00030002,
            0x00030035,
            0x00030036,
            0x000200B3,
            0x00030002,
            0x00030035,
            0x00030036,
            0x00030002,
            0x00030035,
            0x00030036,
            0x000200B4,
            0x00030007,
            0x000200C0,
            0x000300A2,
            0x00030002,
            0x00030084,
            0x000200C1,
            0x000300C5,
            0x000200C2,
            0x0003000A,
            0x00030000,
            0x000200C3,
            0x0003008A,
            0x0003002A,
            0x000200C4,
            0x0003008A,
            0x000300EE,
            0x000200C5,
            0x0003000E,
            0x00020036,
            0x000300A0,--横竖屏C0/A0/00/60
            0x000200E0,
            0x00030012,
            0x0003001C,
            0x00030010,
            0x00030018,
            0x00030033,
            0x0003002C,
            0x00030025,
            0x00030028,
            0x00030028,
            0x00030027,
            0x0003002F,
            0x0003003C,
            0x00030000,
            0x00030003,
            0x00030003,
            0x00030010,
            0x000200E1,
            0x00030012,
            0x0003001C,
            0x00030010,
            0x00030018,
            0x0003002D,
            0x00030028,
            0x00030023,
            0x00030028,
            0x00030028,
            0x00030026,
            0x0003002F,
            0x0003003B,
            0x00030000,
            0x00030003,
            0x00030003,
            0x00030010,
            0x0002003A,
            0x00030005,
            0x00020029,
        },
        --休眠命令
        sleepcmd = {
            0x00020010,
        },
        --唤醒命令
        wakecmd = {
            0x00020011,
        }
    }
    disp.init(para)
    disp.clear()
    disp.update()
end

--控制SPI引脚的电压域
pmd.ldoset(6,pmd.LDO_VMMC)
init()
disp.clear()
disp.drawrect(0, 0, 160, 128, 0xfff) -- 绘制一个矩形区域
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

--打开背光
--实际使用时，用户根据自己的lcd背光控制方式，添加背光控制代码
