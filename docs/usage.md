---
title: Emacs 上手指南：从零开始配置 Python & C++ 开发环境
date: 2023-10-23 20:30:28
updated: 2026-09-05
categories:
  - Programming
  - Tools
tags:
  - Emacs
  - Python
  - C＋＋
photos:
  - https://picsum.photos/800/600?random=3
---

我目前在 macOS 上使用 **Emacs 30.2 + Doom Emacs + Evil**，主要用于 Python、C++ 开发，以及 Org 笔记。日常快捷键已按本机 LazyVim 的习惯做过统一，终端、Git 和 AI 工具也接入了 Emacs。

这篇文章保留最初的入门思路，并按 2026 年 9 月的实际配置重新整理：先学会打开文件、终端和分屏，再使用代码补全、格式化、调试与 CMake。

**适用范围：本文的快捷键以我的个人配置为准。** 标有「自定义」的操作需要相应配置，不是安装 Doom 后就自动具备。原生 Emacs、默认 Doom 和这里的键位不能完全混用。

<!-- more -->

## 1. 先看懂快捷键和界面

### 快捷键记法

| 记法 | 怎么按 |
| --- | --- |
| `SPC f f` | 先按 `Esc` 回到普通模式，再依次按空格、`f`、`f` |
| `C-x C-f` | 按 Ctrl+x，再按 Ctrl+f |
| `M-x` | Meta+x；不确定 Mac 的 Meta 配置时，可用 `SPC :` 打开命令搜索 |
| `RET` | 回车 |
| `SPC c R` | 最后一个是大写 `R`，需要 Shift+r |

Evil 提供 Vim 风格的普通模式、插入模式和可视模式。**输入文本前按 `i`，输入结束按 `Esc`。** 下文的空格前缀快捷键主要在普通模式中使用。

遇到未完成的命令、选择框或提示，通常可以用 `C-g` 取消。按 `SPC` 后稍等，Which-key 会显示后续可用按键，不必一次记住所有组合。

### Buffer、Window 和 Frame

- **Buffer（缓冲区）**：正在编辑或查看的内容，可以是文件、终端或编译输出。
- **Window（窗口）**：Emacs 内部的一块分屏，显示某个缓冲区。
- **Frame（框架）**：桌面上的一个完整 Emacs 窗口。

关闭分屏不等于关闭文件，关闭文件缓冲区也不等于删除磁盘文件。

## 2. 最常用的快捷键速查

| 功能 | 当前快捷键 | 说明 |
| --- | --- | --- |
| 打开或新建指定路径的文件 | `SPC .` / `C-x C-f` | 新建文件优先用这个入口 |
| 查找项目文件 | `SPC SPC` / `SPC f f` | 后者已自定义为项目文件搜索 |
| 最近文件 | `SPC f r` | 找回刚关闭的文件 |
| 保存 | `:w` / `SPC f s` / `C-x C-s` | `:w` 后按回车 |
| 项目全文搜索 | `SPC /` / `SPC s g` | 后者为自定义 |
| 文件树 | `SPC e` | 自定义，Neotree |
| 缓冲区列表 | `SPC ,` | 选择已打开的内容 |
| 回到上一个缓冲区 | `SPC b b` | 自定义，不是打开列表 |
| 前后切换缓冲区 | `H` / `L` | 自定义 |
| 弹出终端 | `SPC 2` | 自定义入口，调用 Doom 的 vterm 弹出窗口 |
| 右侧终端 | `SPC 3` | 自定义，约占当前窗口宽度的 42% |
| 左/下/上/右切换窗口 | `C-h` / `C-j` / `C-k` / `C-l` | 自定义，普通模式 |
| 格式化 | `SPC c f` | 当前缓冲区或选中区域 |
| 重命名代码符号 | `SPC c r` | 自定义统一键位，需要 LSP |
| 编译运行单个 C++ 文件 | `SPC c R` | 自定义，注意大写 |
| Lazygit | `SPC g g` | 自定义 |
| 剪贴板历史 | `SPC p` | 自定义 |

**两个容易记错的地方：** `SPC c r` 是符号重命名，`SPC c R` 才是单文件 C++ 编译运行；`SPC p` 已用于剪贴板历史，完整项目菜单迁到了大写的 `SPC P`。

## 3. 文件操作与基础编辑

### 创建和保存文件

1. 按 `SPC .`，输入 `~/hello.txt`，回车。
2. 按 `i` 输入内容。
3. 按 `Esc`，输入 `:w` 并回车。
4. 按 `SPC b d` 关闭缓冲区。
5. 按 `SPC f r`，重新打开刚才的文件。

新文件在保存后才真正写入磁盘。当前的 `SPC f f` 用来搜索项目文件，不能再把它简单理解为旧版教程里的通用文件打开入口。

### Vim 风格编辑

| 按键 | 功能 |
| --- | --- |
| `h j k l` | 左、下、上、右移动 |
| `w` / `b` | 跳到下一个 / 上一个单词 |
| `gg` / `G` | 文件开头 / 末尾 |
| `i` / `a` / `o` | 插入 / 追加 / 下方新建一行并输入 |
| `v` / `V` | 按字符 / 按行选择 |
| `yy` / `p` | 复制一行 / 粘贴 |
| `dd` | 删除一行 |
| `u` / `C-r` | 撤销 / 重做 |
| `/关键词` | 在当前文件中搜索，回车确认 |
| `n` / `N` | 下一个 / 上一个搜索结果 |

### 文件管理、重命名和删除

| 快捷键 | 功能 |
| --- | --- |
| `SPC e` / `C-c 2` | 切换 Neotree 文件树，自定义 |
| `SPC o p` | 打开项目侧栏，Doom 原有入口 |
| `SPC o -` | 进入当前文件所在的 Dired 目录 |
| `SPC f N` | 重命名或移动当前文件，自定义 |
| `SPC b d` | 关闭当前缓冲区，不删除磁盘文件 |
| `SPC b o` | 关闭其他缓冲区，自定义 |

要删除磁盘文件，可用 `SPC :` 执行 `dired`，打开目录后按 `d` 标记删除，按 `x` 执行，并确认提示。按 `u` 可以取消标记。

## 4. 终端：SPC 2 和 SPC 3 怎么用

这是我最常使用的一组操作。终端后端是 **vterm**，里面运行的是 shell；Emacs 本身不是 shell。

### 打开、输入和切回代码

- **`SPC 2`**：调用 `+vterm/toggle`，显示或隐藏 Doom 的弹出终端。名字虽然写着 Floating terminal，实际布局由 Doom 的 popup 规则控制，通常在底部。
- **`SPC 3`**：打开或聚焦右侧的 `*vterm-right*`。当前实现会复用这个缓冲区，第二次按不是关闭终端。
- **`SPC o t`**：Doom 原有的弹出 vterm 入口。

推荐操作顺序：

1. 先打开项目中的代码文件。
2. 按 `SPC 3` 打开右侧终端；如果输入没有进入 shell，按 `i`。
3. 输入 `pwd`、`ls` 或构建命令。
4. 按 `Esc` 回到普通模式，再按 `C-h` 切回左侧代码。
5. 回到终端后按 `i`，继续输入命令。

当前右侧终端在**新建时**以当前文件所在目录为起点；没有关联文件时使用当前缓冲区的目录。复用已存在的终端不会自动执行 `cd`。切换目录后先检查 `pwd`，必要时手动切换。

### 关闭终端和停止命令

- `exit`：退出当前 shell；本机配置会关闭已结束的 vterm 缓冲区。
- `Esc` → `SPC w d`：关闭当前终端分屏，终端进程可以继续存在。
- `SPC 2`：隐藏弹出终端，不等于停止里面运行的命令。
- 终端输入模式下的 `C-c`：向 shell 中的前台程序发送中断。若被 Emacs 键位拦截，可先按 `C-q`，再按 `C-c`，由 vterm 原样发送。

### 确认是否加载 zsh

在终端中执行：

```zsh
echo $ZSH_VERSION
type ls
```

输出 zsh 版本号，说明当前 shell 是 zsh。本机的 `ls` 是 `eza --icons --git` 的别名，文件图标和提示符来自 shell 配置。

### 为什么第一次出现 Install vterm？

首次加载时，vterm 可能编译原生模块。出现 `*Install vterm*` 和 CMake 编译日志不代表 shell 没加载。

看到 `Built target vterm-module` 表示该编译阶段成功。可以切到日志窗口，按 `SPC w d` 关闭它，再继续编辑。

### ls 有图标却没有颜色

本机曾遇到 Doom 环境缓存保存了 `NO_COLOR=1`，导致 eza 关闭颜色。当前终端可以先验证：

```zsh
printenv NO_COLOR
unset NO_COLOR
ls
```

永久修复是在 `~/.config/doom/config.el` 中清除继承的变量：

```elisp
(setenv "NO_COLOR" nil)
```

本机也已移除 `~/.config/emacs/.local/env` 中的旧记录。重启 Emacs 后新开的终端会继承修正后的环境，已经运行的 shell 则需要执行 `unset NO_COLOR` 或重新打开。

## 5. 分屏、缓冲区和项目管理

### 分屏

| 操作 | 当前快捷键 | 原生 Emacs 对应操作 |
| --- | --- | --- |
| 上下分屏 | `SPC -` | `C-x 2` |
| 左右分屏 | `SPC \|` | `C-x 3` |
| 切换窗口 | `C-h/j/k/l` | `C-x o` 循环切换 |
| 关闭当前分屏 | `SPC w d` | `C-x 0` |
| 只保留当前分屏 | `C-x 1` | 同左 |

`C-h/j/k/l` 表示四个独立快捷键，只在普通模式里按这里的含义使用。插入模式、补全列表和终端输入模式可能有不同绑定。

### 项目菜单为什么变成了大写 P？

Doom 默认把项目操作放在 `SPC p` 下，但我的配置用 `SPC p` 打开剪贴板历史。为避免覆盖整个项目菜单，先复制项目键位到 `SPC P`，再绑定剪贴板功能。

| 快捷键 | 功能 |
| --- | --- |
| `SPC f p` / `SPC P p` | 切换已知项目 |
| `SPC P a` | 添加项目 |
| `SPC P f` | 查找项目文件 |
| `SPC P c` | 在项目中运行构建命令 |
| `SPC P C` | 重复上次项目命令 |
| `SPC P s` | 保存项目文件 |
| `SPC P T` | 运行项目测试命令 |

第一次接触一个项目时，可以先用 `SPC .` 打开项目内文件；Projectile 会根据 Git 等项目标记识别根目录。测试或构建命令不能自动推断时，需要输入适合该项目的命令。

### 搜索和代码导航

| 快捷键 | 功能 |
| --- | --- |
| `SPC s g` / `SPC /` | 搜索项目内容 |
| `SPC s G` | 搜索当前目录内容 |
| `SPC s p` | 搜索个人 Emacs 配置内容，不是项目搜索 |
| `SPC s t` | 搜索 TODO、FIX、FIXME、HACK、REVIEW |
| `SPC s T` | 只搜索 TODO、FIX、FIXME |
| `gd` | 跳到定义 |
| `gr` | 在代码中查找引用 |
| `K` | 查看文档 |
| `C-o` / `C-i` | 沿跳转记录后退 / 前进 |

编译输出、Dired 等特殊缓冲区可能保留自己的 `gr` 刷新操作。语言服务器未启动或项目编译参数不完整时，定义和引用查询也可能不完整。

## 6. 当前配置文件与开发模块

### 配置路径已经更新

本机当前使用：

```text
~/.config/emacs/           Doom 本体
~/.config/doom/init.el     启用模块
~/.config/doom/config.el   个人设置、函数和快捷键
~/.config/doom/packages.el 额外插件声明
```

旧的 `~/.doom.d/` 仍保留，但当前没有设置其他 `DOOMDIR` 时，本机 Doom 优先选择 `~/.config/doom/`。不要同时改两套目录再猜哪套生效。

开发相关模块包括以下内容；这是 `doom!` 中的**节选**，不是让已有用户覆盖整个 `init.el`：

```elisp
:completion
(corfu +orderless)
vertico

:editor
(evil +everywhere)
(format +onsave)

:term
vterm

:tools
debugger
(lsp +peek)
magit
tree-sitter

:lang
(cc +lsp +tree-sitter)
(python +lsp +pyright +tree-sitter +uv)
latex
org
```

修改模块或插件声明后运行：

```sh
~/.config/emacs/bin/doom sync
```

然后重启 Emacs。只调整普通 `config.el` 设置一般不需要同步，重启即可加载；出现问题时可运行 `~/.config/emacs/bin/doom doctor` 检查依赖。

本文中的右侧终端、单文件 C++ 运行和 AI 快捷键来自个人函数，仅启用这些模块不会自动创建对应快捷键。

## 7. C++：补全、格式化与单文件运行

### 使用 clangd

当前采用 **clangd**，不是 ccls。先确认命令可用：

```sh
command -v clangd
command -v clang-format
command -v g++
```

本机的 clangd 来自开发工具，clang-format 已单独安装。当前个性化参数如下：

```elisp
(after! lsp-clangd
  (setq lsp-clients-clangd-args
        '("--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=never"
          "--header-insertion-decorators=0"))
  (set-lsp-priority! 'clangd 2))
```

旧文章把 `lsp-clients-clangd-executable` 设置成 `"ccls"`，这种写法应删除：clangd 客户端应启动 clangd，不能直接换成另一个服务器的程序名。

### 运行一个 C++ 文件

打开 `hello.cpp`：

```cpp
#include <iostream>

int main() {
    std::cout << "Hello, Emacs!" << '\n';
    return 0;
}
```

- `SPC c f`：手动格式化；当前配置也会在普通保存时使用 clang-format。
- `SPC c R`：保存后编译运行，输出程序为同目录下的 `hello.out`。
- `SPC c r`：通过 LSP 重命名符号，不是运行代码。

单文件命令默认使用 `-std=c++17 -g -O0 -Wall -Wextra`，优先查找 `g++`，其次是 `clang++`。macOS 上名为 `g++` 的系统命令可能实际使用 Apple Clang，可通过 `g++ --version` 确认。

这个运行命令没有解析 CMake，也不会自动链接项目中的其他源文件。它适合小程序和练习题。

## 8. CMake：从单文件进入项目开发

多文件项目使用 CMake 管理构建。一个最小项目可以这样组织：

```text
hello-cmake/
├── CMakeLists.txt
└── src/
    └── main.cpp
```

`src/main.cpp` 使用上一节的示例，`CMakeLists.txt` 内容如下：

```cmake
cmake_minimum_required(VERSION 3.20)
project(hello_cmake LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(hello_app src/main.cpp)
target_compile_features(hello_app PRIVATE cxx_std_17)
```

先在 Emacs 打开这个项目的文件，然后 `SPC 3` 打开终端。当前文件如果位于 `src/`，先执行 `cd ..` 回到项目根目录；确认 `pwd` 后再执行：

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build
./build/hello_app
```

以上示例针对本机常见的单配置 Makefiles/Ninja 构建。使用 Xcode 等多配置生成器时，构建配置和可执行文件路径需要相应调整。

生成的 `build/compile_commands.json` 会记录头文件目录、宏和编译参数，帮助 clangd 正确分析项目。clangd 通常会检查名为 `build` 的目录；如果使用其他构建目录或仍有头文件识别问题，可在项目根目录添加 `.clangd`：

```yaml
CompileFlags:
  CompilationDatabase: build
```

也可以按 `SPC P c`，输入 `cmake --build build` 构建项目。**CMake 项目不要用 `SPC c R` 代替构建命令。** 当前自定义的 `cpp-lldb-dap` 仍面向单文件；项目调试需要另配启动项，指向如 `build/hello_app` 的目标，而不是 `.cpp` 文件。

## 9. Python：项目环境、格式化与运行

### 当前工具组合

- **Pyright**：代码分析、类型检查和跳转。
- **uv + 项目 `.venv`**：管理项目依赖和 Python 环境。
- **Ruff + Apheleia**：格式化和导入排序。
- **pytest**：测试。
- **debugpy + Dape**：调试。

本机已启用 Doom 的 Python `+uv` 集成，并修复了切换项目后旧虚拟环境路径残留的问题。编辑器可以识别已有 `.venv`，但不会因此自动安装项目依赖。

新建一个项目时，可在终端执行：

```sh
mkdir python-demo
cd python-demo
uv init
uv add --dev pytest
uv sync
uv run python main.py
uv run pytest
```

最后一条命令需要项目中已有测试。已有 uv 项目则通常在项目根目录执行 `uv sync`，按锁文件恢复环境。

### 格式化已经改用 Ruff

旧文章中的 Black 配置已不适用于当前设置。Ruff 在本机通过 `uv tool install ruff` 安装，并已加入 Emacs 可执行路径。

对应的 Apheleia 映射为：

```elisp
(after! apheleia
  (dolist (mode '(python-mode python-ts-mode))
    (setf (alist-get mode apheleia-mode-alist)
          '(ruff-isort ruff))))
```

启用 `(format +onsave)` 后，本机把自动格式化范围限制在 C/C++ 和 Python。普通保存会格式化，也可按 `SPC c f` 手动执行。**单文件 C++ 运行命令内部的自动保存会跳过异步格式化，以免和编译发生竞态；需要时先普通保存或手动格式化。**

### REPL 和运行代码

- `SPC o r`：打开当前语言的 REPL。
- `SPC :` → `run-python`：直接启动 Python REPL。
- `SPC c s`：把缓冲区或选中区域发送到 REPL。
- `SPC 3`：打开终端，在项目中运行 `uv run python main.py`。

原生 Python 模式里，`C-c C-c` 通常发送整个缓冲区，`C-c C-r` 才是发送选中区域；不要把它和 Org 代码块的执行快捷键混为一谈。

终端是独立运行的 shell。即使 Emacs 已识别 `.venv`，之前打开的终端也不会自动切换环境。在终端里使用 `uv run`，或自行激活 `.venv`。

## 10. 调试：断点、单步和变量

| 快捷键 | 功能 |
| --- | --- |
| `F5` | 选择配置启动调试；已有暂停会话时继续 |
| `SPC d b` | 设置或取消断点 |
| `SPC d B` | 设置条件断点 |
| `F1` | 单步进入函数 |
| `F2` | 单步越过 |
| `F3` | 跳出当前函数 |
| `F7` | 打开 Dape 信息界面 |

Mac 顶部按键若优先控制亮度、音量等系统功能，可能需要同时按 `fn`。

Python 文件选择 `python-debugpy`。本机用全局 Python 启动已安装的 debugpy 适配器，并让被调试程序使用项目解释器。Python 项目环境切换和断点暂停已经实测通过。

单个 C++ 文件选择 `cpp-lldb-dap`：先保存并编译带调试信息的程序，再启动生成的 `.out`。已验证编译运行和调试符号；此前在自动化执行环境中，LLDB 启动进程时报 `process exited with status -1`，因此还不能把本机 GUI 中的 C++ 断点命中标为已验证。

## 11. Git 和 AI 工具

### Git

| 快捷键 | 功能 |
| --- | --- |
| `SPC g g` | 打开 Lazygit |
| `SPC g H` | 查看当前文件提交历史 |
| `SPC g V` | 查看当前文件的 Magit 差异 |
| `SPC g /` | Magit 操作菜单 |
| `SPC g c c` | Magit 创建提交 |

`SPC g c` 是恢复后的 Git 创建菜单。Gemini 的统一入口在 `SPC a g` 下，不再占用这个前缀。

### Claude、Codex 和 Gemini

| 快捷键 | 功能 |
| --- | --- |
| `SPC a c` / `SPC a f` | 打开或聚焦 Claude 终端 |
| `SPC a r` | 运行 `claude --resume` |
| `SPC a C` | 运行 `claude --continue` |
| `SPC a b` | 向 Claude 终端插入当前文件引用 |
| `SPC a o c` / `SPC a o f` | 打开或聚焦 Codex 终端 |
| `SPC a o b` | 向 Codex 终端插入当前文件引用 |
| `SPC a g t` / `SPC a g c` | 打开 Gemini CLI 终端 |

这些是本机自定义的 vterm 包装函数，要求对应 CLI 已安装并完成登录。文件引用使用 `@相对路径`；如果目标终端尚未打开，引用会复制到 Emacs 剪贴板历史。

当前发送文件引用的函数只插入文字，不会自动按回车提交请求。当前的「打开/聚焦」函数还会发送启动命令，不是严格的显示/隐藏切换；已有 AI 会话正在运行时，优先通过 `SPC ,` 切换到对应缓冲区，避免把命令送入现有会话。

旧的 `SPC z a`、`SPC z x` 入口仍保留，但日常推荐记上表这套与 Neovim 对齐的键位。两边插件的对话、选区发送和接受修改等内部功能仍有差异。

## 12. Org：笔记、待办和代码块

### 从一份笔记开始

用 `SPC .` 打开 `~/org/learn.org`：

```org
* Emacs 学习
** TODO 练习项目搜索
** TODO 写一个 CMake 项目
** DONE 学会打开终端

* 今日笔记
- SPC 3：右侧终端
- SPC s g：搜索项目

| 任务     | 状态 |
|----------+------|
| 编译示例 | 完成 |
```

- `Tab`：在标题处折叠或展开，在表格内整理和移动单元格。
- `C-c C-t`：切换 TODO 状态。
- `SPC o A`：打开 Org Agenda。

Agenda 只收集已加入 `org-agenda-files` 的文件；仅把文件放到 `~/org/` 不代表它一定会出现在日程里。

### 在笔记中执行 Python

以下是需要时可加入个人配置的示例，不表示每个新装 Doom 都已有相同设置：

```elisp
(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)))
  (setq org-babel-python-command "python3"))
```

在 Org 文件中写入：

```org
#+begin_src python :results output
print("Hello, Org-Mode!")
#+end_src
```

光标放在代码块内按 `C-c C-c`，按提示确认执行后得到：

```org
#+RESULTS:
: Hello, Org-Mode!
```

`:results output` 用于收集 `print` 的输出；否则默认的返回值模式可能与预期不同。涉及项目依赖时，还需要让 Babel 使用安装了这些依赖的解释器。

### 导出和公式

- `C-c C-e`：打开导出菜单，具体格式取决于已加载的导出后端。
- `C-c C-x C-l`：预览 LaTeX 数学公式。
- PDF 导出需要可用的 LaTeX 工具链；本机已有 LaTeX 模块、latexmk、pdfLaTeX 和 XeLaTeX。

## 13. 获取帮助、退出与学习顺序

### 忘记键位时怎么办

- 按 `SPC` 后稍等，查看 Which-key 提示。
- `SPC :` → `describe-key`：再按一个键，查看实际绑定。
- `SPC :` → `describe-function`：查询命令说明。
- `SPC :` → `help-with-tutorial`：打开原生 Emacs 交互教程。

很多官方教程使用 `C-h` 作为帮助前缀，但本机普通模式的 `C-h` 已改为切换左侧窗口，因此这里优先使用命令搜索入口。

### 退出和保存会话

| 快捷键 | 功能 |
| --- | --- |
| `SPC q s` | 快速保存编辑器会话 |
| `SPC q l` | 恢复保存的会话 |
| `SPC q q` / `C-x C-c` | 退出当前 Emacs 终端/框架，按提示处理未保存文件 |

保存会话不等于保存终端进程，Python REPL、shell 和 AI 对话进程通常不能靠编辑器会话恢复原样继续运行。

### 推荐的练习顺序

1. 创建并保存一个文件，练习 `i`、`Esc`、`:w`。
2. 打开项目，练习 `SPC f f`、`SPC s g`、`gd` 和 `C-o`。
3. 用 `SPC 3` 打开终端，运行一个程序，再切回代码。
4. 练习 Git 历史、格式化和一次 Python 断点调试。
5. 用 Org 记录日常笔记，再逐步增加待办和代码块。

参考资料：

- [GNU Emacs 官方手册](https://www.gnu.org/software/emacs/manual/html_node/emacs/)
- [Org 官方快速入门](https://orgmode.org/quickstart.html)
- [clangd 项目配置说明](https://clangd.llvm.org/installation)
- [Ruff 编辑器集成](https://docs.astral.sh/ruff/editors/setup/)

这些资料用于理解原理和查询命令；本文自定义键位的最终依据仍是本机 `~/.config/doom/config.el`。
