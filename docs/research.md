# Research

#### How can you verify if a DSCP QoS policy is working?

<details>
<summary>Read More</summary>

- Download & install [Microsoft Network Monitor 3.4](https://www.microsoft.com/en-gb/download/details.aspx?id=4865).
   
- Create a new capture.
   
    <img src="../media/network-monitor-new-capture.png" width="450">

- Open a game that you have applied a DSCP value for & enter a game mode in which the game will send & receive packets (e.g an online match, not a local match).
   
- Press F5 to start logging. After 30 seconds or so press F7 to stop the log.
   
- In the left hand pane, click on the game executable name & click on a packet header. Expand the packet info under "Frame Details" and finally expand the subcategory "Ipv4". This will reveal the current DSCP value of each frame.

    <img src="../media/network-monitor-dscp-value.png" width="400">

</details>

---

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

---

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

---

#### Win32PrioritySeparation

- #### The truth behind ambiguous values

    <details>
    <summary>Read More</summary>
    <br>
    
    According to the documentation windows allows up to 0x3F (63 decimal) because the bitmask is made up of 6-bits [[1](bitmask)], so why do values above this exist? what happens if we enter a value greater than the (theoretically) maximum allowed? let's find out.

    We can read PsPrioritySeparation & PspForegroundQuantum in a local kernel debugger such as WinDbg in realtime and use the quantum index provided in the windows internals book to find out the different values it returns with different Win32PrioritySeparation entries. See results below.

    | PsPrioritySeparation | Foreground boost |
    |----------------------|------------------|
    | 2                    | 3:1              |
    | 1                    | 2:1              |
    | 0                    | 1:1              |

    <img src="../media/w32ps-quantum-index.png" width="600">

    Demonstration with the windows default, **0x2 (2 decimal)** :

    ```
    lkd> dd PsPrioritySeparation L1
    fffff802`3a6fc5c4  00000002

    lkd> db PspForegroundQuantum L3
    fffff802`3a72e874  06 0c 12
    ```
    PspForegroundQuantum returns the values in hexadecimal so we need to convert it to decimal in order to use the tables correctly. ``06 0c 12`` is equivalent to ``6 12 18`` and PsPrioritySeparation returns ``2``. In the tables, this corresponds to short, variable, 3:1. But we already knew this as it is documented by microsoft, so now lets try an ambiguous value.

    **0xffff3f91 (4294918033 decimal)**:

    ```
    lkd> dd PsPrioritySeparation L1
    fffff802`3a6fc5c4  00000001

    lkd> db PspForegroundQuantum L3
    fffff802`3a72e874  0c 18 24
    ```

    ``0c 18 24`` is equivalent to ``12 24 36`` and PsPrioritySeparation returns ``1`` which corresponds to long, variable, 2:1. Nothing special as it seems, this is actually equivalent to values less than the maximum documented value as shown in [this csv](https://raw.githubusercontent.com/djdallmann/GamingPCSetup/master/CONTENT/RESEARCH/FINDINGS/win32prisep0to271.csv). I had the same results while testing various other values.

    Conclusion: Why does windows allow us to enter values greater than 0x3F (63 decimal) if any value greater than this is equivalent to values less than the maximum documented value? The reason behind this is because the maximum value for a REG_DWORD is 0xFFFFFFFF (4294967295 decimal) [[1](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-dtyp/262627d8-3418-4627-9218-4ffe110850b2)] and there are no restrictions in place to prevent users to entering a illogical value, so when the kernel reads the Win32PrioritySeparation registry key, it must account for invalid values so it only reads a portion of the entered value. The portion it chooses to read is the first 6-bits of the bitmask which means values greater than 63 are recurring values.
    </details>

---


<!-- #### Title

<details>
<summary>Read More</summary>
<br>

</details> -->