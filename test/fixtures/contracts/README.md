# contracts — 主仓库契约金样本同步副本

本目录的 `ws_frames.json` 是主仓库（Modernchat-new）`contracts/ws-frames.json` 的**同步副本**，供 `test/contract_frames_test.dart` 直接消费，断言移动端 WS 帧解析口径与主仓库一致。

- **禁止直接修改本副本**：改契约一律先改主仓库（`docs/后端需求规格.md` → 金样本 → `proto.ts`），再复制过来；
- `ws_frames.sha256` 是副本按 LF 归一化的 SHA-256 指纹，CI 用 `tr -d '\r'` + `sha256sum` 校验副本未被本地手改——改副本不改指纹会挂 CI；
- 同步步骤：复制主仓库 `contracts/ws-frames.json` 到本目录并重命名 `ws_frames.json` → 重算指纹（内容按 LF 归一化后取哈希）→ 提交。

契约总览与跨端能力矩阵见主仓库 `docs/项目组架构与集成.md`。
