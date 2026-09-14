# Day 6 — Sepolia 环境配置

> 阶段 1 第一步：RPC + 钱包 + `.env`，**今天不上链**（上链是 Day 7）。  
> 完成后在 README 勾选 Day 6，并跑文末「验收命令」。

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

- [ ] RPC URL  
- [ ] MetaMask Sepolia + 有余额  
- [ ] `.env` 三变量  
- [ ] `forge script ... --rpc-url sepolia` 模拟成功  
