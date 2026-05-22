## GFRichTextFormatter: 通用 RichTextLabel BBCode 格式化辅助。
##
## 提供安全转义、Markdown 子集转 BBCode、变量占位符替换和可配置 token 替换。
## 该类不加载任何资源，不规定文本来源、语言、本地化、图标集或 UI 展示规则。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFRichTextFormatter
extends RefCounted


# --- 常量 ---

## BBCode 输入模式。
## [br]
## @api public
const MARKUP_BBCODE: StringName = &"bbcode"

## 普通文本输入模式，会先转义 BBCode 控制字符。
## [br]
## @api public
const MARKUP_PLAIN: StringName = &"plain"

## Markdown 子集输入模式，会转换为 RichTextLabel BBCode。
## [br]
## @api public
const MARKUP_MARKDOWN: StringName = &"markdown"

const _STRIP_LEFT_BRACKET_PLACEHOLDER: String = "__GF_ESCAPED_LEFT_BRACKET__"
const _STRIP_RIGHT_BRACKET_PLACEHOLDER: String = "__GF_ESCAPED_RIGHT_BRACKET__"


# --- 公共方法 ---

## 格式化文本为 RichTextLabel 可用的 BBCode。
## [br]
## @api public
## [br]
## @param text: 原始文本。
## [br]
## @param options: 可选设置，支持 markup、variables、variable_resolver、variable_prefix、variable_suffix、token_resolver、token_prefix、token_suffix。
## [br]
## @return BBCode 文本。
## [br]
## @schema options: Dictionary，支持 markup、variables、variable_resolver、variable_prefix、variable_suffix、escape_variable_values、missing_variable_text、token_resolver、token_prefix、token_suffix、escape_token_values。
static func to_bbcode(text: String, options: Dictionary = {}) -> String:
	var markup: StringName = StringName(options.get("markup", MARKUP_BBCODE))
	var result: String = text

	match markup:
		MARKUP_PLAIN:
			result = escape_bbcode(result)
		MARKUP_MARKDOWN:
			result = markdown_to_bbcode(result)
		_:
			pass

	var raw_variables: Variant = options.get("variables", {})
	var variables: Dictionary = raw_variables if raw_variables is Dictionary else {}
	var variable_resolver := _get_callable_option(options, "variable_resolver")
	if not variables.is_empty() or variable_resolver.is_valid():
		result = replace_variables(result, variables, variable_resolver, options)

	var token_resolver := _get_callable_option(options, "token_resolver")
	if token_resolver.is_valid():
		result = replace_tokens(result, token_resolver, options)

	return result


## 把常见 Markdown 子集转换为 RichTextLabel BBCode。
## [br]
## @api public
## [br]
## @param text: Markdown 文本。
## [br]
## @return BBCode 文本。
static func markdown_to_bbcode(text: String) -> String:
	var pattern := (
		"!\\[([^\\]]*)\\]\\(([^\\)]+)\\)"
		+ "|\\[([^\\]]+)\\]\\(([^\\)]+)\\)"
		+ "|`([^`]+)`"
		+ "|\\*\\*([^\\*]+)\\*\\*"
		+ "|\\*([^\\*]+)\\*"
		+ "|~~([^~]+)~~"
	)
	return _replace_regex_matches(text, pattern, func(match_result: RegExMatch) -> String:
		if not match_result.get_string(2).is_empty():
			return "[img]%s[/img]" % escape_bbcode(match_result.get_string(2))
		if not match_result.get_string(4).is_empty():
			return "[url=%s]%s[/url]" % [
				escape_bbcode(match_result.get_string(4)),
				escape_bbcode(match_result.get_string(3)),
			]
		if not match_result.get_string(5).is_empty():
			return "[code]%s[/code]" % escape_bbcode(match_result.get_string(5))
		if not match_result.get_string(6).is_empty():
			return "[b]%s[/b]" % escape_bbcode(match_result.get_string(6))
		if not match_result.get_string(7).is_empty():
			return "[i]%s[/i]" % escape_bbcode(match_result.get_string(7))
		if not match_result.get_string(8).is_empty():
			return "[s]%s[/s]" % escape_bbcode(match_result.get_string(8))
		return escape_bbcode(match_result.get_string(0))
	)


## 替换变量占位符。
## [br]
## @api public
## [br]
## @param text: 输入文本。
## [br]
## @param variables: 变量字典。
## [br]
## @param resolver: 可选变量解析回调，签名为 func(name: String) -> Variant。
## [br]
## @param options: 可选设置，支持 variable_prefix、variable_suffix、escape_variable_values、missing_variable_text。
## [br]
## @return 替换后的文本。
## [br]
## @schema variables: Dictionary，key 为变量名 String，value 为会转成文本的任意值。
## [br]
## @schema options: Dictionary，支持 variable_prefix、variable_suffix、escape_variable_values、missing_variable_text。
static func replace_variables(
	text: String,
	variables: Dictionary = {},
	resolver: Callable = Callable(),
	options: Dictionary = {}
) -> String:
	var prefix := String(options.get("variable_prefix", "{{"))
	var suffix := String(options.get("variable_suffix", "}}"))
	var escape_values := bool(options.get("escape_variable_values", true))
	var missing_text := String(options.get("missing_variable_text", ""))
	return _replace_wrapped_segments(
		text,
		prefix,
		suffix,
		func(token: String) -> String:
			var value: Variant = null
			var has_value := false
			if resolver.is_valid():
				value = resolver.call(token)
				has_value = value != null
			if not has_value and variables.has(token):
				value = variables[token]
				has_value = true
			if not has_value:
				return missing_text

			var value_text := str(value)
			return escape_bbcode(value_text) if escape_values else value_text
	)


## 替换可配置 token，例如 `:icon_id:`。
## [br]
## @api public
## [br]
## @param text: 输入文本。
## [br]
## @param resolver: token 解析回调，签名为 func(token: String) -> String。
## [br]
## @param options: 可选设置，支持 token_prefix、token_suffix、escape_token_values。
## [br]
## @return 替换后的文本。
## [br]
## @schema options: Dictionary，支持 token_prefix、token_suffix、escape_token_values。
static func replace_tokens(text: String, resolver: Callable, options: Dictionary = {}) -> String:
	if not resolver.is_valid():
		return text

	var prefix := String(options.get("token_prefix", ":"))
	var suffix := String(options.get("token_suffix", ":"))
	var escape_values := bool(options.get("escape_token_values", false))
	return _replace_wrapped_segments(
		text,
		prefix,
		suffix,
		func(token: String) -> String:
			if not _is_safe_token(token):
				return prefix + token + suffix

			var raw_resolved: Variant = resolver.call(token)
			if raw_resolved == null:
				return prefix + token + suffix

			var resolved := String(raw_resolved)
			if resolved.is_empty():
				return prefix + token + suffix
			return escape_bbcode(resolved) if escape_values else resolved
	)


## 转义 BBCode 控制字符。
## [br]
## @api public
## [br]
## @param text: 输入文本。
## [br]
## @return 可安全嵌入 BBCode 的文本。
static func escape_bbcode(text: String) -> String:
	var result := ""
	for index: int in range(text.length()):
		var character := text.substr(index, 1)
		if character == "[":
			result += "[lb]"
		elif character == "]":
			result += "[rb]"
		else:
			result += character
	return result


## 移除 BBCode 标签。
## [br]
## @api public
## [br]
## @param text: 输入文本。
## [br]
## @return 去掉标签后的文本。
static func strip_bbcode(text: String) -> String:
	var regex := RegEx.new()
	var error := regex.compile("\\[[^\\]]*\\]")
	if error != OK:
		return text

	var protected_text := text
	protected_text = protected_text.replace("[lb]", _STRIP_LEFT_BRACKET_PLACEHOLDER)
	protected_text = protected_text.replace("[rb]", _STRIP_RIGHT_BRACKET_PLACEHOLDER)
	var stripped := regex.sub(protected_text, "", true)
	stripped = stripped.replace(_STRIP_LEFT_BRACKET_PLACEHOLDER, "[")
	stripped = stripped.replace(_STRIP_RIGHT_BRACKET_PLACEHOLDER, "]")
	return stripped


# --- 私有/辅助方法 ---

static func _get_callable_option(options: Dictionary, key: String) -> Callable:
	var value: Variant = options.get(key, Callable())
	if value is Callable:
		return value
	return Callable()


static func _replace_regex_matches(text: String, pattern: String, replacement_builder: Callable) -> String:
	var regex := RegEx.new()
	var error := regex.compile(pattern)
	if error != OK or not replacement_builder.is_valid():
		return text

	var result := ""
	var cursor := 0
	for match_result: RegExMatch in regex.search_all(text):
		var start := match_result.get_start()
		var end := match_result.get_end()
		if start < cursor:
			continue

		result += escape_bbcode(text.substr(cursor, start - cursor))
		result += String(replacement_builder.call(match_result))
		cursor = end

	result += escape_bbcode(text.substr(cursor))
	return result


static func _replace_wrapped_segments(
	text: String,
	prefix: String,
	suffix: String,
	resolver: Callable
) -> String:
	if prefix.is_empty() or suffix.is_empty() or not resolver.is_valid():
		return text

	var result := ""
	var cursor := 0
	while cursor < text.length():
		var start := text.find(prefix, cursor)
		if start < 0:
			result += text.substr(cursor)
			break

		var token_start := start + prefix.length()
		var end := text.find(suffix, token_start)
		if end < 0:
			result += text.substr(cursor)
			break

		result += text.substr(cursor, start - cursor)
		var token := text.substr(token_start, end - token_start)
		result += String(resolver.call(token))
		cursor = end + suffix.length()

	return result


static func _is_safe_token(token: String) -> bool:
	if token.is_empty():
		return false

	for index: int in range(token.length()):
		var character := token.substr(index, 1)
		if not _is_safe_token_character(character):
			return false
	return true


static func _is_safe_token_character(character: String) -> bool:
	return (
		(character >= "a" and character <= "z")
		or (character >= "A" and character <= "Z")
		or (character >= "0" and character <= "9")
		or character == "_"
		or character == "-"
		or character == "."
	)
