# 更新日志

## [未发布]

- fix(android)：移除 Flutter 脚手架 TODO 与 debug key 签名兜底；release 默认未签名，提供本地 `android/key.properties` 时才使用正式签名，避免 release 包携带 debug 签名
- docs(审计整改)：补 `.gitattributes`（仓库强制 LF，与项目组其余仓库一致）；新增本 CHANGELOG，补齐版本变更记录

## 1.0.0+1

- Feature-First 三层架构骨架（auth / chat / contacts / settings），DI 组合根隔离 data 实现
- 认证：登录 / 注册分段式品牌页，token 存 `flutter_secure_storage`（Android Keystore / iOS Keychain），旧明文令牌一次性迁移并删除
- 扫码确认桌面端登录（票据扫描 + 确认接口 + 设置入口）
- 适配主仓库多端能力：客户端标识、WS query、`kicked` 帧、版本协商
- 设计令牌与移动端交互：品牌蓝、7 档字号、分段控件、吸顶分组、底部导航
- CI：`flutter analyze` + `flutter test` + Android/iOS 构建工作流
