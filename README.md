f9omstw benchmark (台灣證交所)
==============================

## 基本說明
* sourc code
  * [libfon9](https://github.com/fonwin/libfon9)
  * [f9omstw](https://github.com/fonwin/f9omstw)

* 測量的時間點:
  * [T0 Client before send](https://github.com/fonwin/f9omstw/blob/9f3ed8a/f9omsrc/OmsRcClient_UT.c#L331)
  * [T1 Server before parse(封包收到時間)](https://github.com/fonwin/f9omstw/blob/9f3ed8a/f9omsrc/OmsRcServerFunc.cpp#L194)
  * [T2 Server after first updated(Sending, Queuing, Reject...)](https://github.com/fonwin/f9omstw/blob/9f3ed8a/f9omstw/OmsBackend.cpp#L202)
  * `T0-` = T0(n) - T0(n-1) 表示 Client 連續送單之間的延遲.
  * `T1-` = T1(n) - T1(n-1) 表示 RcServer 處理連續下單之間的延遲.
  * `T2-` = T2(n) - T2(n-1) 表示 OmsCore 處理連續下單要求之間的延遲 (包含送出 FIX.4.4 給證交所).
  * 有測試交易所成功回覆, 但沒有計算交易所回覆的時間

---------------------------------------
## [初次啟動](Startup.md)

## 測試指令
* Client 下單程式 & 下單指令:
```
~/devel/output/f9omstw/release/f9omsrc/OmsRcClient_UT -a "dn=localhost:6601|ClosedReopen=5" -u fonwin

關閉 Client 端 log
> lf 0

新單測試
> set  TwsNew BrkId=8610|Market=T|Symbol=2317|OType=0|Pri=200|Qty=8000|Side=B|IvacNo=10
> send TwsNew 1 g1
> send TwsNew 10 g2
> send TwsNew 100 g3
> send TwsNew 1000 g4
> send TwsNew 10000 g5
> send TwsNew 100000 g6

刪單測試
> set  TwsChg Qty=0|BrkId=8610|Market=T|SessionId=N|OrdNo=30000
> send TwsChg 1 d1
> send TwsChg 10 d2 +
> send TwsChg 100 d3 +
> send TwsChg 1000 d4 +
> send TwsChg 10000 d5 +
> send TwsChg 100000 d6 +

慢速測試: 60 筆, 每筆間隔 1000 ms
> send TwsNew 60/1000 s1
```

* 分析程式
`~/devel/output/f9omstw/release/f9omstw/OmsLogAnalyser ~/f9utws/logs/yyyymmdd/omstw.log `

---------------------------------------
## 測試結果
### 設備及工具
* 硬體: HP ProLiant DL380p Gen8 / E5-2680 v2 @ 2.80GHz
* OS: Ubuntu 16.04.2 LTS
* gcc version 5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.9)
### 執行環境
* OmsCoreByThread: [`Cpu=19`](./f9utws.block/fon9cfg/MaPlugins.f9gv#L7)
* [`chrt -f 90 taskset -c 10,11,12,13,14,15,16,17,18 ./run.sh`](./f9utws.block/srun.sh#L7)
### 20191118
* sourc code / (重構 for add f9omstwf)
  * [libfon9](https://github.com/fonwin/libfon9) (版本: 9a7ca3b)
  * [f9omstw](https://github.com/fonwin/f9omstw) (版本: 9f3ed8a)
* 記憶體用量(沒有成交, 程式 f9utw 沒結束):
  * cat /proc/pid/status
  * TwsNew  111111筆: VmPeak: 1645232 kB
  * +TwsChg 111111筆: VmPeak: 1720672 kB
  * +TwsNew 100萬 筆: VmPeak: 4021272 kB (共 TwsNew 1,111,111筆, TwsChg 111,111筆)
  * +TwsNew 100萬 筆: VmPeak: 4764320 kB (共 TwsNew 2,111,111筆, TwsChg 111,111筆)
  * +TwsNew 100萬 筆: VmPeak: 5547684 kB (共 TwsNew 3,111,111筆, TwsChg 111,111筆)
  * +TwsNew 100萬 筆: VmPeak: 6157732 kB (共 TwsNew 4,111,111筆, TwsChg 111,111筆)
  * +TwsNew 100萬 筆: VmPeak: 7031852 kB (共 TwsNew 5,111,111筆, TwsChg 111,111筆)
  * 由於有用到 [ObjSupplier機制](https://github.com/fonwin/f9omstw/blob/9f3ed8a/f9omstw/OmsRequestFactory.hpp#L87)
    所以記憶體的使用量不是成線性增長.
### 20190905
* 與 20190828 在誤差範圍內, 所以不附上 log 及 額外分析.
* sourc code
  * libfon9 版本: 49a659b
  * f9omstw 版本: db9ff5f
* 增加功能:
  * 增加風控處理機制, 但沒有實作風控內容.
  * Client 增加連續刪單測試.
### 20190828
* 時間單位: us(microsecond)
* sourc code
  * libfon9 版本: 33e3017
  * f9omstw 版本: f6ff38a
* 統計結果 [Wait=Block](./f9utws.block/logs/20190828/omstws.log.Summary.txt)
* 統計結果 [Wait=Busy](./f9utws.busy/logs/20190828/omstws.log.Summary.txt)
* 10萬筆, 可在 1 秒內完成: 收單解析、下單打包(FIX.4.4)、部分 send() 成功
  * 但因網路頻寬、SNDBUF 配置... 等因素, 下單打包的資料, 可能仍保留在程式的緩衝區裡面.
  * 以 g6:100000(Wait=Block) 最後這筆來看
    * T0 = 20190828053307.406899
    * T1 = 20190828053307.406921 (T1 - T0 = 22 us)
    * T2 = 20190828053307.406932 (T2 - T1 = 11 us)
      * T2(g6:100000) - T0(g6:1)(Client打包第1筆的時間) 20190828053306.492035 = 0.914897 秒
    * OMS 打包完畢的時間 = T2
    * OMS 收到回報的時間 = 20190828053311.712511 ( - T2 = 花費 4.305579 秒)
    * 測試環境 OMS 到「模擬交易所」之間的網路頻寬 = 100M (`ethtool xxx`)
* 由底下結果看來, 使用 `Wait=Busy` 與 `Wait=Block` 比較, 在大部分情況下, 可以明顯降低延遲.
```
* 10 筆:
  * Block: T2-T1|50%= 99|75%=118|90%=121|99%= 121|99.9%= 121|99.99%= 121|Worst=118|120|121|
  * Busy:  T2-T1|50%= 38|75%= 40|90%= 44|99%=  44|99.9%=  44|99.99%=  44|Worst= 40| 43| 44|
* 100 筆:
  * Block: T2-T1|50%= 18|75%= 96|90%=113|99%= 117|99.9%= 117|99.99%= 117|Worst=116|117|117|
  * Busy:  T2-T1|50%=  6|75%=  9|90%= 18|99%=  30|99.9%=  30|99.99%=  30|Worst= 29| 30| 30|
* 1000 筆:
  * Block: T2-T1|50%=  8|75%=  8|90%= 10|99%= 106|99.9%= 328|99.99%= 328|Worst=117|118|328|
  * Busy:  T2-T1|50%=  5|75%=  6|90%=  7|99%=  18|99.9%=  20|99.99%=  20|Worst= 20| 20| 20|
* 1萬筆:
  * Block: T2-T1|50%=  8|75%=  9|90%= 10|99%=  20|99.9%= 114|99.99%= 117|Worst=116|117|117|
  * Busy:  T2-T1|50%=  4|75%=  6|90%=  7|99%=  15|99.9%=  26|99.99%= 315|Worst= 33|314|315|
* 10萬筆:
  * Block: T2-T1|50%=  8|75%= 10|90%= 12|99%=2555|99.9%=6171|99.99%=6818|Worst=6859|6859|6861|
  * Busy:  T2-T1|50%=  5|75%=  7|90%=  9|99%= 499|99.9%=3132|99.99%=3828|Worst=3886|3887|3887|
* 1筆/每秒, 共60次
  * Block: T2-T1|50%=119|75%=123|90%=125|99%= 182|99.9%= 182|99.99%= 182|Worst=126|126|182|
  * Busy:  T2-T1|50%= 14|75%= 14|90%= 15|99%= 350|99.9%= 350|99.99%= 350|Worst= 16| 25|350|
* 1筆/0.5秒, 共60次
  * Block: T2-T1|50%=119|75%=124|90%=125|99%= 186|99.9%= 186|99.99%= 186|Worst=127|155|186|
  * Busy:  T2-T1|50%= 13|75%= 13|90%= 14|99%=  59|99.9%=  59|99.99%=  59|Worst= 17| 18| 59|
* 1筆/0.1秒, 共60次
  * Block: T2-T1|50%=119|75%=122|90%=124|99%= 126|99.9%= 126|99.99%= 126|Worst=125|125|126|
  * Busy:  T2-T1|50%= 12|75%= 13|90%= 13|99%=  15|99.9%=  15|99.99%=  15|Worst= 13| 15| 15|
```
---------------------------------------
## 測試結果探討
* 詳細的探討, 等有空時再說吧!
* OmsCore 使用 OmsCoreByThread
  * 收單 thread 與 OmsCore 在不同 thread.
  * 可設定 WaitPolicy: `Wait=Busy` 或 `Wait=Block`(使用 condition variable).
  * 可綁定 CPU: `Cpu=19`
  * 如果不使用 OmsCoreByThread, 改用 OmsCoreByMutex(尚未實現) 延遲會更低嗎?
* OmsCore 的效率: `T2-`
  * 包含 send() 呼叫.
* Rc協定收單 的效率: `T1-`
  * 包含 recv() 呼叫.
* OmsCoreByThread(Context switch): `T2-T1`
  * 如果使用網路加速 library(例如: OpenOnload), 會有什麼變化呢?
* CPU cache 的影響?

### Linux 的 低延遲
* 這裡只是基礎, 關於核心的調教, 還要更多的研究.
* Linux 啟動時使用 isolate 參數, 將 cpu core 保留給 OMS 使用.
  * sudo vi /etc/default/grub
    * GRUB_CMDLINE_LINUX_DEFAULT="isolcpus=10,11,12,13,14,15,16,17,18,19,30,31,32,33,34,35,36,37,38,39"
  * sudo update-grub
* Linux 設定 irqbalance
* 將 CPU 設定為高效能(關閉省電模式), 但若 IO 設定有使用 `Wait=Busy` 參數, 也可以考慮不調整 CPU 時脈.
* 請參考 [rt-cfg.sh](f9utws.block/rt-cfg.sh)
* 啟動時的優先權及綁定 cpu, 請參考 [srun.sh](f9utws.block/srun.sh)
  * 使用 chrt 設定優先權
  * 使用 taskset 設定使用的 cpu cores
    * `chrt -f 90 taskset -c 10,11,12,13,14,15,16,17,18 ./run.sh`
    * 若有錯誤訊息: `chrt: failed to set pid 0's policy: Operation not permitted`   
      則要先執行:   `sudo setcap  cap_sys_nice=eip  /usr/bin/chrt`
