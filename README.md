# Modernchat-mobile

ModernChat 的移动端工程，当前覆盖 Android / iOS 两个平台。

- 包名：`modernchat_mobile`
- 应用标识前缀：`com.modernchat`
- 许可证：Apache-2.0（见 [LICENSE](LICENSE)）

## 环境要求

- Flutter 3.50.0 stable（Dart 3.14.0）及以上
- 注意：该 SDK 分支已将 `package:flutter/material.dart` 标记为 deprecated，UI 代码统一使用 `package:material_ui/material_ui.dart`

## 快速开始

```powershell
flutter pub get
flutter run
```

常见构建命令：

```powershell
flutter analyze                         # 静态检查
flutter test                            # 运行测试
flutter build apk --release             # Android 通用安装包
flutter build apk --release --split-per-abi  # Android 按 ABI 拆分安装包
flutter build ios --release             # iOS（需在 macOS 上执行）
```

Android release 默认产物为 **unsigned**（CI  artifact 同理，不会用 debug key 签名）。正式发布需在本地 `android/key.properties` 提供 `storeFile` / `storePassword` / `keyAlias` / `keyPassword`；该文件与 keystore 均已被 `.gitignore`，严禁入库。

## 架构

采用 Feature-First + 分层结构，遵循高内聚低耦合：

```text
lib/
├── core/                    # 跨模块基础设施，不含业务逻辑
│   ├── network/             # Dio 客户端、异常映射、Provider
│   ├── storage/             # 本地存储封装与 Provider
│   ├── router/              # go_router 路由配置
│   └── theme/               # 主题与设计令牌
├── features/                # 按业务功能垂直切分
│   ├── auth/                # 登录/注册
│   │   ├── data/            # 数据源、仓储实现、DTO
│   │   ├── domain/          # 实体、仓储抽象、用例
│   │   └── presentation/    # 页面、Provider
│   ├── chat/                # 会话与消息
│   ├── contacts/            # 联系人
│   └── settings/            # 设置
└── main.dart                # 只做依赖注入与路由装配
```

约定：

- `presentation` 只依赖 `domain` 的抽象，不直接引用 `data` 的实现细节
- 模块间不直接 import 内部文件，通过路由或 Provider 通信
- 技术选型：Riverpod（状态管理 + 依赖注入）、go_router（路由）、dio（网络）、shared_preferences（非敏感偏好）+ flutter_secure_storage（访问令牌）
- DI 组合根：`lib/di/repository_providers.dart` 是唯一组装 RepositoryImpl / RemoteDataSource 的地方，presentation 只依赖 domain 抽象。服务地址通过 `--dart-define=MC_API_HOST=... --dart-define=MC_WS_HOST=...` 注入，默认 Android 模拟器 `10.0.2.2:8080`

## UI 与移动端交互

视觉风格模仿 Web 端 `docs/UI设计方案.md` 与本地 HTML 移动原型，统一在 `lib/core/theme/app_tokens.dart`：

- 品牌蓝 `#0052D9`（深色 `#7CB8FF`），品牌色只用于主按钮、选中态、未读等关键位置
- 7 档字号（11/12/13/14/16/20/26）、4 档圆角 + 胶囊（6/10/14/20/999）、4pt 间距节奏
- 120/200/280ms 动效时长与 `ease-out / ease-in-out / spring` 缓动令牌
- 设置页可切换浅色 / 深色 / 跟随系统，使用紧凑的分段控件
- 应用图标源图保存在 `assets/branding/app_icon_source.png`，裁切版 `app_icon.png` 同时用于登录页 / 设置页品牌标识；Android/iOS 启动图标均由该图生成
- 登录与注册合并为同一个分段式品牌页，遵循原型的 104px 品牌标识、大标题和卡片布局
- 主页面使用 26px 大标题；头像为圆角方形；未读徽标用品牌蓝，免打扰会话用灰阶
- 会话列表按「置顶 / 最近」分组并吸顶，好友申请 Tab 显示待处理数量，聊天记录按日期分隔
- 聊天页使用头像 + 名称 + 状态栏，更多操作复用会话上下文面板
- 设置页使用资料卡、主题三选项、账号/关于分组和底部退出登录按钮

移动端交互约定：

- 一级入口固定在底部导航：消息 / 联系人 / 设置；高频动作常驻列表（会话搜索、新建会话、添加好友）
- 上下文操作用底部面板：长按会话可置顶、免打扰、改群名；退出登录、添加好友等也使用底部面板
- 触控目标不小于 44px；输入框自动收键盘；长按会话与页码切换保持状态

性能约定：

- 长列表使用 `ListView.builder` + `ValueKey`，会话项、消息气泡、联系人项用 `RepaintBoundary` 隔离重绘
- 主界面 `IndexedStack` 保留各 tab 状态，避免切页重复请求
- 认证只订阅 `authUserIdProvider`，避免整个 `AuthState` 变化导致聊天页重建
- WS 触发的会话列表刷新做 260ms 节流，避免高频消息导致整表反复请求与重建
- 本地搜索先过滤已加载的好友，不增加额外请求
- 输入框状态用 `ValueListenableBuilder` 局部更新，避免每次按键重建整个页面
- 空态 / 错误态统一由 `core/ui/app_state_view.dart` 提供
- 完整性能策略、约束和验证方式见 [docs/性能优化.md](docs/性能优化.md)

## API 对接

接口契约来自服务端 `docs/后端需求规格.md`（接口字段权威）与 `docs/客户端接入指南.md`（多端登录/令牌/WS/会话/版本协商）：https://github.com/modern-day-team/modern-chat-new/tree/main/docs

- REST base URL 与 WS 地址集中在 `lib/core/network/network_config.dart`，默认指向 Android 模拟器的 `10.0.2.2:8080`，真机/生产部署需替换。
- 认证：登录/注册返回 `{token, user}`，token 存**系统安全存储**（Android Keystore / iOS Keychain，`flutter_secure_storage`）并在每次请求注入 `Authorization: Bearer <token>`；首次启动会把旧版 SharedPreferences 的明文令牌迁移到安全存储并删除旧值。启动用 `/api/me` 恢复会话。
- 领域模型位于 `lib/core/model/`，字段与 API §13 对齐，JSON 解析统一走 `json_helpers.dart` 兼容数字/字符串 ID。
- 实时消息：`WsClient` 实现 `/ws?token=` 握手、25 秒心跳及 8 种上行帧；`message`/`recall`/`message_update` 等下行帧在 `chat_providers.dart` 就地更新状态，消息发送使用 clientMsgId 乐观消息。
- 范围：当前已覆盖认证、会话列表、消息收发、联系人/好友申请、设置与退出；群管理、文件上传、搜索消息详情、管理后台等接口尚未做 UI。

## 相关项目

- ModernChat 服务端与 Web 端：https://github.com/modern-day-team/modern-chat-new
