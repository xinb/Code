// REFERENCE:
// https://github.com/XTLS/Xray-examples
// https://xtls.github.io/config/
       
// 常用的config文件，不论服务器端还是客户端，都有5个部分。外加小小白解读：
// ┌─ 1_log          日志设置 - 日志写什么，写哪里（出错时有据可查）
// ├─ 2_dns          DNS-设置 - DNS怎么查（防DNS污染、防偷窥、避免国内外站匹配到国外服务器等）
// ├─ 3_routing      分流设置 - 流量怎么分类处理（是否过滤广告、是否国内外分流）
// ├─ 4_inbounds     入站设置 - 什么流量可以流入Xray
// └─ 5_outbounds    出站设置 - 流出Xray的流量往哪里去
       
       
{
    // 1_日志设置
    "log": {
        "loglevel": "warning",    // 内容从少到多: "none", "error", "warning", "info", "debug" 
        "access": "/home/vpsadmin/xray_log/access.log",    // 访问记录
        "error": "/home/vpsadmin/xray_log/error.log"    // 错误记录
    },
       
    // 2_DNS设置
    "dns": {
        "servers": [
            "https+local://1.1.1.1/dns-query",    // 首选1.1.1.1的DoH查询，牺牲速度但可防止ISP偷窥
            "localhost"
        ]
    },
       
    // 3_分流设置
   
    // 4_入站设置
    // 4.1 这里只写了一个最简单的vless+xtls的入站，因为这是Xray最强大的模式。如有其他需要，请根据模版自行添加。
    "inbounds": [
        {
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "e9ea185d-b0f9-4dc8-897a-dba7cfc2c9af", // 填写你的 UUID
                        "flow": "xtls-rprx-direct",
                        "level": 0,
                        "email": "vpsadmin@your.com"
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "dest": 80 // 默认回落到防探测的代理
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "xtls",
                "xtlsSettings": {
                    "allowInsecure": false,    // 正常使用应确保关闭
                    "minVersion": "1.2",       // TLS最低版本设置
                    "alpn": [
                        "http/1.1"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/home/vpsadmin/xray_cert/xray.crt",
                            "keyFile": "/home/vpsadmin/xray_cert/xray.key"
                        }
                    ]
                }
            }
        }
    ],
       
    // 5_出站设置
    "outbounds": [
        // 5.1 第一个出站是默认规则，freedom就是对外直连（vps已经是外网，所以直连）
        {
            "tag": "direct",
            "protocol": "freedom"
        },
        // 5.2 屏蔽规则，blackhole协议就是把流量导入到黑洞里（屏蔽）
        {
            "tag": "block",
            "protocol": "blackhole"
        }
    ]
}
