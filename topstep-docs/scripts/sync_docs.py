#!/usr/bin/env python3
"""
TopStepComKit SDK 文档自动同步脚本

使用方式:
  python3 sync_docs.py              # 扫描所有变更并同步
  python3 sync_docs.py --file x.h  # 同步指定 .h 文件对应的模块
  python3 sync_docs.py --watch      # 持续监听 .h 文件变化，自动同步
  python3 sync_docs.py --all        # 强制同步所有模块（忽略缓存）

环境变量:
  ANTHROPIC_API_KEY  必须设置，用于调用 Claude API 生成文档
"""

import os
import sys
import json
import hashlib
import argparse
import time
from pathlib import Path
from datetime import datetime
from typing import Optional, Tuple

# ============================================================
# 路径配置
# ============================================================
SCRIPT_DIR   = Path(__file__).parent
DOCS_ROOT    = SCRIPT_DIR.parent           # topstep-docs/
SDK_ROOT     = DOCS_ROOT.parent            # TopStepComKit/
INTERFACE_SRC = (
    SDK_ROOT
    / "TopStepInterfaceKit"
    / "TopStepInterfaceKit"
    / "Classes"
    / "Source"
)
ZH_DOCS      = DOCS_ROOT / "docs"
EN_DOCS      = DOCS_ROOT / "i18n" / "en" / "docusaurus-plugin-content-docs" / "current"
CACHE_FILE   = SCRIPT_DIR / ".h_hashes.json"
CHANGELOG_ZH = ZH_DOCS / "changelog.md"
CHANGELOG_EN = EN_DOCS / "changelog.md"

# ============================================================
# 模块 → 文档路径 映射
# ============================================================
MODULE_DOC_MAP: dict[str, tuple[str, str, str]] = {
    # 模块目录名: (文档相对路径, 中文名, sidebar_position)
    "TSBleConnect":        ("api/ble-connect",              "蓝牙连接",     "1"),
    "TSHeartRate":         ("api/health/heart-rate",        "心率",         "2"),
    "TSSleep":             ("api/health/sleep",             "睡眠",         "3"),
    "TSBloodOxygen":       ("api/health/blood-oxygen",      "血氧",         "4"),
    "TSBloodPressure":     ("api/health/blood-pressure",    "血压",         "5"),
    "TSStress":            ("api/health/stress",            "压力",         "6"),
    "TSTemperature":       ("api/health/temperature",       "体温",         "7"),
    "TSElectrocardio":     ("api/health/electrocardio",     "心电",         "8"),
    "TSSport":             ("api/health/sport",             "运动",         "9"),
    "TSDailyActivity":     ("api/health/daily-activity",    "日常活动",     "10"),
    "TSAutoMonitor":       ("api/health/auto-monitor",      "自动监测",     "11"),
    "TSActivityMeasure":   ("api/health/active-measure",    "主动测量",     "12"),
    "TSHealthBase":        ("api/health/overview",          "健康数据概述", "1"),
    "TSDataSync":          ("api/data-sync",                "数据同步",     "1"),
    "TSBattery":           ("api/device/battery",           "设备电量",     "1"),
    "TSPeripheralFind":    ("api/device/find",              "查找设备",     "2"),
    "TSPeripheralLock":    ("api/device/lock",              "屏幕锁",       "3"),
    "TSFirmwareUpgrade":   ("api/device/firmware",          "固件升级",     "4"),
    "TSDial":              ("api/device/dial",              "表盘",         "5"),
    "TSMessage":           ("api/communication/message",    "消息通知",     "1"),
    "TSContact":           ("api/communication/contact",    "联系人",       "2"),
    "TSAlarmClock":        ("api/communication/alarm",      "闹钟",         "3"),
    "TSReminders":         ("api/communication/reminders",  "提醒",         "4"),
    "TSCamera":            ("api/communication/camera",     "相机控制",     "5"),
    "TSUserInfo":          ("api/settings/user-info",       "用户信息",     "1"),
    "TSUnit":              ("api/settings/unit",            "单位设置",     "2"),
    "TSLanguage":          ("api/settings/language",        "语言设置",     "3"),
    "TSTime":              ("api/settings/time",            "时间设置",     "4"),
    "TSSetting":           ("api/settings/setting",        "设备设置",     "5"),
    "TSWeather":           ("api/settings/weather",         "天气",         "6"),
    "TSMusic":             ("api/extras/music",             "音乐控制",     "1"),
    "TSGlasses":           ("api/extras/glasses",           "眼镜",         "2"),
    "TSFemaleHealth":      ("api/extras/female-health",     "女性健康",     "3"),
    "TSPrayers":           ("api/extras/prayers",           "祈祷时间",     "4"),
    "TSAIChat":            ("api/extras/ai-chat",           "AI 聊天",      "5"),
    "TSWorldClock":        ("api/extras/world-clock",       "世界时钟",     "6"),
    "TSCardBag":           ("api/extras/card-bag",          "卡包",         "7"),
    "TSAppStore":          ("api/extras/app-store",         "应用商店",     "8"),
}

# ============================================================
# 提示词模板
# ============================================================
ZH_SYSTEM = """你是 TopStepComKit iOS SDK 的技术文档工程师。
根据提供的 Objective-C 头文件，生成格式规范的中文 Markdown 技术文档。

文档格式（严格遵守）：
1. 顶部 frontmatter：sidebar_position 和 title 字段
2. 一级标题 = 模块名称（中文 + 英文括号）
3. 一段概述
4. "## 前提条件" —— 说明使用前需满足的条件
5. "## 数据模型" —— 所有 Model/Struct/Enum，用 Markdown 表格列出属性（属性名、类型、说明）
6. "## 枚举与常量" —— 所有枚举，用表格列出每个值和说明
7. "## 回调类型" —— typedef block 类型，用表格列出
8. "## 接口方法" —— 每个方法：
   - 三级标题 = 方法功能描述
   - objectivec 代码块展示方法签名
   - 参数表格（参数名、类型、说明）
   - 代码示例（真实可用的 Objective-C 代码）
9. "## 注意事项" —— 重要使用注意点，使用有序列表
10. 不输出任何解释，直接输出 Markdown 内容
11. 代码示例中用 TSLog() 而非 NSLog()

【重要】Markdown 表格中的类型写法（必须严格遵守）：
- 表格单元格中所有 Objective-C 类型名称必须用反引号包裹，例如：
  - `NSString *` 而非 NSString *
  - `NSInteger` 而非 NSInteger
  - `BOOL` 而非 BOOL
  - `NSArray<TSItem *> *` 而非 NSArray<TSItem *> *
  - `void (^)(NSError *)` 而非 void (^)(NSError *)
- 表格单元格中不得出现裸露的 * 号或 <> 尖括号（须用反引号包裹整个类型）
- 只有在代码块（```objc ... ```）中才可以写不带反引号的 OC 代码
"""

EN_SYSTEM = """You are a technical documentation engineer for the TopStepComKit iOS SDK.
Based on the provided Objective-C header files, generate a well-structured English Markdown documentation.

Documentation format (strictly follow):
1. Top frontmatter with sidebar_position and title fields
2. H1 = Module name (English)
3. One-paragraph overview
4. "## Prerequisites" — conditions required before use
5. "## Data Models" — all Model/Struct/Enum with property tables (property, type, description)
6. "## Enumerations" — all enums with value tables
7. "## Callback Types" — typedef block types with tables
8. "## API Reference" — for each method:
   - H3 = method purpose in plain English
   - objectivec code block with method signature
   - Parameters table (name, type, description)
   - Code example (working Objective-C code)
9. "## Important Notes" — key usage notes in an ordered list
10. Output only Markdown, no explanations
11. Use TSLog() instead of NSLog() in code examples

IMPORTANT — Type names in Markdown tables (strictly required):
- All Objective-C type names in table cells MUST be wrapped in backticks, for example:
  - `NSString *` not NSString *
  - `NSInteger` not NSInteger
  - `BOOL` not BOOL
  - `NSArray<TSItem *> *` not NSArray<TSItem *> *
  - `void (^)(NSError *)` not void (^)(NSError *)
- Table cells must NOT contain bare * characters or <> angle brackets (wrap entire type in backticks)
- Only inside code fences (```objc ... ```) may OC code appear without backtick wrapping
"""

# ============================================================
# 工具函数
# ============================================================

def file_hash(path: Path) -> str:
    return hashlib.md5(path.read_bytes()).hexdigest()


def load_cache() -> dict:
    if CACHE_FILE.exists():
        return json.loads(CACHE_FILE.read_text())
    return {}


def save_cache(cache: dict):
    CACHE_FILE.write_text(json.dumps(cache, indent=2, ensure_ascii=False))


def collect_module_headers(module_dir: Path) -> str:
    """收集模块目录下所有 .h 文件内容，拼接成字符串"""
    headers = []
    for h_file in sorted(module_dir.rglob("*.h")):
        rel = h_file.relative_to(INTERFACE_SRC)
        headers.append(f"// ===== {rel} =====\n{h_file.read_text(encoding='utf-8', errors='ignore')}")
    return "\n\n".join(headers)


def find_module_dir(file_path: Path) -> Optional[Tuple[str, Path]]:
    """从 .h 文件路径反推模块名和模块目录"""
    try:
        rel = file_path.relative_to(INTERFACE_SRC)
    except ValueError:
        return None

    parts = rel.parts
    # 顶层模块（如 TSBleConnect）或嵌套模块（如 TSHealthDataFeatures/TSHeartRate）
    for i, part in enumerate(parts):
        if part in MODULE_DOC_MAP:
            return part, INTERFACE_SRC / Path(*parts[: i + 1])

    return None


def generate_doc(module_name: str, module_dir: Path, lang: str) -> str:
    """调用 Claude API 生成文档"""
    try:
        import anthropic
    except ImportError:
        print("❌ 请先安装 anthropic: pip3 install anthropic")
        sys.exit(1)

    api_key = os.environ.get("ANTHROPIC_API_KEY") or os.environ.get("ANTHROPIC_AUTH_TOKEN")
    base_url = os.environ.get("ANTHROPIC_BASE_URL")

    # 若环境变量未设置，从 Claude Code 配置文件读取
    if not api_key:
        claude_settings = Path.home() / ".claude" / "settings.json"
        if claude_settings.exists():
            try:
                cfg = json.loads(claude_settings.read_text())
                env = cfg.get("env", {})
                api_key = env.get("ANTHROPIC_AUTH_TOKEN") or env.get("ANTHROPIC_API_KEY")
                base_url = base_url or env.get("ANTHROPIC_BASE_URL")
            except Exception:
                pass

    if not api_key:
        print("❌ 未找到 API Key，请设置 ANTHROPIC_API_KEY 环境变量")
        sys.exit(1)

    doc_path, zh_name, sidebar_pos = MODULE_DOC_MAP[module_name]
    headers_content = collect_module_headers(module_dir)

    title = zh_name if lang == "zh" else module_name.replace("TS", "")
    system_prompt = ZH_SYSTEM if lang == "zh" else EN_SYSTEM
    user_msg = (
        f"模块: {module_name}（{zh_name}）\n"
        f"sidebar_position: {sidebar_pos}\n"
        f"title: {title}\n\n"
        f"以下是该模块所有头文件内容：\n\n{headers_content}"
    )

    client_kwargs = {"api_key": api_key}
    if base_url:
        client_kwargs["base_url"] = base_url

    client = anthropic.Anthropic(**client_kwargs)
    message = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=8192,
        system=system_prompt,
        messages=[{"role": "user", "content": user_msg}],
    )
    return message.content[0].text


def fix_mdx_table_cells(content: str) -> str:
    """修复 Markdown 中裸露的 OC 类型符号（* 和 <>），避免 MDX 将其解析为 JSX"""
    import re

    # 匹配泛型类型表达式，如 NSArray<Foo *> * 或 NSDictionary<K, V>
    GENERIC_RE = re.compile(
        r'(?<![`])'                   # 前面不是反引号
        r'([A-Z]\w*<[^`>]+>(?:\s*\*)*)'  # 大写开头 + 泛型 + 可选指针
        r'(?![`\w])'                  # 后面不是反引号或字母
    )
    # 匹配裸指针类型，如 NSString * / UIImage * (不含泛型参数内的类型)
    POINTER_RE = re.compile(
        r'(?<![`\w<])'
        r'([A-Z]\w+\s*\*+)'
        r'(?![`\w])'
    )

    lines = content.split("\n")
    in_code_block = False
    result = []

    for line in lines:
        stripped_line = line.strip()
        if stripped_line.startswith("```"):
            in_code_block = not in_code_block
            result.append(line)
            continue

        if in_code_block:
            result.append(line)
            continue

        if line.startswith("|"):
            # 表格行：逐单元格处理
            cells = line.split("|")
            new_cells = []
            for cell in cells:
                cell_stripped = cell.strip()
                if ("*" in cell_stripped or "<" in cell_stripped) and "`" not in cell_stripped:
                    cell = cell.replace(cell_stripped, f"`{cell_stripped}`")
                new_cells.append(cell)
            result.append("|".join(new_cells))
        else:
            # 非表格行：先替换泛型，再替换裸指针
            new_line = GENERIC_RE.sub(lambda m: f"`{m.group(1)}`", line)
            new_line = POINTER_RE.sub(lambda m: f"`{m.group(1)}`", new_line)
            result.append(new_line)

    return "\n".join(result)


def write_doc(module_name: str, content: str, lang: str):
    """将文档写入对应路径"""
    doc_path, _, _ = MODULE_DOC_MAP[module_name]
    target_dir = ZH_DOCS if lang == "zh" else EN_DOCS
    out_file = target_dir / f"{doc_path}.md"
    out_file.parent.mkdir(parents=True, exist_ok=True)
    content = fix_mdx_table_cells(content)
    out_file.write_text(content, encoding="utf-8")
    print(f"  ✅ [{lang}] {out_file.relative_to(DOCS_ROOT.parent)}")


def append_changelog(changed_modules: list[tuple[str, str]]):
    """在 changelog.md 的第一个 ## 标题前追加今日更新记录"""
    today = datetime.now().strftime("%Y-%m-%d")

    for changelog_file, lang in [(CHANGELOG_ZH, "zh"), (CHANGELOG_EN, "en")]:
        changelog_file.parent.mkdir(parents=True, exist_ok=True)
        if changelog_file.exists():
            existing = changelog_file.read_text(encoding="utf-8")
        else:
            if lang == "zh":
                existing = "---\nsidebar_position: 10\ntitle: 更新日志\n---\n\n# 更新日志\n"
            else:
                existing = "---\nsidebar_position: 10\ntitle: Changelog\n---\n\n# Changelog\n"

        lines = []
        if lang == "zh":
            lines.append(f"\n## {today}\n")
            for module_name, zh_name in changed_modules:
                lines.append(f"- **{zh_name}（{module_name}）**: 接口文档已同步更新")
        else:
            lines.append(f"\n## {today}\n")
            for module_name, _ in changed_modules:
                lines.append(f"- **{module_name}**: API documentation updated")

        # 跳过 frontmatter（两个 "---" 之间），再找第一个 "## " 标题前插入
        # frontmatter 格式: "---\n...\n---\n"
        insert_marker = "\n## "
        fm_end = -1
        if existing.startswith("---"):
            second_dash = existing.find("\n---", 3)
            if second_dash != -1:
                fm_end = second_dash + 4  # 跳过 "\n---"
        search_from = fm_end if fm_end != -1 else 0
        idx = existing.find(insert_marker, search_from)
        if idx == -1:
            new_content = existing + "\n".join(lines) + "\n"
        else:
            new_content = existing[:idx] + "\n".join(lines) + "\n" + existing[idx:]
        changelog_file.write_text(new_content, encoding="utf-8")

    print(f"  📝 changelog.md 已更新（{len(changed_modules)} 个模块）")


# ============================================================
# 核心流程
# ============================================================

def sync_module(module_name: str, force: bool = False) -> bool:
    """同步单个模块的文档，返回是否实际发生了更新"""
    if module_name not in MODULE_DOC_MAP:
        return False

    # 找到模块目录
    module_dir = None
    for candidate in INTERFACE_SRC.rglob(module_name):
        if candidate.is_dir():
            module_dir = candidate
            break

    if not module_dir:
        print(f"  ⚠️  找不到模块目录: {module_name}")
        return False

    # 检查是否需要更新
    cache = load_cache()
    h_files = list(module_dir.rglob("*.h"))
    current_hashes = {str(f): file_hash(f) for f in h_files}
    cached_hashes = cache.get(module_name, {})

    if not force and current_hashes == cached_hashes:
        return False  # 无变化

    _, zh_name, _ = MODULE_DOC_MAP[module_name]
    print(f"\n🔄 同步模块: {module_name}（{zh_name}）")

    # 生成中英文文档
    for lang in ("zh", "en"):
        try:
            content = generate_doc(module_name, module_dir, lang)
            write_doc(module_name, content, lang)
        except Exception as e:
            print(f"  ❌ 生成 [{lang}] 失败: {e}")
            return False

    # 更新缓存
    cache[module_name] = current_hashes
    save_cache(cache)
    return True


def scan_and_sync(force: bool = False):
    """扫描所有模块，同步有变化的文档"""
    print(f"🔍 扫描 TopStepInterfaceKit 变更...")
    updated: list[tuple[str, str]] = []

    for module_name in MODULE_DOC_MAP:
        did_update = sync_module(module_name, force=force)
        if did_update:
            _, zh_name, _ = MODULE_DOC_MAP[module_name]
            updated.append((module_name, zh_name))

    if updated:
        append_changelog(updated)
        print(f"\n✨ 完成，共更新 {len(updated)} 个模块文档")
    else:
        print("✅ 所有文档已是最新，无需更新")


def sync_from_file(file_path_str: str):
    """根据 .h 文件路径同步对应模块"""
    file_path = Path(file_path_str).resolve()
    result = find_module_dir(file_path)
    if not result:
        # 不是 TopStepInterfaceKit 的 .h 文件，静默忽略
        return

    module_name, module_dir = result
    did_update = sync_module(module_name, force=True)
    if did_update:
        _, zh_name, _ = MODULE_DOC_MAP[module_name]
        append_changelog([(module_name, zh_name)])


def watch_mode(interval: int = 3):
    """轮询检测 .h 文件变化，自动同步（适用于在 Xcode 中修改的场景）"""
    print(f"👁  Watch 模式启动，每 {interval} 秒检测一次变化...")
    print(f"   监听目录: {INTERFACE_SRC}")
    print("   按 Ctrl+C 退出\n")

    cache = load_cache()

    while True:
        try:
            updated: list[tuple[str, str]] = []
            for module_name in MODULE_DOC_MAP:
                module_dir = None
                for candidate in INTERFACE_SRC.rglob(module_name):
                    if candidate.is_dir():
                        module_dir = candidate
                        break
                if not module_dir:
                    continue

                h_files = list(module_dir.rglob("*.h"))
                current_hashes = {str(f): file_hash(f) for f in h_files}
                if current_hashes != cache.get(module_name, {}):
                    did_update = sync_module(module_name, force=True)
                    if did_update:
                        _, zh_name, _ = MODULE_DOC_MAP[module_name]
                        updated.append((module_name, zh_name))
                        cache[module_name] = current_hashes

            if updated:
                append_changelog(updated)

            time.sleep(interval)
        except KeyboardInterrupt:
            print("\n👋 Watch 模式已退出")
            break


def hook_mode():
    """被 Claude Code PostToolUse Hook 调用：从 stdin 读取事件 JSON"""
    import sys as _sys
    try:
        data = json.load(_sys.stdin)
    except Exception:
        return  # 非 JSON 或空输入，静默退出

    tool_name = data.get("tool_name", "")
    if tool_name not in ("Edit", "Write"):
        return

    tool_input = data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")
    if not file_path or not file_path.endswith(".h"):
        return

    sync_from_file(file_path)


# ============================================================
# CLI 入口
# ============================================================

def main():
    parser = argparse.ArgumentParser(description="TopStepComKit SDK 文档同步工具")
    parser.add_argument("--file", metavar="PATH", help="同步指定 .h 文件对应的模块")
    parser.add_argument("--watch", action="store_true", help="监听变化，自动同步（轮询）")
    parser.add_argument("--all", action="store_true", dest="force_all", help="强制同步所有模块")
    parser.add_argument("--hook", action="store_true", help="Claude Code Hook 模式（读取 stdin）")
    parser.add_argument("--interval", type=int, default=3, help="Watch 模式轮询间隔（秒）")
    args = parser.parse_args()

    if args.hook:
        hook_mode()
    elif args.file:
        sync_from_file(args.file)
    elif args.watch:
        watch_mode(interval=args.interval)
    elif args.force_all:
        scan_and_sync(force=True)
    else:
        scan_and_sync(force=False)


if __name__ == "__main__":
    main()
