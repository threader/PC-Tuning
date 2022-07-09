# Research

## Content Overview

- [How can you verify if a DSCP QoS policy is working?](#how-can-you-verify-if-a-dscp-policy-is-working)
- [What TscSyncPolicy does Windows use by default?](#what-tscsyncpolicy-does-windows-use-by-default)
- [How many Rss Queues do you need?](#how-many-rss-queues-do-you-need)

#### How can you verify if a DSCP QoS policy is working?

<details>
<summary>Read More</summary>

- Download & install [Microsoft Network Monitor 3.4](https://www.microsoft.com/en-gb/download/details.aspx?id=4865).
   
- Create a new capture.
   
    <img src="../media/network-monitor-new-capture.png" width="450">

- Open a game that you have applied a DSCP value for & enter a game mode in which the game will send & receive packets (e.g an online match, not a local match).
   
- Press F5 to start logging. After 30 seconds or so press F7 to stop the log.
   
- In the left hand pane, click on the game executable name & click on a packet header. Expand the packet info under "Frame Details" and finally expand the subcategory "Ipv4". This will reveal the current DSCP value of each frame.

    <img src="../media/network-monitor-new-capture.png" width="450">

</details>

#### What TscSyncPolicy does Windows use by default?

<details>
<summary>Read More</summary>
<br>

After searching through the decompiled ntoskrnl.exe pseudocode in [Hex-Rays IDA](https://hex-rays.com/products/idahome/), i noticed that ``HalpTscSyncPolicy`` is changed when TscSyncPolicy is configured via bcdedit.exe. Despite many claims of enhanced being the default value, there has no been evidence so i decided to find out myself.

We can read ``HalpTscSyncPolicy`` in a local kernel debugger such as [WinDbg](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/debugger-download-tools) in realtime to find out the different values it returns with different bcd store configurations. See results below.

bcdedit.exe /deletevalue tscsyncpolicy (windows default):
```
lkd> dd HalpTscSyncPolicy l1
fffff801`2de4a3ac  00000000
```
bcdedit.exe /set tscsyncpolicy default:
```
lkd> dd HalpTscSyncPolicy l1
fffff803`1dc4a3ac  00000000
```
bcdedit.exe /set tscsyncpolicy legacy:
```
lkd> dd HalpTscSyncPolicy l1
fffff805`1dc4a3ac  00000001
```
bcdedit.exe /set tscsyncpolicy enhanced:
```
lkd> dd HalpTscSyncPolicy l1
fffff802`2864a3ac  00000002
```

Conclusion: By default, Windows uses the ``default`` value, not ``enhanced`` or ``legacy``

</details>

#### How many Rss Queues do you need?

<details>
<summary>Read More</summary>
<br>

Receive side scaling (Rss) is a network driver technology that enables the efficient distribution of network receive processing across multiple CPUs in multiprocessor systems [[1](https://docs.microsoft.com/en-us/windows-hardware/drivers/network/introduction-to-receive-side-scaling)]. The amount you should use or need depends on your typical network load. In server environments, a large amount of Rss queues is desirable as receive processing delays will be reduced & ensures that no CPU is heavily loaded. The same concept can be applied to games however the network load differs significantly making it an invalid comparison so i decided to carry out some experiments myself, see results below.

I simulated Valorant's network traffic in iperf using two machines (~300kb/s receive in deathmatch) & monitored the network driver's activity in xperf. Please note that RssBaseProcessor is set to 0, so theoretically, CPU 0 & CPU 1 should be handling DPCs/ISRs for ndis.sys.

<img src="../media/300kbps-ndis-xperf-report.png" width="500">

I noticed that despite having Rss queues set to 2, only CPU 1 was primarily handling interrupts for the driver which i assume was due to such little traffic. So I decided to re-test with the same configuration, however this time i simulated 1Gbps network traffic to verify this.

<img src="../media/1gbps-ndis-xperf-report.png" width="500">

As expected, this scenario demonstrates that both CPU 0 & CPU 1 are handling DPCs/ISRs for ndis.sys.

Conclusion: During online matches, at most two Rss queues/cores are being utilized, however there is no harm in using more than two but it is important to be aware of the information above as people reserve consecutive cores specifically for the network driver when those core(s) could better be used for another driver or a real-time application. The amount of Rss queues a network adapter has may also determine the quality of the hardware but this is yet to be explored but something to keep in mind.

</details>
