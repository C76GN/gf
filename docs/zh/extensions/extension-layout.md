# 扩展目录结构

GF 内置扩展直接位于 `addons/gf/extensions` 下一层。每个扩展以独立子目录维护自己的 manifest、运行时代码、资源和编辑器贡献。

## 扩展根目录

```text
addons/gf/
  kernel/
  standard/
  extensions/
    action_queue/
    behavior_tree/
    capability/
    combat/
    ...
```

`addons/gf/extensions` 是 GF 内置扩展根目录。外部扩展可以复用 GF 的 manifest 约定，但应作为项目代码或独立 Godot 插件维护在 `addons/gf` 外。

## 扩展内结构

扩展内部不机械复制整个 GF 目录。扩展根目录只放扩展元数据、可选装配入口和说明文档，业务代码进入稳定槽位。这样从文件树上就能看出“这是扩展入口”还是“这是运行时代码”。

```text
addons/gf/extensions/example/
  gf_extension.json
  extension.gd            # 可选，继承 GFInstaller
  README.md               # 可选，扩展内说明
  foundation/             # 可选：扩展内纯算法、值对象、codec
  runtime/                # 可选：Model/System/Utility 等运行时模块
  resources/              # 可选：配置、定义、Resource 数据
  nodes/                  # 可选：场景节点、Controller、桥接节点
  editor/                 # 可选：Inspector、生成器、导入器
  actions/                # 可选：动作/步骤/命令式表现单元
  tests/                  # 可选：扩展内测试
  examples/               # 可选：示例场景或资源
```

如果扩展已经像 `combat`、`network`、`save` 这类大型内置扩展一样有清晰的内部领域，也可以使用领域子目录，例如 `hit_detection`、`serialization`、`serializers`。原则是目录名表达稳定职责，而不是表达临时实现细节。

小扩展优先使用 `runtime`、`resources`、`nodes`、`editor` 这些通用槽位，保持扩展结构一致。
