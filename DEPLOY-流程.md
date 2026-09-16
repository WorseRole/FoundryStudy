# Sepolia 链上发布流程

> Day 9 定稿 · 环境见 [DAY6-环境配置.md](./DAY6-环境配置.md) · 调合约见 [知识库 · Forge/Cast 链上命令](https://worserole.github.io/web3-learning-docs/foundry/forge-cast-链上命令.html)

---

## 1. 写合约并本地测通

1. 在 **`src/`** 编写合约（如 `Counter.sol`、`Vault.sol`）。
2. 在 **`test/`** 编写测试。
3. 根目录执行 **`forge test`**，全绿后再上链。

---

## 2. 写部署脚本 `script/`

1. 新建 `script/Xxx.s.sol`，**继承 `forge-std` 的 `Script`**。
2. 在 **`run()`** 中（与 Counter / Vault 脚本同结构）：
   - 从 `.env` 读取 **`PRIVATE_KEY`**（`vm.envUint`）；
   - **`vm.startBroadcast(私钥)`**；
   - **`new Xxx()`** 部署；
   - **`console.log("Xxx deployed at:", address(xxx))`** 打印链上地址；
   - **`vm.stopBroadcast()`**。

---

## 3. 模拟（建议，不上链、不花 gas）

在项目根目录（Foundry 自动读 `.env`）：

```bash
forge script script/Xxx.s.sol --rpc-url sepolia -vvv
```

**不要**加 `--broadcast`。确认日志中有 `deployed at: 0x...` 且 `Script ran successfully`。

---

## 4. 真部署到 Sepolia

```bash
forge script script/Xxx.s.sol --rpc-url sepolia --broadcast --verify -vvvv
```

| 参数 | 作用 |
|------|------|
| `--rpc-url sepolia` | 使用 `foundry.toml` + `.env` 中的 Sepolia RPC |
| `--broadcast` | 签名并广播交易，**真正上链** |
| `--verify` | 向 Etherscan 提交源码验证（需 `ETHERSCAN_API_KEY`） |
| `-vvvv` | 详细日志 |

成功后以终端 **`== Logs ==`** 里的地址为准，写入 README **「部署记录」**，并在 [sepolia.etherscan.io](https://sepolia.etherscan.io) 核对。

---

## 5. 部署之后（可选，非 forge script）

对**已部署**的合约读/写，用 **`cast`**（见知识库链上命令备忘）：

- **读**：`cast call ...`（不上链）
- **写**：`cast send ...`（要 gas + 私钥）

---

## 本仓库已部署（Sepolia）

| 合约 | 地址 |
|------|------|
| Counter | [0x00E60d96e3ccbe461700bEF3FC2B8b61EfAd2A1c](https://sepolia.etherscan.io/address/0x00E60d96e3ccbe461700bEF3FC2B8b61EfAd2A1c) |
| Vault | [0x605edB790b07dA3809E61ba24fbd4a29b9ad3D32](https://sepolia.etherscan.io/address/0x605edB790b07dA3809E61ba24fbd4a29b9ad3D32) |
