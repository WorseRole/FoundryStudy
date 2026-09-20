# FoundryStudy — 合约实操恢复计划

> 从「理论慌、手感丢」到「能写、能测、能部署、能升级、能投简历」
>
> 开始日期：2026-09-08 · 预计投简历：约 4 周后

---

## 进度一览

| 阶段 | 内容 | 天数 | 状态 |
|------|------|------|------|
| 0 | Foundry 热身 | Day 1-5 | ✅ 完成 |
| 1 | Sepolia 部署 | Day 6-10 | ✅ 完成 |
| 2 | 合约升级 Proxy | Day 11-15 | 🔄 Day 14 ✅ |
| 3 | 项目深入（永续 + Kinza） | Day 16-21 | ⬜ 未开始 |
| 4 | 面试准备 | Day 22-26 | ⬜ 未开始 |
| 5 | 简历定稿 + 投递 | Day 27-30 | ⬜ 未开始 |

**当前位置：阶段 2 · Day 15**（Day 14 Sepolia 升级 ✅ · **34 tests passed**）

---

## 阶段 0：Foundry 热身（Day 1-5）

> 目标：找回写合约 + 写测试的手感，不部署。

### Day 1 — Counter 基础 ✅

- [x] `forge test` 跑通（9 passed）
- [x] 理解 `src/` / `test/` / `script/` 目录
- [x] 新增 `decrement()` + `require` 防下溢
- [x] 写正常测试 + revert 测试
- [x] CounterTest：**4 passed**

**学到：** Storage、`setUp()`、`assertEq`、`testFuzz`、Solidity 0.8 算术下溢 panic

---

### Day 2 — Ownable 权限 ✅

- [x] 新建 `src/Ownable.sol`
- [x] `Counter is Ownable`，`setNumber` 加 `onlyOwner`
- [x] `vm.prank` + `vm.expectRevert("not owner")`
- [x] CounterTest：**6 passed**

**学到：** 权限控制、`modifier`、继承、`msg.sender`

---

### Day 3 — Vault 存取 ETH ✅

- [x] 新建 `src/Vault.sol`（`deposit` / `withdraw`）
- [x] 新建 `test/Vault.t.sol`
- [x] 使用 `vm.deal`、`deposit{value:}`、`call{value:}`
- [x] 理解 CEI：先改 `balances`，再转 ETH
- [x] VaultTest：**5 passed**，全项目 **18 passed**

**学到：**
- `payable` + `msg.value`：合约通过 `deposit()` 收 ETH，并记入 `balances[msg.sender]`
- `vm.deal`：测试里给地址「发 ETH」；`deposit{value:}`：调用时附带 ETH
- `call{value: amount}("")`：向用户转 ETH，比 `transfer` 更灵活（gas 上限、兼容合约地址）
- **CEI 模式**：Checks（校验）→ Effects（先改 `balances`）→ Interactions（再 `call` 转 ETH）
- `expectRevert` 字符串必须和 `require` 文案**完全一致**（大小写、空格都要对）

**对应笔记：** 知识地图 03 重入攻击 · Kinza `supply/withdraw` 简化版

---

### Day 4 — 重入攻击演示 ✅

- [x] 新建 `src/Attacker.sol`（恶意合约，在 receive 里再次 withdraw）
- [x] 写一个 **不安全版** `VaultVunlnerable.sol`（先转 ETH 再改 balance）
- [x] 测试：攻击者能 drain 合约（`ReentrancyTest` 2 passed）
- [x] 对比安全版 Vault（CEI）攻击失败
- [ ] 可选：加 `ReentrancyGuard`

**学到：**
- **重入不是异步**：`call` 期间外层 `withdraw` 暂停，Attacker `receive` 里再进 `withdraw`，同一笔交易、同一调用栈
- 不安全 Vault：嵌套 `withdraw` 时 `balances` 仍是旧值，可多次 `require` 通过并转 ETH
- **unwind**：最里层 `call` 返回后先改账；多层 `-=` 会 **0x11 underflow** → 整笔 revert（可用 `call` 后 `if (balances < amount) return` 避免演示被 revert 打断）
- `receive` 里用 `vault.balance >= 1 ether`（不是 `>`），否则池里剩最后 1 ether 时不再提
- 安全 Vault（CEI）：`receive` 里读到 `balances == 0`，重入打不穿

**对应笔记：** 知识地图 03 重入 · CEI

---

### Day 5 — 阶段复盘 ✅

- [x] `forge test` 全绿，记录总测试数（**20 passed**，4 suites）
- [x] `forge fmt` 格式化代码
- [x] 口头讲一遍：Counter → Ownable → Vault → 重入（见下方「阶段 0 串讲」）
- [x] Day 1-5 笔记写入 README

**阶段 0 完成标准：** 能独立写合约 + 测试 + 解释 revert 原因 ✅

#### 阶段 0 串讲（面试/自测用）

| Day | 合约 | 核心点 | 测试习惯 |
|-----|------|--------|----------|
| 1 | Counter | storage、`increment/decrement`、`require` 防下溢 | `assertEq`、`testFuzz`、`expectRevert` |
| 2 | Ownable + Counter | 继承、`onlyOwner`、`msg.sender` | `vm.prank` 换调用者 |
| 3 | Vault | `payable`、`msg.value`、`call{value:}`、**CEI** | `vm.deal`、`deposit{value:}` |
| 4 | VaultVunlnerable + Attacker | 先 call 后改账 → 重入；同步调用栈、unwind | 对比安全 Vault 同一攻击失败 |

**一句话：** 状态先改再对外 call（CEI），否则带 `receive` 的合约能在你的函数返回前再次进入你。

---

## 阶段 1：Sepolia 部署（Day 6-10）

> 目标：合约真正上链，Etherscan 可查。

### Day 6 — 环境配置 ✅

> **逐步说明 + 三变量原理**：[`DAY6-环境配置.md`](DAY6-环境配置.md)

- [x] 注册 [Alchemy](https://www.alchemy.com/) 或 Infura，拿 Sepolia RPC URL → `.env` 的 `SEPOLIA_RPC_URL`
- [x] 安装 [MetaMask](https://metamask.io/)，添加 Sepolia 网络（Chain ID `11155111`）
- [x] 领 Sepolia ETH（水龙头）
- [x] `cp .env.example .env` 并填写三变量（**不要 commit** `.env`）
- [x] `.gitignore` 已忽略 `.env`
- [x] **验收**：`forge test` 20 passed + `forge script script/Counter.s.sol --rpc-url sepolia -vvv` 模拟成功（2026-09-15）

仓库已配置：`foundry.toml`（`sepolia` RPC / Etherscan）、`script/Counter.s.sol`（读 `PRIVATE_KEY` 并 `console.log` 地址）。

---

### Day 7 — 部署 Counter ✅

- [x] 完善 `script/Counter.s.sol`（`startBroadcast` / `new Counter` / `console.log`）
- [x] 本地模拟：`forge script script/Counter.s.sol --rpc-url sepolia`
- [x] 真部署 + 验证：`--broadcast --verify`（2026-09-16）
- [x] 合约地址见下方「部署记录」· Etherscan **Verified**

---

### Day 8 — 部署 Vault ✅

- [x] 写 `script/Vault.s.sol`
- [x] 部署 Vault 到 Sepolia（2026-09-16 · `0x605e…3D32`）
- [x] 链上 `deposit()` + `cast call` 读 `balances`（私钥签名经 RPC 发交易，Etherscan 可查 tx 记录）
- [x] Counter 加练：`cast send` → `increment()`，Read / `cast call` 读 `number`

---

### Day 9 — 部署脚本 + 文档 ✅

- [x] 整理 deploy 流程 → [`DEPLOY-流程.md`](DEPLOY-流程.md)
- [x] 「部署记录」表格（Counter / Vault · Sepolia · 2026-09-16）
- [x] 流程要点：合约 + test → script（`console.log` 地址）→ 模拟 → `--broadcast --verify`
- [ ] （可选）`DeployAll.s.sol` 仅本地模拟
- [ ] 口头串讲 1 分钟（自练）

---

### Day 10 — 阶段复盘 ✅

> 串讲定稿：[阶段1-串讲.md](./阶段1-串讲.md)（知识库 [同名页](https://worserole.github.io/web3-learning-docs/foundry/阶段1-串讲.html)）  
> 链上命令：[Forge/Cast 链上命令](https://worserole.github.io/web3-learning-docs/foundry/forge-cast-链上命令.html)

- [x] Counter / Vault Sepolia 可查、可交互（部署记录 + `cast`）
- [x] 对照知识地图 01 §9–15（calldata、nonce、gas、生命周期）
- [x] 串讲稿已写入 `阶段1-串讲.md`（含 30 秒极简版）
- [x] 不要求 Etherscan 截图

**阶段 1 完成标准：** testnet 部署 + 验证 + 交易全链路串讲 ✅

---

## 阶段 2：合约升级 Proxy（Day 11-15）

> 目标：UUPS Proxy，V1 → V2 升级，storage 不丢。

### Day 11 — 读 Proxy 原理 ✅

> 总结：[阶段2-Day11-Proxy原理.md](./阶段2-Day11-Proxy原理.md) · [知识库](https://worserole.github.io/web3-learning-docs/foundry/阶段2-Day11-Proxy原理.html)

- [x] 读知识地图 01「Proxy / delegatecall / Storage Layout」
- [x] 读 `perpetual-contract` 子账户 **EIP-1167 Clone**（非 Dealer UUPS；见阶段2-Day11 §6–7）
- [x] 理解：逻辑合约可换，storage 在 Proxy 里不变；UUPS vs Transparent 口播三题

---

### Day 12 — 写 V1 / V2 ✅

> 总结：[阶段2-Day12-CounterV1V2.md](./阶段2-Day12-CounterV1V2.md) · [知识库](https://worserole.github.io/web3-learning-docs/foundry/阶段2-Day12-CounterV1V2.html)

- [x] `CounterV1.sol`：现有 Counter 逻辑
- [x] `CounterV2.sol`：`reset()` + `version()`（`"2"`）
- [x] **Storage Layout 不变**（`owner` slot0、`number` slot1）
- [x] `test/CounterUpgrade.t.sol`（assert + revert）· 全仓 **30 tests**

---

### Day 13 — 部署 Proxy ✅

- [x] OpenZeppelin + `openzeppelin-contracts-upgradeable`（`.gitmodules` / `remappings.txt`）
- [x] `CounterUpgradeableV1` + `ERC1967Proxy` + `initialize`
- [x] `test/CounterUpgradeableProxyTest.t.sol` · `script/CounterUpgradeable.s.sol`
- [x] Sepolia `--broadcast`：Proxy + V1 impl（见部署记录 · 2026-09-20）

---

### Day 14 — 执行升级 ✅

- [x] `CounterUpgradeableV2` + `initializeV2` / `bump`
- [x] `test/CounterUpgradeableProxyTest2.t.sol`（upgradeToAndCall + bump）
- [x] `script/CounterUpgradeV2.s.sol` · Sepolia 升级（V2 impl · 见部署记录）
- [x] 链上：`number` 仍为 2，`bump=100`，`version=2`

---

### Day 15 — 阶段复盘 ⬜

- [ ] 写测试：fork 或本地测 upgrade 流程
- [ ] 理解升级风险：Storage 冲突、权限、初始化（知识地图 03）
- [ ] 记录 Proxy 地址 + V1/V2 实现地址

**阶段 2 完成标准：** 能讲清 delegatecall、Proxy、升级注意事项

---

## 阶段 3：项目深入（Day 16-21）

> 目标：把 Foundry 手感接到真实项目上，为简历和面试做准备。

### Day 16-17 — MetaNode 永续合约 ⬜

- [ ] 读 `docs/projects/metanode-perpetual.md`（知识库）
- [ ] 读 `perpetual-new-contract/src/libraries/Trading.sol`
- [ ] 读 `Liquidation.sol` + `Perpetual.sol` 的 `_settle`
- [ ] 练 1 遍 CEX.md 5 层讲解（录音或写下来）
- [ ] 可选：补 1 个 `testTradeSettlement` Foundry 测试

**负责模块（简历用）：** Trading / Liquidation / Funding / perpetual-go

---

### Day 18-19 — KinzaFinance 借贷 ⬜

- [ ] 读 `docs/projects/kinza-lending.md`（知识库）
- [ ] 读 `项目文档/KinzaFinance 完整借贷流程.md`
- [ ] 读 `GenericLogic.calculateUserAccountData()`（HF 计算）
- [ ] 读 `LiquidationLogic.executeLiquidationCall()`
- [ ] 背 3 题：scaled balance / 清算条件 / LTV vs 清算阈值

**负责模块（简历用）：** LiquidationLogic / GenericLogic / SupplyLogic / BorrowLogic

---

### Day 20 — Fork Test ⬜

- [ ] 写 1 个 fork test：fork BSC mainnet，读 Kinza Pool 状态
- [ ] 或：fork Sepolia，测自己的 Vault
- [ ] 理解：`vm.createSelectFork`、`deal`、`prank` 在 fork 里的用法

---

### Day 21 — 阶段复盘 ⬜

- [ ] 对比：永续清算 vs Kinza 清算（异同表）
- [ ] 更新知识库 `docs/projects/` 如有新理解
- [ ] 能 15 分钟白板：Lending + Liquidation 系统设计

**阶段 3 完成标准：** 两个项目都能讲 15 分钟，有 fork test 产出

---

## 阶段 4：面试准备（Day 22-26）

### Day 22-23 — 系统设计 ⬜

- [ ] 准备白板题 1：设计 Lending + Liquidation（Kinza）
- [ ] 准备白板题 2：设计链下撮合 + 链上结算 Perp（MetaNode）
- [ ] 每个能画架构图 + 讲核心流程 + 说 3 个风险点

---

### Day 24-25 — Mock Interview ⬜

- [ ] 永续 5 题：delegatecall / `_settle` 公式 / EIP-712 / MM 清算 / fundingRate
- [ ] Kinza 5 题：HF / scaled balance / liquidationCall / Close Factor / Oracle
- [ ] 安全 5 题：重入 / CEI / 精度 / Oracle 操纵 / 升级风险
- [ ] 各练 1 小时，录音回听

---

### Day 26 — 笔记总复习 ⬜

- [ ] 知识地图 01-04 各过一遍标题 + 核心公式
- [ ] `forge test` 全绿，部署地址整理完毕
- [ ] 列出还模糊的 5 个点，逐个查完

---

## 阶段 5：简历定稿 + 投递（Day 27-30）

### Day 27 — 简历 ⬜

- [ ] 项目一：MetaNode 永续（合约 + Go 后端）
- [ ] 项目二：KinzaFinance 借贷（清算 + HF + 借贷流程）
- [ ] 技能栈：Solidity / Foundry / Hardhat / Go / EIP-712 / Chainlink
- [ ] GitHub 置顶：web3-learning-docs + FoundryStudy + perpetual-new-contract

**简历项目描述见：** `web3-learning-docs/docs/projects/`

---

### Day 28 — 材料检查 ⬜

- [ ] 知识库在线：https://worserole.github.io/web3-learning-docs/
- [ ] Sepolia 合约 Etherscan 链接可打开
- [ ] GitHub Profile 有 README
- [ ] 简历 PDF 导出

---

### Day 29-30 — 投递 ⬜

- [ ] DeFi 协议：Aave / Compound / GMX / dYdX 等（每天 3-5 家）
- [ ] CEX：OKX / Bybit / Binance 等（每天 2-3 家）
- [ ] 审计：CertiK / OpenZeppelin 等（每天 1-2 家）
- [ ] 记录投递表格：公司 / 岗位 / 日期 / 状态

---

## 部署记录

| 合约 | 网络 | 地址 | 部署日期 |
|------|------|------|----------|
| Counter | Sepolia | [0x00E60d96e3ccbe461700bEF3FC2B8b61EfAd2A1c](https://sepolia.etherscan.io/address/0x00E60d96e3ccbe461700bEF3FC2B8b61EfAd2A1c) | 2026-09-16 |
| Vault | Sepolia | [0x605edB790b07dA3809E61ba24fbd4a29b9ad3D32](https://sepolia.etherscan.io/address/0x605edB790b07dA3809E61ba24fbd4a29b9ad3D32) | 2026-09-16 |
| CounterProxy（UUPS 门面） | Sepolia | [0x901D9F0d66db49226476372e1B63684bFEbE4F73](https://sepolia.etherscan.io/address/0x901D9F0d66db49226476372e1B63684bFEbE4F73) | 2026-09-20 |
| CounterUpgradeable V1（impl） | Sepolia | [0xC2fB0cB014D76fF0beDFE4CfaB8Aafba77036550](https://sepolia.etherscan.io/address/0xC2fB0cB014D76fF0beDFE4CfaB8Aafba77036550) | 2026-09-20 |
| CounterUpgradeable V2（impl） | Sepolia | [0x22b7144CFd9D2A7e5936EB8418C2c33cf6dd6AC1](https://sepolia.etherscan.io/address/0x22b7144CFd9D2A7e5936EB8418C2c33cf6dd6AC1) | 2026-09-20 |

---

## 每日记录

> 每天花 2 分钟写一行，换电脑也能接上进度。

| 日期 | Day | 做了什么 | 测试数 |
|------|-----|----------|--------|
| 2026-09-08 | 1 | Counter decrement + require + revert 测试 | 4 passed |
| 2026-09-08 | 2 | Ownable + onlyOwner + prank 测试 | 6 passed |
| 2026-09-10 | 3 | Vault deposit/withdraw + CEI；练 vm.deal / prank / call{value:} | Vault 5 / 全仓 18 |
| 2026-09-12 | 4 | VaultVunlnerable + Attacker + ReentrancyTest；调用栈 / unwind | Reentrancy 2 / 全仓 20 |
| 2026-09-12 | 5 | 阶段 0 复盘；forge fmt；20 tests 全绿 | 20 passed |
| 2026-09-15 | 6 | Alchemy RPC + MetaMask + `.env` 三变量；Sepolia 模拟部署脚本通过 | 20 passed |
| 2026-09-16 | 7 | Counter Sepolia 部署 + Etherscan verify；tx `0xfc14…6cef` | 20 passed |
| 2026-09-16 | 8 | Vault 部署 verify + `cast send` deposit / 读 balances；Counter increment 链上调用 | 20 passed |
| 2026-09-16 | 9–10 | DEPLOY-流程 + 阶段1-串讲（知识地图 01 §9–15） | 20 passed |
| 2026-09-16 | 11 | Proxy / delegatecall / layout；UUPS vs Transparent；阶段2-Day11 总结 | 20 passed |
| 2026-09-17 | 12 | CounterV1/V2 + CounterUpgrade 测试补全 | 30 passed |
| 2026-09-18 | 13 | OZ UUPS + ERC1967Proxy + CounterUpgradeableV1 / 测试 / 部署脚本 | 32 passed |
| 2026-09-20 | 14 | V2 + upgrade 测试；Sepolia Proxy 升级 V2（bump/initV2） | 34 passed |

---

## 阶段 2 · Day 11（摘要）

完整稿：[阶段2-Day11-Proxy原理.md](./阶段2-Day11-Proxy原理.md)

**30 秒版：** Proxy + delegatecall — 代码在 Implementation，状态在 Proxy；升级换 implementation 指针，布局兼容；计划用 UUPS。

---

## 阶段 2 · Day 12（摘要）

完整稿：[阶段2-Day12-CounterV1V2.md](./阶段2-Day12-CounterV1V2.md)

**30 秒版：** V1 复制 Counter；V2 同 layout 加 `reset`/`version`；`CounterUpgrade` 测数值与 revert；链上同址保 state 留 Day 13–14。

---

## 阶段 1 串讲（摘要）

完整稿：[阶段1-串讲.md](./阶段1-串讲.md)

**30 秒版：** Foundry 在 Sepolia 部署 Counter/Vault（`forge script --broadcast --verify`），`cast send` 调 `increment`、`deposit`、`withdraw`；私钥本地签名 → Alchemy RPC → 节点验 **nonce**/余额/签名 → EVM 执行 **calldata** → 改 Storage（`number`、`balances`）→ 付 **gas**；只读用 **`cast call`**。

---

## Sepolia 发布流程（摘要）

> 完整步骤：[DEPLOY-流程.md](./DEPLOY-流程.md)

1. **`src/` 合约 + `test/`** → `forge test`
2. **`script/Xxx.s.sol`** → `new Xxx()` + **`console.log` 合约地址**
3. 模拟：`forge script script/Xxx.s.sol --rpc-url sepolia -vvv`
4. 上链：`forge script script/Xxx.s.sol --rpc-url sepolia --broadcast --verify -vvvv`

链上读/写见 [知识库 · Forge/Cast 链上命令](https://worserole.github.io/web3-learning-docs/foundry/forge-cast-链上命令.html)。

## 常用命令

```bash
# 测试
forge test
forge test --match-contract VaultTest -vv
forge fmt

# 部署示例（见 DEPLOY-流程.md）
forge script script/Counter.s.sol --rpc-url sepolia --broadcast --verify -vvvv
forge script script/Vault.s.sol --rpc-url sepolia --broadcast --verify -vvvv

# 本地节点
anvil
```

---

## 相关链接

- [Foundry Book](https://book.getfoundry.sh/)
- [知识库](https://worserole.github.io/web3-learning-docs/)
- [MetaNode 项目文档](https://worserole.github.io/web3-learning-docs/projects/metanode-perpetual)
- [Kinza 项目文档](https://worserole.github.io/web3-learning-docs/projects/kinza-lending)

---

## 原始 Foundry 说明

<details>
<summary>点击展开 forge / cast / anvil 基础命令</summary>

```shell
forge build
forge test
forge fmt
forge snapshot
anvil
cast <subcommand>
forge --help
```

</details>
