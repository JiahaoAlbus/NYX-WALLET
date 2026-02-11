# Ethereum Foundation ESP 申请材料（草案）

## 项目名称
NYX WALLIET

## 申请类别
Wallet / UX & Security / Developer Tooling

## 项目简介（一句话）
NYX WALLIET 是面向 iOS 17+ 的非托管多链钱包，重点提供以太坊生态的安全交易与风险防护能力（本地密钥、交易模拟、钓鱼检测、费用透明），并以开源方式输出安全与交易构建组件。

## 项目背景与动机
钱包是以太坊用户进入生态的第一入口，但目前多数钱包在移动端安全、交易风险提示、手续费透明以及可复现的开源安全实践上仍有明显缺口。NYX WALLIET 的目标是在 iOS 端提供可发布的安全钱包，并将关键安全与交易模块开源，以提升以太坊生态用户安全体验。

## 目标与产出（面向 ETH 生态）
- 产出 1：开源安全模块（Seed Sharding、风险引擎、交易模拟框架）
- 产出 2：开源 EVM 交易构建与手续费透明展示组件（包含 1.5% 服务费显示规范）
- 产出 3：iOS 端可发布的钱包应用（支持 ETH 主网、EIP-1559、ERC20）
- 产出 4：安全审计报告或第三方评估摘要（开源或公开摘要）

## 核心功能
- ETH 主网与测试网支持（EIP-1559 / ERC20）
- 本地密钥与生物识别解锁（Secure Enclave + Keychain）
- 交易模拟与风险提示（钓鱼检测、异常地址识别、gas 过高提示）
- 费用展示透明（确认页显示服务费）

## 当前进展
- iOS 可运行原型已完成（多链支持）
- EVM/Solana/BTC/TRON 基础交易构建与签名已实现（部分链仍需补齐手续费与交易构建细节）
- 交易风险引擎与钓鱼检测框架已搭建
- 发布文档与上线流程已准备

## 计划与里程碑（6 个月）
详见：`esp/ESP_MILESTONES.md`

## 预算拆解
详见：`esp/ESP_BUDGET.md`

## 开源计划
详见：`esp/ESP_OPEN_SOURCE_PLAN.md`

## 联系方式
- 邮箱：support@nyxwallet.app
- GitHub： https://github.com/JiahaoAlbus/NYX-WALLET
