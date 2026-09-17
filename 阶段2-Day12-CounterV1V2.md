# 阶段 2 · Day 12 — CounterV1 / CounterV2

> 知识库：[阶段2-Day12-CounterV1V2](https://worserole.github.io/web3-learning-docs/foundry/阶段2-Day12-CounterV1V2.html) · Day 11：[阶段2-Day11-Proxy原理](./阶段2-Day11-Proxy原理.md)

---

## 交付

- `src/CounterV1.sol` — 同 `Counter`
- `src/CounterV2.sol` — 同 layout + `reset()` / `version()` 返回 `"2"`
- `test/CounterUpgrade.t.sol` — V1/V2 断言 + revert

**Layout：** `Ownable.owner` → slot 0，`number` → slot 1。

---

## 测试

```bash
forge test --match-contract CounterUpgrade -vv
forge test   # 27 passed
```

覆盖：increment/decrement 数值、`reset` 先增后清、非 owner reset/setNumber revert、V1 decrement too small、`version == "2"`。

---

## Day 12 ✅

**下一步 Day 13：** OZ UUPS、`initialize`、部署 ERC1967Proxy。
