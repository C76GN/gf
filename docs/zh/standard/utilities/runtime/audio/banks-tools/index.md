# Audio Bank 与配置工具

本组页面说明 `GFAudioBank` 的分层事件 ID、候选片段、fallback 播放，以及 `GFAudioBankTools` 的扫描、导入和播放前校验。

## 阅读入口

- [Bank 播放](bank-playback.md)：`GFAudioClip`、`GFAudioBank`、候选权重、事件 ID fallback 和验证。
- [Bank 工具与导入](bank-tools-import.md)：扫描音频路径、生成 Bank、同步已有 Bank 和 Inspector 入口。

## 使用边界

Audio Bank 只提供通用事件 ID 到音频候选的映射和导入辅助。声音命名规范、混音策略、平台音频 SDK、语言包和项目事件生命周期由项目层决定。
