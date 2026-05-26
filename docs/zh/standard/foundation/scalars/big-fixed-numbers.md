# 大数与定点数

`GFBigNumber` 和 `GFFixedDecimal` 解决两类不同数值问题：前者用于超大量级展示和近似计算，后者用于固定小数位的精确累计。

## `GFBigNumber`

`GFBigNumber` 适合挂机/放置类游戏的超大数值。它使用尾数 + 指数的形式表达量级，可用于：

- 超出原生 `float` 直观显示范围的资源数量
- 跨数量级比较
- 高阶增长、收益结算、战力显示

```gdscript
var gold := GFBigNumber.from_string("1.25e18")
var bonus := GFBigNumber.from_string("2e17")
var total := gold.add(bonus)
print(total.to_scientific_string()) # 1.45e18
```

`GFBigNumber` 是显示和量级计算用的近似大数。它适合挂机资源、战力、收益预估和跨数量级比较，不适合作为付费货币、强精度经济结算、竞技排行榜最终判定或任何要求逐分逐厘精确的权威数据源。

## `GFFixedDecimal`

`GFFixedDecimal` 适合货币、税率、百分比、经营数值这类对累计误差更敏感的场景。它内部用整数缩放保存值。

```gdscript
var price := GFFixedDecimal.from_string("12.34", 2)
var tax := GFFixedDecimal.from_string("0.08", 2)
var total := price.multiply(tax, 2).add(price)
print(total.to_decimal_string()) # 13.33
```

普通十进制字符串会走整数缩放解析；科学计数法字符串会先退回 float 路径再构建定点数，可能存在浮点舍入。需要严格十进制导入时，建议用普通十进制字符串，或在项目导表阶段把科学计数法预处理成固定小数文本。
