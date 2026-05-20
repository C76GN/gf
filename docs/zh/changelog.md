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

## [3.16.1] - 2026-05-21

**版本概述**：增强声明式信号桥接的配置校验，收紧槽位库存可增长容量语义，并修正音频配置的默认扩展名选择表面，让资源化信号连接、通用槽位容器和音频配置都能更早暴露配置问题。

### 🔄 机制更改 (Changed)

- `GFSignalBridge.get_validation_report()` 现在会报告 `argument_indices` 越界，以及桥接后传给目标方法的参数数量不匹配，避免无效桥接延迟到运行时调用才失败。
- `GFSlotInventoryModel.get_remaining_capacity_for_item()` 现在会在 `allow_growth = true` 且物品存在有限 `max_stack_count` 时，把可增长的新堆叠容量计入剩余容量，便于非部分加入前准确预判容量。
- `GFAudioClip.path` 的文件选择器现在与 `GFAudioBankTools.AUDIO_EXTENSIONS` 保持一致，默认允许选择 `opus` 音频资源。

### 🐛 Bug 修复

- 修复 `GFSlotInventoryModel.add_item()` 在可增长库存达到物品堆叠数量上限时仍可能额外创建空槽的问题。

### 📁 核心受影响文件 (Affected Files)

- 信号桥接：`addons/gf/standard/utilities/signals/bridge/gf_signal_bridge.gd`、`tests/gf_core/standard/utilities/signals/bridge/test_gf_signal_bridge.gd`、`docs/zh/standard/utilities/runtime/time-signal-pool.md`。
- 领域库存：`addons/gf/extensions/domain/inventory/gf_slot_inventory_model.gd`、`tests/gf_core/extensions/domain/test_gf_domain_extensions.gd`、`docs/zh/extensions/flow-domain-physics/index.md`。
- 标准音频：`addons/gf/standard/utilities/audio/gf_audio_clip.gd`、`tests/gf_core/standard/utilities/audio/test_gf_audio_bank_tools.gd`、`docs/zh/standard/utilities/runtime/audio.md`。
