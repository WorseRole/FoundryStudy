# 阶段 2 · Day 11 — Proxy 升级原理

> **Day 11**：只读原理，不写链上代码。  
> 对照 [知识地图 01 · Delegatecall / Proxy / Storage Layout](https://worserole.github.io/web3-learning-docs/web3/恢复基础，建立知识地图.html)  
> 知识库镜像：[阶段2-Day11-Proxy原理](https://worserole.github.io/web3-learning-docs/foundry/阶段2-Day11-Proxy原理.html)

---

## 1. 一句话模型

**用户永远调 Proxy 地址；业务状态写在 Proxy 的 storage；逻辑代码在 Implementation，通过 `delegatecall` 执行；升级 = 把 Proxy 里存的 `implementation` 指针从 V1 换成 V2。**

---

## 2. A / B / C 对照标准术语

| 口语 | 标准名 | 说明 |
|------|--------|------|
| 逻辑合约 A | **Implementation V1** | 提供 bytecode；升级场景下用户不直接调它的地址 |
| 代理 B | **Proxy** | 用户认的地址；fallback 里 `delegatecall` 到 implementation |
| 升级版 C | **Implementation V2** | 新部署；Proxy 内指针 A → C |

**纠正一句：** 不是「把 A 放进 B」，而是 B **delegatecall** A 的代码；**数据在 Proxy（B）**，不在 A/C 的 storage。

---

## 3. 升级要注意的三件事

1. **Storage Layout**：V2 不能改 V1 已有变量顺序/类型，只能 **末尾追加**；乱序 → **升级后运行** slot 对错（不是 V2 deploy 失败）。
2. **初始化**：用 `initializer` / `upgradeToAndCall`，不要指望用户调 Proxy 时再跑 `constructor`。
3. **权限**：UUPS 里 `_authorizeUpgrade`，防任意升级。

---

## 4. Transparent vs UUPS

| | Transparent | UUPS（Day 13–14） |
|--|-------------|-------------------|
| 升级写在哪 | Proxy **Admin** | **Implementation** |
| Admin 调 Proxy | 走 Proxy 管理函数，**不** delegatecall | 仍调 Proxy，delegatecall 进实现的升级函数 |
| 用户调 Proxy | delegatecall 到 Implementation | 同上 |
| 目的之一 | 避免 Admin 与实现的 **selector 冲突** | Proxy 更薄；升级逻辑在实现里 |

---

## 5. 自测三题（我的口播）

**Q1 地址不变：** 用户用的是 Proxy；升级只换 implementation 指针，Proxy 地址和 storage 不变。

**Q2 不能乱序 slot：** Proxy 里已按 V1 布局存数据；V2 对调变量会读错 slot，升级成功后逻辑就错。

**Q3 UUPS vs Transparent：** UUPS 升级在 Implementation，调 Proxy delegatecall 改 ERC1967 指针；Transparent 由 Proxy Admin 改指针，用户才 delegatecall。

---

## 6. `perpetual-contract` 里的 Proxy（Clone）

- **Dealer / Perpetual**：`new` 部署，**不是** UUPS。
- **SubaccountFactory**：OZ `Clones.clone(template)` → [EIP-1167](https://eips.ethereum.org/EIPS/eip-1167) 最小代理。
- 每个子账户 **独立地址 + 独立 storage**；逻辑共用 template；`init(owner)` 代替 constructor。
- 与 Counter UUPS：**同是 delegatecall**；Clone 为 **省 gas、多实例**，UUPS 为 **同地址升级**。

详见知识库 [§7](https://worserole.github.io/web3-learning-docs/foundry/阶段2-Day11-Proxy原理.html)。

---

## 7. 30 秒极简版

Proxy + delegatecall：代码在 Implementation，状态在 Proxy。升级换 implementation 地址，布局必须兼容。我们用 UUPS；Transparent 是 Admin 在 Proxy 层升级。

---

## Day 11 Checklist

- [x] 读知识地图 01 Proxy / delegatecall / Storage Layout
- [x] 读 `perpetual-contract` Subaccount Clone（§6）
- [ ] 可选：OZ Upgradeable 文档（Day 13）
- [x] 三题口播过关

**当前：** Day 12 → 写 `CounterV1` / `CounterV2`。
