# CyberCode · Doom Emacs 配置

面向 macOS 的个人 Emacs 配置：CyberCode ASCII 启动页、FiraCode 字体、Vim 风格操作、Neotree、右侧终端、C++ / Python / R 开发、Org 和 LaTeX。常用键位按作者的 LazyVim 使用习惯统一。没有邮件模块。

## 一键安装（macOS）

先安装 [Homebrew](https://brew.sh)，并完成 `xcode-select --install`。退出 Emacs 后执行：

```sh
git clone https://github.com/Bayesianovich/emacs-config.git && cd emacs-config && ./install.sh --deps
```

脚本会通过 Homebrew 安装 Emacs、开发工具和 Nerd Font，创建独立 debugpy 环境，下载 Doom，并安装本配置启用的插件。首次安装需要网络，可能耗时较长。Homebrew 的 Emacs 默认提供终端版；有 GUI 需求可自行安装支持动态模块的 Emacs 30+ GUI 版本，再运行不带 `--deps` 的脚本。

已具备依赖时：`./install.sh`。预览安装路径且不修改文件：`./install.sh --dry-run`。

- 个人配置默认写入 `~/.config/doom`，已有目录会完整移动到带时间戳的备份目录；已有 `local.el` 会复制回来。
- Doom 默认写入 `~/.config/emacs`。新安装固定在 `doom-version` 中的版本；已有 Doom 原样复用，不强制切换版本。不同版本可能存在兼容性差异。
- 支持 `DOOMDIR`、`EMACSDIR`、`XDG_CONFIG_HOME` 覆盖路径；使用自定义路径时启动 Emacs 也要保持相同环境。
- 遇到已有非 Doom 的 Emacs 目录会停止，不覆盖。
- 不复制历史、密钥、AI 登录、环境缓存或你的项目文件。安装失败后备份仍保留，可修复依赖重跑；恢复时退出 Emacs，将新配置移开，再把备份移回原路径并执行 `doom sync`。
- 如存在旧的 `~/.emacs` 或 `~/.emacs.d` 启动配置，请先备份移开，避免 Emacs 优先加载旧配置。

## 首次启动

```sh
emacs
~/.config/emacs/bin/doom doctor
```

普通模式按 `SPC` 等待 Which-key 提示。终端首次启动可能编译 vterm 原生模块，结束后即可使用。字体需要重新启动 GUI 才会生效；终端版字体由外部终端控制。

## 常用快捷键

先按 `Esc` 回到普通模式，`SPC` 表示空格，`C-` 表示 Ctrl。

| 功能 | 快捷键 |
| --- | --- |
| 打开/新建文件 | `SPC .` / `C-x C-f` |
| 项目文件 / 最近文件 | `SPC f f` / `SPC f r` |
| 保存 | `SPC f s` / `:w` |
| 文件树 | `SPC e` |
| 弹出终端 | `SPC 2` |
| 右侧终端 | `SPC 3` |
| 左下上右窗口 | `C-h` / `C-j` / `C-k` / `C-l` |
| 上下 / 左右分屏 | `SPC -` / `SPC \|` |
| 缓冲区列表 / 关闭 | `SPC ,` / `SPC b d` |
| 项目搜索 | `SPC s g` |
| 项目菜单 / 剪贴板历史 | `SPC P` / `SPC p` |
| 定义 / 引用 / 文档 | `gd` / `gr` / `K` |
| 格式化 / 重命名符号 | `SPC c f` / `SPC c r` |
| 单文件 C++ 编译运行 | `SPC c R` |
| 调试 / 断点 | `F5` / `SPC d b` |
| 调试进入 / 越过 / 跳出 | `F1` / `F2` / `F3` |
| Lazygit | `SPC g g` |
| Org Agenda | `SPC o A` |

终端中按 `i` 输入，`Esc` 后用窗口快捷键切回代码。`SPC 3` 新建终端时从当前文件目录启动；没有文件时使用当前缓冲区目录。它会复用已有终端，切目录后检查 `pwd`，必要时自行 `cd`。`exit` 结束 shell；关分屏不会终止进程。配置清除继承的 `NO_COLOR`，但不安装作者的 zsh 主题、eza 别名或 shell 插件。

[完整使用教程](docs/usage.md) 是作者本机指南，其中提到的已安装工具和验证结果属于作者机器，不表示安装脚本包含所有可选组件。

## 开发与可选依赖

- **C++**：clangd、clang-format、CMake、LLDB 来自开发工具和 LLVM。`SPC c R` 仅编译当前文件，CMake 项目在终端运行 `cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug` 和 `cmake --build build`。
- **Python**：uv 管理项目 `.venv`，Pyright 分析，Ruff 格式化，debugpy 调试。项目依赖仍需自行执行 `uv sync`。不带 `--deps` 安装时需自行安装 uv、Ruff、Pyright。
- **R / ESS**：`--deps` 会安装 R；ESS 随 Doom `:lang ess` 安装。打开 `.R` 文件后按 `SPC o r` 启动 R 控制台，按 `SPC m l` 发送当前行，`SPC m r` 发送选中区域，`SPC m b` 发送整个缓冲区。不带 `--deps` 时请自行安装 R。R 语言服务器未默认启用，R 的 LSP 补全与诊断需要额外安装 `languageserver` 并将模块改为 `(ess +lsp)`。
- **调试**：Python 适配器优先使用安装脚本创建的独立环境。C++ 断点启动受本机 LLDB 和系统权限影响，尚未验证所有 GUI 环境。
- **LaTeX / PDF**：模块已启用，但大体积 TeX 发行版没有自动安装。需要时安装 MacTeX（例如 `brew install --cask mactex-no-gui`）；PDF Tools 可能还需要 `brew install poppler automake pkgconf` 后按 doctor 提示编译。
- **AI**：`SPC a c` Claude、`SPC a o c` Codex、`SPC a g t` Gemini。CLI 需自行安装登录。已有会话用 `SPC ,` 切换；当前打开函数会再次发送启动命令。
- **Telegram**：为了降低默认安装门槛，仓库默认不安装 telega。需要时取消 `packages.el` 中的注释，安装 TDLib、构建 telega-server，再运行 `doom sync`。
- **Linux**：未提供自动依赖安装。自行安装 Emacs 30+（动态模块）、git、ripgrep、fd、CMake、编译器和对应语言工具后，可用 `./install.sh`；未在全新 Linux 系统验证。

## 私有设置与更新

把机器专属路径、字体等覆盖项写入 `~/.config/doom/local.el`，它在配置末尾加载，不会提交到本仓库。

```elisp
;;; local.el -*- lexical-binding: t; -*-
(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 16))
```

更新仓库后重新执行安装脚本：

```sh
git pull --ff-only
./install.sh
```

每次都会备份旧配置；直接改过安装目录的其他文件，请先合并回仓库副本。`local.el` 会保留。Doom 本体升级需自行执行 `doom upgrade`，建议先备份并检查模块兼容性。

## 验证范围

配置源自作者正在使用的 Emacs 30.2 / Doom 2.1.1。仓库检查了 Lisp 括号、Shell 语法，以及隔离目录中的安装、备份、重复运行与拒绝覆盖流程。未在全新 macOS 上完整重装所有 Homebrew 和 Doom 依赖；可选组件仍以 `doom doctor` 结果为准。
