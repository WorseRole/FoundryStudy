# 阶段 2 · Day 14 — 升级 V2 + Sepolia

> 知识库：[阶段2-Day14-升级Sepolia](https://worserole.github.io/web3-learning-docs/foundry/阶段2-Day14-升级Sepolia.html)

---

## Sepolia 地址

| 角色 | 地址 |
|------|------|
| **Proxy（用户只调这个）** | [0x901D…4F73](https://sepolia.etherscan.io/address/0x901D9F0d66db49226476372e1B63684bFEbE4F73) |
| V1 impl | [0xC2fB…6550](https://sepolia.etherscan.io/address/0xC2fB0cB014D76fF0beDFE4CfaB8Aafba77036550) |
| V2 impl | [0x22b7…6AC1](https://sepolia.etherscan.io/address/0x22b7144CFd9D2A7e5936EB8418C2c33cf6dd6AC1) |

Day 13：3 tx（V1 impl · Proxy+init · increment）。Day 14：2 tx（V2 impl · upgradeToAndCall+initializeV2）。

---

## 脚本

```bash
forge script script/CounterUpgradeV2.s.sol --rpc-url sepolia -vvvv
forge script script/CounterUpgradeV2.s.sol --rpc-url sepolia --broadcast -vvvv
```

---

## 验收（链上）

- `number == 2`（升级前后不变）
- `bump == 100`，`version == "2"`

```bash
cast call 0x901D9F0d66db49226476372e1B63684bFEbE4F73 "number()(uint256)" --rpc-url sepolia
```

---

**下一步 Day 15：** 阶段 2 串讲 + 升级风险复盘。
