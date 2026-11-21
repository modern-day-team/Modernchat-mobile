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
flutter build apk --release             # Android 安装包
flutter build ios --release             # iOS（需在 macOS 上执行）
```

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
- 技术选型：Riverpod（状态管理 + 依赖注入）、go_router（路由）、dio（网络）、shared_preferences（本地存储）

## API 对接

接口契约来自服务端 `docs/API文档.md`：https://github.com/modern-day-team/modern-chat-new/blob/main/docs/API%E6%96%87%E6%A1%A3.md

- REST base URL 与 WS 地址集中在 `lib/core/network/network_config.dart`，默认指向 Android 模拟器的 `10.0.2.2:8080`，真机/生产部署需替换。
- 认证：登录/注册返回 `{token, user}`，token 存本地并在每次请求注入 `Authorization: Bearer <token>`；启动用 `/api/me` 恢复会话。
- 领域模型位于 `lib/core/model/`，字段与 API §13 对齐，JSON 解析统一走 `json_helpers.dart` 兼容数字/字符串 ID。
- 实时消息：`WsClient` 实现 `/ws?token=` 握手、25 秒心跳及 8 种上行帧；`message`/`recall`/`message_update` 等下行帧在 `chat_providers.dart` 就地更新状态，消息发送使用 clientMsgId 乐观消息。
- 范围：当前已覆盖认证、会话列表、消息收发、联系人/好友申请、设置与退出；群管理、文件上传、搜索消息详情、管理后台等接口尚未做 UI。

## 相关项目

- ModernChat 服务端与 Web 端：https://github.com/modern-day-team/modern-chat-new
