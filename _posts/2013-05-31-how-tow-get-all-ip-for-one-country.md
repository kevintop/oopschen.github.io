---
layout: post
title: 如何获取某个国家的ip段分配，以及ip所对应的服务商
tags: ip段,ip拥有者,apnic
date: 2013-05-31 16:45:00
category: 技术
---
[IANAwebsite]: http://www.iana.org/ "IANA Website"
[APNICweb]: http://www.apnic.net/ "APNIC Website"
[iso3166]: http://www.iso.org/iso/home/standards/country_codes/iso-3166-1_decoding_table.htm "ISO-3166 Country Code"
[APNICformat]: http://www.apnic.net/publications/media-library/documents/resource-guidelines/rir-statistics-exchange-format#Format "APNIC IP ALLOC FORMAT"
[apnic_file]: http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest "APNIC Latest IP"
[rfc3921]: http://www.ietf.org/rfc/rfc3912.txt "RFC 3921"

互联网在最初的时候只是一个局域网，各个州的局域网连接起来后就变成了当今的局域网。所谓ip，就是分配给每个上网设备的一个地址，像邮箱一样。而这个工作不可能由一个组织具体到每个设备，这样既消耗资源，又不高效。因此，一个名为[IANA][IANAwebsite],的组织负责统筹安排数字的分配（包含ip地址，端口地址，域名等等），当然具体执行的时候，会分配到各个州的办事处。而亚洲的办事处称为[APNIC][APNICweb]。说了这么多，好像没说重点，这篇博客主要记录如何获取某个国家的ip段，以及如何过滤出某些运营商的ip段。  

#### 获取某个国家的ip段
在这之前，我们先了解下什么是**Country Code(CC)**, CC是国家代码的简称。我们通常可以在域名后看到，比如*www.google.com.hk*就代表google在香港的服务，而*wwww.google.com.sg*则是新加坡的服务，后面我们将用他来过滤ip段。[更多的CC可以参考这里][iso3166]  
Apnic负责亚洲地区的ip分配，而所有ip信息是公开的，具体参考文件[Lastes IP Allocation][apnic_file], 下面我们简单介绍下apnic的的[格式][APNICformat]：  
  
###### 备注行
**\#**在文件中表示备注，可以正常忽略，当然也有一些有用的信息,比如文档地址在哪里等
  
##### 文件头行
样例：  
> 2|apnic|20130531|29927|19850701|20130530|+1000
格式:
> version|registry|serial|records|startdate|enddate|UTCoffset
  
1. version, 表示当前的版本，目前是2
2. registry, 办事处简称，可以是afrinic, apnic, arin,iana, lacnic, ripencc其中的一个
3. serial, 可以理解成文件的id
4. records, 文件有多少条记录，不包括空行，文件头行，备注行以及概要行
5. startdate, 开始的日期，格式为yyyymmdd
6. enddate, 结束日期， 格式如上
7. UTCoffset, UTC中的距离

##### 概要行
样例：  
> apnic|*|asn|*|5214|summary
格式：   
> registry|*|type|*|count|summary
  
1. registry, 同上
2. \*，保留字段
3. type， 可以是asn,ipv4,ipv6中的一个， asn, 全称Autonomous System (AS) Numbers), 可以理解成办事处的id号
4. count, type指定类型的记录数，比如type这列为ipv4，那count列表是文件中ipv4的记录数
5. summary, 就是字符串"summary", 为了和记录行区别
  
##### 记录行
样例：  
> apnic|CN|ipv4|1.0.1.0|256|20110414|allocated
格式：
> registry|cc|type|start|value|date|status\[|extensions...\]
  
1. registry, 同上
2. cc， 上面将的CC
3. type， 同上
4. start，开始值
5. value，从start开始有几个数值
6. date, 记录被确定的日期，格式和startdate相同
7. status， 可以是allocated或者assign，至于这两者的区别就是allocated一定是在使用中的，而assign可以是预先保留，未使用
8. extensions, 额外的信息，但是必须用**|**分割
  
到这里我们就应该知道如何解析这个文件从而获取国内的ip了, **文章结尾附上脚本获取apnic的指定ip**  
  
  
#### 查询每个ip段的服务商
上面我们介绍了如何去获得指定ip段，但是这些ip段又会再分配给不同的运营商使用，比如电信，联通，移动以及各高校的固定ip。这些情形APNIC是不会知道的，也不关心，那么我们如何去解析呢？  
  
这个时候我们需要用到whois, whois主要是查询RFC3921[rfc3921]中的对象，whosi通过建立tcp链接，遵循request和response的设计，以文本的格式传递信息，当然只允许ASCII。但是我查了很久，没有一个标准的whois协议，可能是各个办事处自己定制的。啥历史原因就不得而知了。  
下面是一个whois 1.0.1.0的例子:  
> % \[whois.apnic.net node-1\]  
> % Whois data copyright terms    http://www.apnic.net/db/dbcopyright.html  
>   
> inetnum:        1.0.1.0 - 1.0.1.255  
> netname:        CHINANET-FJ  
> descr:          CHINANET FUJIAN PROVINCE NETWORK  
> descr:          China Telecom  
> descr:          No.31,jingrong street  
> descr:          Beijing 100032  
> country:        CN  
> admin-c:        CA67-AP  
> tech-c:         CA67-AP  
> status:         ALLOCATED PORTABLE  
> notify:         fjnic@fjdcb.fz.fj.cn  
> remarks:        service provider  
> changed:        hm-changed@apnic.net 20110414  
> mnt-by:         APNIC-HM  
> mnt-lower:      MAINT-CHINANET-FJ  
> mnt-irt:        IRT-CHINANET-CN  
> source:         APNIC   
>   
> role:           CHINANETFJ IP ADMIN  
> address:        7,East Street,Fuzhou,Fujian,PRC  
> country:        CN  
> phone:          +86-591-83309761  
> fax-no:         +86-591-83371954  
> e-mail:         fjnic@fjdcb.fz.fj.cn  
> remarks:        send spam reports  and abuse reports  
> remarks:        to abuse@fjdcb.fz.fj.cn  
> remarks:        Please include detailed information and  
> remarks:        times in UTC  
> admin-c:        FH71-AP  
> tech-c:         FH71-AP  
> nic-hdl:        CA67-AP  
> remarks:        www.fjtelecom.com  
> notify:         fjnic@fjdcb.fz.fj.cn  
> mnt-by:         MAINT-CHINANET-FJ  
> changed:        fjnic@fjdcb.fz.fj.cn 20100108  
> source:         APNIC  
> changed:        hm-changed@apnic.net 20111114  
  
从上面我们不难看出是电信福建\(CHINANET-FJ\)的网络.  
  
  
#### 脚本
##### 获取ip段python脚本
  
{% highlight python %}
#!/usr/bin/env python

"""
This file is help to generate ip range for a country

Usage:
    ./iprange.py countryCC protocal(ipv4|ipv6) outputfile 

outputfile format:
    start ip,end ip\n
    start ip,end ip\n
    ...

"""

import sys
import urllib2
from ipgen import format_ip4
from ipgen import parse_ip4

def cal_ip_range(startIP, num) :
    rnum = int(num)
    if 0 > num :
        rnum = 0
    numip = parse_ip4(startip)
    endIP = numip + rnum
    return numip, endIP

def merge_iprange(ips, sip, eip) :
    inx = -1
    stip = 0
    etip = 0
    for i,ippair in enumerate(ips) :
        if ippair[1] < sip or ippair[0] > eip :
            continue
        inx = i
        stip = min(sip, ippair[0])
        etip = max(eip, ippair[1])
        break

    if 0 > inx :
        ips.append((sip, eip))
        return
    ips[inx] = stip, etip


if 4 > len(sys.argv) :
    print "please check the usage.\n\t./iprange.py countryCC protocal(ipv4|ipv6) outputfile"
    sys.exit(1)

cc = sys.argv[1].lower()
proto = sys.argv[2].lower()
outputpath = sys.argv[3]

apnic_url = "http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"
# download file
res = urllib2.urlopen(apnic_url)
if None == res or 200 != res.getcode() :
    print "Download fail"
    sys.exit(1)

html = res.read()
lines = html.split("\n")

ips = []
for line in lines :
    if 1 > len(line) or "#" == line[0] :
        continue
    eles = line.split("|")
    tmpCC= eles[1].lower()
    typ = eles[2].lower()
    if tmpCC == cc and proto == typ :
        startip = eles[3]
        num = eles[4]
        sip, eip = cal_ip_range(startip, num)
        merge_iprange(ips, sip, eip)

with open(outputpath, "w+") as f :
    for ippair in ips :
        f.write("%s,%s\n" % (format_ip4(ippair[0]), format_ip4(ippair[1])))

print "Done range:", len(ips)
sys.exit(0)
{% endhighlight %}
  

##### 查询指定netname的python脚本
  
{% highlight python %}
#!/usr/bin/env python

"""
This file is help to generate whois keys ip

Usage:
    ./ipselect.py inputfile outputdir keys(case-insensitive)

outputfile format:
    start ip,end ip\n
    start ip,end ip\n
    ...

"""

import sys
import os.path
import subprocess


def read_key_val(key, fileobj) :
    for line in fileobj:
        pos = line.lower().find(key)
        if 0 > pos :
            continue
        return line[pos+len(key):]
    return None

if 5 > len(sys.argv) :
    print "please check the usage.\n\t./ipselect.py inputfile outputdir key possibleValues(,)"
    sys.exit(1)

inputfile = sys.argv[1]
outputdir = sys.argv[2]
key = sys.argv[3].strip().lower()
vals = sys.argv[4].strip().lower().split(",")

if 1 > len(vals) :
    print "possibleValues error", vals
    sys.exit(1)

if not os.path.exists(inputfile) :
    print "inputfile not exist"
    sys.exit(1)

if not os.path.exists(outputdir) :
    print "outputdir not found"
    sys.exit(1)

fail=0
success=0
key_fd_map = {}
with open(inputfile, "r") as f :
    for line in f :
        eles = line.strip().split(",")
        if 2 > len(eles) :
            continue
        start_ip = eles[0]
        end_ip = eles[1]
        pipe = subprocess.Popen('whois %s' %(start_ip), stdout=subprocess.PIPE, shell=True)
        if 0 != pipe.wait() :
            print "whois fail", start_ip
            sys.exit(1)
        keyval = read_key_val(key, pipe.stdout)
        pipe.stdout.close()

        if None == keyval :
            continue

        targetStr = keyval.strip().lower()
        for val in vals: 
            if -1 < targetStr.find(val) :
                # to multiple file
                if val not in key_fd_map :
                    key_fd_map[val] = open(os.path.join(outputdir, val), "w+")
                key_fd_map[val].write(line)
                success += 1
                break
            continue
        fail += 1

print "Done select(success-fail):%d-%d" % (success, fail)

sys.exit(0)
{% endhighlight %}
  
下面是查询联通，电信和铁通的使用例子:
  
{% highlight bash %}
./ipselect.py ${paramsfile} ${selectdir} netname unicom,chinanet,CTTNET
{% endhighlight %}
