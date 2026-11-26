# 更新日志

## [未发布]

- feat(契约)：接入主仓库跨端契约金样本——`test/fixtures/contracts/ws_frames.json` 为 Modernchat-new `contracts/` 的同步副本，新增 `test/contract_frames_test.dart` 金样本驱动回归测试（服务端全帧解析为 `WsEvent` 且类型保持、message/reaction/error/kicked 字段逐一核对、上行帧契约键齐全）；CI verify 任务新增指纹校验（LF 归一化 SHA-256），副本被手改而指纹未更新会挂 CI。同步流程见 `test/fixtures/contracts/README.md`，契约总览见主仓库 `docs/项目组架构与集成.md`
- fix(android)：移除 Flutter 脚手架 TODO 与 debug key 签名兜底；release 默认未签名，提供本地 `android/key.properties` 时才使用正式签名，避免 release 包携带 debug 签名
- docs(审计整改)：补 `.gitattributes`（仓库强制 LF，与项目组其余仓库一致）；新增本 CHANGELOG，补齐版本变更记录

## 1.0.0+1

- Feature-First 三层架构骨架（auth / chat / contacts / settings），DI 组合根隔离 data 实现
- 认证：登录 / 注册分段式品牌页，token 存 `flutter_secure_storage`（Android Keystore / iOS Keychain），旧明文令牌一次性迁移并删除
- 扫码确认桌面端登录（票据扫描 + 确认接口 + 设置入口）
- 适配主仓库多端能力：客户端标识、WS query、`kicked` 帧、版本协商
- 设计令牌与移动端交互：品牌蓝、7 档字号、分段控件、吸顶分组、底部导航
- CI：`flutter analyze` + `flutter test` + Android/iOS 构建工作流
