# 更新日志 (Changelog)

## 📝 日志条目结构标准

每次版本更新应包含以下核心模块（若无相关变动可省略该模块）：

1. **版本号与日期**：格式为 `## [主版本.次版本.修订号] - YYYY-MM-DD`
2. **版本概述**：简短描述该版本的核心目标（如：大型特性更新、紧急修复、性能重构等）。
3. **🚀 新增特性 (Added)**：新加入的类、方法、系统、扩展组件等。
4. **🔄 机制更改 (Changed)**：对现有功能逻辑的修改、内部重构、性能优化等。
5. **🐛 Bug 修复 (Fixed)**：修复的逻辑错误、内存泄漏、崩溃问题等。
6. **⚠️ 废弃与移除 (Deprecated/Removed)**：标记为废弃（将在未来移除）或本次直接移除的接口、文件。
7. **🔌 API 变动说明 (API Changes)**：详细列出函数签名改变、属性重命名等直接导致旧代码报错的改动。
8. **📘 升级指南 (Migration Guide)**：为使用旧版本框架的开发者提供 Step-by-Step 的升级建议和兼容性处理方案。
9. **📁 核心受影响文件 (Affected Files)**：列出改动最大的核心源码文件，方便开发者进行二次开发比对。

---

## 维护策略

正式文档中的更新日志只保留当前最新发布版本。发布新版本时，应将 `[未发布]` 合并为具体版本条目，并删除上一个正式版本条目；旧版本历史以 Git 历史和 GitHub Releases 为准，避免正式文档长期膨胀。

---

## [3.11.0] - 2026-05-18

**版本概述**：扩展标准音频工具的 BGM transport 与 SFX 生命周期控制，让暂停菜单、剧情恢复、关卡切换和全局静音/停止流程可以复用 GF 自己的音频抽象，而不是项目层手动管理播放器节点。

### 🚀 新增特性

- `GFAudioUtility` 新增 `play_bgm_with_options()`、`pause_bgm()`、`resume_bgm()`、`seek_bgm()`、`get_bgm_playback_position()`、`is_bgm_paused()` 和 `stop_all_sfx()`。
- `GFAudioBackend` 新增对应 BGM transport 与 stop-all SFX 可选协议，外部音频后端可选择接管这些控制请求。
- `GFAudioUtility` 新增 `bgm_finished(history_key)` 信号，并在调试快照中公开 BGM 暂停状态、播放位置、loop 覆盖值和空间 SFX 活跃数量。

### 🔄 机制更改

- 默认 Godot BGM 播放路径使用 `AudioStreamPlayer.stream_paused` 保留暂停位置，显式传入 `loop` 时复制音频流再尝试设置循环属性，避免修改共享 Resource。
- 普通 SFX 与 2D/3D 空间 SFX 现在都会被 `stop_all_sfx()` 跟踪和释放；该接口会同时取消尚未完成的异步 SFX 请求。

### 🔌 API 变动说明

- `GFAudioUtility.get_debug_snapshot()` 新增 `bgm_paused`、`bgm_position`、`current_bgm_loop` 和 `active_spatial_sfx_count` 字段。
- `GFAudioBackend` 的新增方法都是默认返回未处理的可选协议；未实现这些方法的项目后端应继承当前基类以获得默认行为。

### 📘 升级指南

- 项目中用于暂停菜单或场景切换的手写 BGM 暂停/恢复逻辑，可迁移到 `pause_bgm()`、`resume_bgm()` 和 `get_bgm_playback_position()`。
- 项目中手动遍历 SFX 播放器的停止逻辑，可迁移到 `stop_all_sfx()`；需要精细控制单次播放时仍使用 `GFAudioEmitterHandle`。

### 📁 核心受影响文件

- 音频协议：`addons/gf/standard/utilities/audio/gf_audio_backend.gd`。
- 音频工具：`addons/gf/standard/utilities/audio/gf_audio_utility.gd`。
- 测试：`tests/gf_core/standard/utilities/audio/test_gf_audio_utility.gd`。
- 文档：`docs/zh/standard/utilities/runtime/audio.md`。

---
