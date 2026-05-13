## GFInteractionContext: 一次交互流程的轻量上下文。
##
## 用于在 Command、事件或项目自定义方法之间传递 sender、target、payload 与可选分组信息。
class_name GFInteractionContext
extends RefCounted


# --- 公共变量 ---

## 交互发起者。
var sender: Object = null

## 交互目标。
var target: Object = null

## 交互携带的数据。
var payload: Variant = null

## 交互所属的可选分组。
var group_name: StringName = &""


# --- Godot 生命周期方法 ---

func _init(
	p_sender: Object = null,
	p_target: Object = null,
	p_payload: Variant = null,
	p_group_name: StringName = &""
) -> void:
	sender = p_sender
	target = p_target
	payload = p_payload
	group_name = p_group_name


# --- 公共方法 ---

## 设置 sender 并返回自身，便于链式构造。
## @param value: 要写入或修改的值。
func with_sender(value: Object) -> GFInteractionContext:
	sender = value
	return self


## 设置 target 并返回自身，便于链式构造。
## @param value: 要写入或修改的值。
func with_target(value: Object) -> GFInteractionContext:
	target = value
	return self


## 设置 payload 并返回自身，便于链式构造。
## @param value: 要写入或修改的值。
func with_payload(value: Variant) -> GFInteractionContext:
	payload = value
	return self


## 设置 group_name 并返回自身，便于链式构造。
## @param value: 要写入或修改的值。
func with_group(value: StringName) -> GFInteractionContext:
	group_name = value
	return self
