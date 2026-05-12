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

## [3.1.0] - 2026-05-12

**版本概述**：本版本为 Combat 命中区域补充可复用碰撞形状配置能力，使项目可以在复用同一组 HitBox / HurtBox 节点时按攻击配置切换 Godot 原生碰撞形状，同时明确官方包的 GF 发行版本与包自身版本之间的边界。

### 🚀 新增特性

- 新增 `GFHitCollisionShapeConfig2D` 与 `GFHitCollisionShapeConfig3D`，用于以 Resource 形式复用 HitBox / HurtBox 的 Godot 原生碰撞形状、偏移、旋转、缩放和 disabled 状态。
- `GFHitBox2D`、`GFHurtBox2D`、`GFHitBox3D` 与 `GFHurtBox3D` 新增 `collision_shape_config`、`auto_apply_collision_shape_config`、`apply_collision_shape_config()`、`get_generated_collision_shape()` 和 `clear_generated_collision_shape()`，用于按配置生成或更新框架管理的 CollisionShape 子节点。
- `GFPackageManifest` 新增 `package_version` 字段，用于记录单个包自身的公开行为版本。

### 🔄 机制更改

- 官方包 `gf_package.json` 的 `version` 表示当前 GF 官方发行版本，发布时所有官方包必须同步；`package_version` 表示包自身版本，只有该包的公开 API、配置、行为或兼容性契约发生变化时才按 SemVer 递增。
- 本版本所有官方包的 `version` 同步为 `3.1.0`；Combat 包因新增公开配置能力将 `package_version` 递增为 `1.1.0`，其余未发生包内公开行为变化的官方包保持 `package_version` 为 `1.0.0`。

### 🔌 API 变动说明

- 新增 Combat 命中区域配置化碰撞形状 API；该能力只生成或更新框架管理的 `CollisionShape2D` / `CollisionShape3D` 子节点，不修改用户手写的其他碰撞节点。
- `collision_shape_config` 置空或缺少 `shape` 时会清理框架管理的生成节点，避免切换攻击形状后残留旧碰撞区域。
- 官方包 manifest 新增 `package_version`，旧 manifest 未声明该字段时工具会回退使用 `version`；GF 官方包从本版本起必须显式声明。

### 📁 核心受影响文件

- `addons/gf/kernel/package/gf_package_manifest.gd`
- `addons/gf/kernel/editor/package/gf_package_manager_dock.gd`
- `addons/gf/packages/official/*/gf_package.json`
- `addons/gf/packages/official/combat/hit_detection/**`
- `tests/gf_core/kernel/package/test_gf_package_manifest.gd`
- `tests/gf_core/packages/official/combat/test_gf_combat_extension.gd`
- `AI_MAINTENANCE.md`
- `addons/gf/packages/README.md`
- `docs/zh/packages/index.md`
- `docs/zh/packages/combat/index.md`
