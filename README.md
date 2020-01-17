# gprs-
目前市面上太多开源的天气预报了，常见的有wifi esp8266 版本，树莓派版本。这些开源的天气预报都是利用wifi 或者以太网 调用第三方天气预报接口来查询当地天气预报。这里存在一个问题就是网络的接入不太方便。本次开源的天气预报利用了gprs恰好解决了这个问题。

实现原理：1.利用合宙提供的基站定位功能算出经纬度。

                   2.利用心知天气 API接口进行https的当地的天气预报数据获取

实现过程主要利用luat 里面的5个功能块：ntp 时间同步 ， lbsLoc 基站定位 ， json 数据解码 ，https 数据请求

实现教程：1.注册心知天气预报账号https://www.seniverse.com/signup?callback=https%3A%2F%2Fdocs.seniverse.com%2Fapi%2Fstart%2Fcode.html


                   2.获取 api key填入key 到源码里面（源码里面KEY无效了 必须自己申请）
