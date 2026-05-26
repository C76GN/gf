# 兼容旧存档

2.0 默认关闭旧版纯 JSON 回退。当项目已经配置混淆、压缩或 Binary 格式时，解码失败不会再自动尝试按未混淆 JSON 读取原始 bytes。

迁移旧文件时可临时启用 `allow_legacy_plain_json_fallback`。

JSON 读取默认保留解析出的数字类型。如果旧存档列表或元数据依赖把接近整数的 float 归一为 int，可临时开启 `GFStorageUtility.normalize_json_numbers` 或 `GFStorageCodec.normalize_json_numbers` 后读出并重写。

`allow_absolute_paths` 默认关闭，绝对路径会收敛回 `user://<save_dir_name>/` 下的同名文件。

只有可信编辑器工具或迁移脚本确实需要写入外部路径时，才应显式设为 `true`。

`save_slot()` 只接受大于等于 `0` 的整数槽位。`load_slot_result()` / `load_slot_meta_result()` 可区分“合法空字典”和“文件缺失、非法槽位或解码失败”。

异步 `save_data_async()` / `load_data_async()` 会按文件串行和线程预算调度。

如果同一路径需要混合同步和异步读写，先调用 `wait_for_async_tasks()` 收敛已入队任务顺序，再执行同步 `save_data()` / `load_data()`。

`dispose()` 会等待已开始的线程结束并发出对应完成信号，对尚未开始的队列任务发出失败结果，避免调用方一直等待完成通知。
