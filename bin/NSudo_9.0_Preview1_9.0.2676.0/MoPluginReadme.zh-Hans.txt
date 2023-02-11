﻿# 毛利优化插件 简易使用方法

## 适用版本

- 9.0.2676.0

## MoDefragMemory

### 功能

内存碎片整理，通过把物理内存中的大部分内存交换到页面文件实现

### 用法

> NSudoPluginHost MoPlugin.dll MoDefragMemory

## MoEnableMicrosoftUpdate

### 功能

开启 Windows Update 中 "更新 Windows 时提供其他 Microsoft 产品的更新" 的选项

### 用法

> NSudoPluginHost MoPlugin.dll MoEnableMicrosoftUpdate

## MoManageCompactOS

### 功能

CompactOS 管理

### 用法

- `/Query` 查询 CompactOS 状态
  > NSudoPluginHost MoPlugin.dll MoManageCompactOS /Query
- `/Enable` 启用 CompactOS
  > NSudoPluginHost MoPlugin.dll MoManageCompactOS /Enable
- `/Disable` 禁用 CompactOS
  > NSudoPluginHost MoPlugin.dll MoManageCompactOS /Disable

## MoPurgeChromiumCache

### 功能

基于 Chromium 的应用程序的 Web 缓存清理，包括 Chrome、基于 Chromium 的 Edge 和
基于 Electron 的应用程序等

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgeChromiumCache /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgeChromiumCache /Purge

## MoPurgeCorruptedAppXPackages

### 功能

损坏的 AppX 包清理

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgeCorruptedAppXPackages /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgeCorruptedAppXPackages /Purge

## MoPurgeDeliveryOptimizationCache

### 功能

传递优化缓存清理

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgeDeliveryOptimizationCache /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgeDeliveryOptimizationCache /Purge

## MoPurgeGeckoCache

### 功能

基于 Gecko 的应用程序的 Web 缓存清理，包括 Firefox、Waterfox 和 Pale Moon 等

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgeGeckoCache /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgeGeckoCache /Purge

## MoPurgeNuGetCache

### 功能

NuGet 缓存安全清理

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgeNuGetCache /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgeNuGetCache /Purge

## MoPurgePackageCache

### 功能

Package Cache 目录安全清理

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgePackageCache /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgePackageCache /Purge

## MoPurgeSystemRestorePoint

### 功能

系统还原点清理

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgeSystemRestorePoint /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgeSystemRestorePoint /Purge

## MoPurgeTridentCache

### 功能

基于 Trident 的应用程序的 Web 缓存清理，包括 Internet Explorer、传统版本的 
Edge、基于 MSHTML 的应用程序和基于based applications, Edge WebView 的应用程
序等

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgeTridentCache /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgeTridentCache /Purge

## MoPurgeVisualStudioCodeCache

### 功能

Visual Studio Code 缓存清理

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgeVisualStudioCodeCache /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgeVisualStudioCodeCache /Purge

## MoPurgeVisualStudioInstallerCache

### 功能

Visual Studio Installer 缓存安全清理

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgeVisualStudioInstallerCache /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgeVisualStudioInstallerCache /Purge

## MoPurgeWindowsEventLog

### 功能

Windows 事件日志清理

### 用法

- `/Scan` 扫描
  > NSudoPluginHost MoPlugin.dll MoPurgeWindowsEventLog /Scan
- `/Purge` 清理
  > NSudoPluginHost MoPlugin.dll MoPurgeWindowsEventLog /Purge

## MoUpdateAppXPackages

### 功能

Windows 商店应用一键升级

### 用法

- 无参数
  > NSudoPluginHost MoPlugin.dll MoUpdateAppXPackages
- `/Loop` 循环执行，直到无应用包需要升级再停止
  > NSudoPluginHost MoPlugin.dll MoUpdateAppXPackages /Loop
