# -*- coding: utf-8 -*-
"""把华盛达页面的新文件注册进 project.pbxproj（幂等：已存在的引用跳过）。"""
import re, sys

path = sys.argv[1]
s = open(path, encoding="utf-8").read()

HUB_GROUP = "5AD0000000000000000000A1"     # Huashengda
COMMON_GROUP = "5AD0000000000000000000A2"  # Huashengda/Common
SOURCES_PHASE_ANCHOR = "5AD0000000000000000000B3 /* TSHuashengdaVC.m in Sources */,"

# 子目录组：name -> (groupId, files)
GROUPS = {
    "ParentalMode": ("5AD0000000000000000000A3", ["TSHsdParentalModeVC"]),
    "ClassroomMode": ("5AD0000000000000000000A4", ["TSHsdClassroomModeVC"]),
    "Task": ("5AD0000000000000000000A5", ["TSHsdTaskVC", "TSHsdTaskEditorVC"]),
    "Habit": ("5AD0000000000000000000A6", ["TSHsdHabitVC", "TSHsdHabitEditorVC"]),
    "Usage": ("5AD0000000000000000000A7", ["TSHsdUsageVC"]),
    "Game": ("5AD0000000000000000000A8", ["TSHsdGameVC"]),
    "Ice": ("5AD0000000000000000000A9", ["TSHsdIceVC"]),
    "Tools": ("5AD0000000000000000000AA", ["TSHsdBoundaryToolsVC"]),
}
COMMON_FILES = ["TSHsdDisplay", "TSHsdErrorText", "TSHsdCallLog", "TSHsdCallLogVC", "TSHsdLocalCache", "TSHsdViews",
                "TSHsdWeekdayView", "TSHsdTimelineView", "TSHsdDock", "TSHsdSheet", "TSHsdReadbackDiff", "TSHsdBaseVC"]

counter = [0x100]
def new_id():
    counter[0] += 1
    return "5AD00000000000000000%04X" % counter[0]

file_refs, build_files, sources = [], [], []
group_children = {COMMON_GROUP: [], HUB_GROUP: []}

def register(base, group_id):
    if ("/* %s.m */ = {isa = PBXFileReference" % base) in s:
        return
    h_id, m_id, b_id = new_id(), new_id(), new_id()
    file_refs.append('\t\t%s /* %s.h */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = %s.h; sourceTree = "<group>"; };' % (h_id, base, base))
    file_refs.append('\t\t%s /* %s.m */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.objc; path = %s.m; sourceTree = "<group>"; };' % (m_id, base, base))
    build_files.append('\t\t%s /* %s.m in Sources */ = {isa = PBXBuildFile; fileRef = %s /* %s.m */; };' % (b_id, base, m_id, base))
    sources.append('\t\t\t\t%s /* %s.m in Sources */,' % (b_id, base))
    group_children.setdefault(group_id, []).extend(['\t\t\t\t%s /* %s.h */,' % (h_id, base), '\t\t\t\t%s /* %s.m */,' % (m_id, base)])

for base in COMMON_FILES:
    register(base, COMMON_GROUP)

new_groups = []
for name, (gid, files) in GROUPS.items():
    if ("%s /* %s */ = {" % (gid, name)) in s:
        continue
    for base in files:
        register(base, gid)
    children = "\n".join(group_children.get(gid, []))
    new_groups.append("\t\t%s /* %s */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n%s\n\t\t\t);\n\t\t\tpath = %s;\n\t\tsourceTree = \"<group>\";\n\t\t};" % (gid, name, children, name))
    group_children[HUB_GROUP].append('\t\t\t\t%s /* %s */,' % (gid, name))

def insert_after(text, anchor, payload):
    idx = text.index(anchor) + len(anchor)
    return text[:idx] + "\n" + payload + text[idx:]

# PBXBuildFile
if build_files:
    s = insert_after(s, "/* Begin PBXBuildFile section */", "\n".join(build_files))
# PBXFileReference
if file_refs:
    s = insert_after(s, "/* Begin PBXFileReference section */", "\n".join(file_refs))
# PBXGroup：新组 + 挂到 Huashengda / Common
if new_groups:
    s = insert_after(s, "/* Begin PBXGroup section */", "\n".join(new_groups))
for gid, children in group_children.items():
    if not children or gid not in (HUB_GROUP, COMMON_GROUP):
        continue
    m = re.search(r"(\t\t%s /\* [^*]+ \*/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n)" % gid, s)
    assert m, gid
    s = s[:m.end()] + "\n".join(children) + "\n" + s[m.end():]
# Sources build phase
if sources:
    s = insert_after(s, SOURCES_PHASE_ANCHOR, "\n".join(sources))

open(path, "w", encoding="utf-8").write(s)
print("added files:", len(build_files), "groups:", len(new_groups))
