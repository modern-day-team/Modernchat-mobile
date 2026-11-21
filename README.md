# Modernchat-mobile

ModernChat 的 Flutter 移动端工程，当前覆盖 Android / iOS 两个平台。

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

## 相关项目

- ModernChat 服务端与 Web 端：https://github.com/modern-day-team/modern-chat-new
