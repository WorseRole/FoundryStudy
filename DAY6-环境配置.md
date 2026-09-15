# Day 6 — Sepolia 环境配置

> 阶段 1 第一步：RPC + 钱包 + `.env`，**今天不上链**（上链是 Day 7）。  
> **状态（2026-09-15）**：✅ 验收已通过（`forge script ... --rpc-url sepolia` 模拟成功）。

---

## 0. 三个 `.env` 变量：各干什么、Foundry 怎么用

| 变量 | 典型来源 | 一句话 |
|------|----------|--------|
| `SEPOLIA_RPC_URL` | **Alchemy**（或 Infura）App 的 HTTPS 地址 | **连 Sepolia 链的「电话线」**：查余额、估 gas、**广播已签名的交易** |
| `PRIVATE_KEY` | **MetaMask 测试账户**导出的私钥（带 `0x`） | **谁出钱、谁签名**：本地用私钥签名，**不把私钥发给 Alchemy/Etherscan** |
| `ETHERSCAN_API_KEY` | [etherscan.io/myapikey](https://etherscan.io/myapikey) | **Day 7 `--verify` 专用**：把源码提交给 Etherscan **做合约验证**；日常在网页查交易**不需要**这个 Key |

### 你的理解对不对？

- **私钥 ↔ 钱包**：对。和 MetaMask 里**同一个测试账户**对应；MetaMask 是界面，Foundry 在终端里用私钥直接签名。  
- **Etherscan Key ↔ 验证合约**：对。浏览器打开 [sepolia.etherscan.io](https://sepolia.etherscan.io) 查交易是免费的；API Key 是给 **程序**（Foundry）调 Etherscan 接口上传源码、在页面上显示「Verified Contract」。  
- **Alchemy**：不是浏览器，也不是钱包。它是 **Sepolia 上的节点服务商**；你给的 URL 让 `forge` / `cast` 和真实 Sepolia 网络对话。

### 数据怎么走（Day 6 模拟 vs Day 7 真部署）

```
┌─────────────┐     HTTPS JSON-RPC      ┌──────────────┐
│ forge/cast  │ ───────────────────────►│ Alchemy 节点 │──► Sepolia 链
└─────────────┘   (读链上状态、估 gas、     └──────────────┘
       │           Day7 广播 signed tx)
       │ 本地读 .env
       ├─ SEPOLIA_RPC_URL  → foundry.toml [rpc_endpoints] sepolia
       ├─ PRIVATE_KEY      → script 里 vm.envUint("PRIVATE_KEY") 签名
       └─ ETHERSCAN_API_KEY → 仅 --verify 时 foundry.toml [etherscan] sepolia

Day 6：--rpc-url sepolia，不加 --broadcast → 用 RPC 估 gas，在本地/simulate 跑脚本，不上链。
Day 7：加 --broadcast → 用私钥签名 → 通过 Alchemy 把交易打进 Sepolia。
       加 --verify   → Foundry 再带 ETHERSCAN_API_KEY 调 API 提交源码。
```

### 在仓库里「谁读取」

1. **Foundry 启动**（在 FoundryStudy 根目录）：自动加载 **`.env`** 到环境变量。  
2. **`foundry.toml`**  
   - `[rpc_endpoints] sepolia = "${SEPOLIA_RPC_URL}"` → 命令行写 `--rpc-url sepolia` 时用 Alchemy URL。  
   - `[etherscan] sepolia = { key = "${ETHERSCAN_API_KEY}" }` → 仅 `--verify` 时用。  
3. **`script/Counter.s.sol`**  
   - `vm.envUint("PRIVATE_KEY")` → 从环境变量读私钥，用于 `vm.startBroadcast(deployerPrivateKey)`。

MetaMask 里 Sepolia 网络的 RPC **可以填和 `.env` 相同的 Alchemy URL**，这样浏览器和 Foundry 连的是同一套链；**私钥只写在 `.env` 给 Foundry 用**，不要写进 Git。

> 📝 **串讲自测（3 句）**：RPC 是链的入口；私钥只在本地签名；Etherscan API Key 是部署后自动验证源码，不是查交易用的。

---

## 1. Sepolia RPC（Alchemy 示例）

1. 打开 [Alchemy](https://www.alchemy.com/) 注册 / 登录  
2. **Create App** → Chain 选 **Ethereum**，Network 选 **Sepolia**  
3. 进入 App → **API Key** → 复制 **HTTPS** URL，形如：  
   `https://eth-sepolia.g.alchemy.com/v2/xxxxxxxx`

（Infura 同理：项目 → Sepolia → 复制 HTTPS URL。）

---

## 2. MetaMask + Sepolia 网络

1. 安装 [MetaMask](https://metamask.io/) 浏览器扩展  
2. 创建或导入钱包（**建议单独一个仅用于测试的账户**）  
3. 添加 Sepolia：  
   - 网络名称：`Sepolia`  
   - RPC URL：与上面 Alchemy URL 相同即可  
   - Chain ID：`11155111`  
   - 符号：`ETH`  
   - 区块浏览器：`https://sepolia.etherscan.io`

---

## 3. 领 Sepolia ETH

任选其一（有时需 Google / GitHub 登录）：

- [Google Cloud Sepolia Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)  
- [Alchemy Sepolia Faucet](https://www.alchemy.com/faucets/ethereum-sepolia)

目标：MetaMask 里 Sepolia 余额 **≥ 0.05 ETH**（部署 Counter 足够）。

---

## 4. Etherscan API Key（Day 7 `--verify` 要用）

1. [etherscan.io](https://etherscan.io/) 注册  
2. [My API Keys](https://etherscan.io/myapikey) → Add → 复制 Key  

（Sepolia 验证走同一套 API Key。）

---

## 5. 本地 `.env`

在 **FoundryStudy 根目录**：

```bash
cp .env.example .env
```

编辑 `.env`（三行都要填）：

```bash
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/你的key
PRIVATE_KEY=0x你的测试账户私钥
ETHERSCAN_API_KEY=你的etherscan_key
```

**私钥怎么拿（仅测试账户）**

MetaMask → 账户详情 → 显示私钥 → 复制，前面保留 `0x`。

⚠️ **不要**把主网有钱包的私钥写进 `.env`；`.env` 已在 `.gitignore`，**不要 commit**。

---

## 6. 验收命令（Day 6 完成标准）

在项目根目录：

```bash
# 1）阶段 0 仍全绿
forge test

# 2）用 Sepolia RPC 模拟部署脚本（不广播、不花 gas）
forge script script/Counter.s.sol --rpc-url sepolia -vvv
```

第二条应看到类似：

```text
Counter deployed at: 0x...
Script ran successfully.
```

若报错 `environment variable "PRIVATE_KEY" not found`，说明 `.env` 未建或路径不对。

可选：看 Sepolia 余额（需已填写 `.env`，Foundry 会自动加载）：

```bash
cast balance $(cast wallet address --private-key "$PRIVATE_KEY") --rpc-url sepolia
```

---

## 7. Day 7 预告（明天再做）

真部署 + Etherscan 验证：

```bash
forge script script/Counter.s.sol \
  --rpc-url sepolia \
  --broadcast \
  --verify \
  -vvvv
```

把输出的合约地址填进 README「部署记录」表。

---

## 勾选（README）

- [x] RPC URL  
- [x] MetaMask Sepolia + 有余额  
- [x] `.env` 三变量（`PRIVATE_KEY` 须带 `0x` 前缀）  
- [x] `forge script ... --rpc-url sepolia` 模拟成功（2026-09-15）  
