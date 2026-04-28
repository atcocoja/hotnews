#!/usr/bin/env bash
set -euo pipefail

# 生产文件完整性检查脚本
# 检查选题目录下的所有生产文件是否完整、符合规范

show_usage() {
  cat <<EOF
用法: scripts/tools/check-production.sh <选题目录>

检查一个选题目录的生产文件完整性。

示例:
  scripts/tools/check-production.sh outputs/N05-zhao-murphy-snooker-semifinal

检查项：
- 8个必需文件是否存在
- 文件中的关键字段是否填写
- 时长、段数是否符合项目标准
- 是否避免精确真人面部
- 日期是否使用绝对日期

EOF
}

if [[ $# -lt 1 ]]; then
  show_usage
  exit 1
fi

TARGET_DIR="$1"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "❌ 错误：目录不存在 $TARGET_DIR"
  exit 1
fi

echo "🔍 检查选题生产文件"
echo "===================="
echo "目录: $TARGET_DIR"
echo ""

# 检查必需文件
REQUIRED_FILES=(
  "00-source-log.md"
  "01-topic-card.md"
  "02-script.md"
  "03-image-prompts.md"
  "04-seedance-prompts.md"
  "05-publish-copy.md"
  "06-assets-manifest.md"
  "07-production-checklist.md"
)

MISSING_FILES=()
PRESENT_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
  if [[ -f "$TARGET_DIR/$file" ]]; then
    PRESENT_FILES+=("$file")
  else
    MISSING_FILES+=("$file")
  fi
done

echo "📁 文件完整性检查"
echo "必需文件: ${#REQUIRED_FILES[@]}"
echo "已存在: ${#PRESENT_FILES[@]}"
echo "缺失: ${#MISSING_FILES[@]}"

if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
  echo ""
  echo "❌ 缺失文件:"
  for file in "${MISSING_FILES[@]}"; do
    echo "  - $file"
  done
fi

echo ""

# 如果文件不完整，提前退出
if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
  echo "⚠️ 文件不完整，请先生成所有必需文件"
  exit 1
fi

echo "✅ 所有必需文件存在"
echo ""

# 检查关键字段
echo "📋 关键字段检查"
echo ""

# 检查 01-topic-card.md
echo "检查 01-topic-card.md..."
TOPIC_CARD="$TARGET_DIR/01-topic-card.md"

if grep -q "recommended_duration:.*1[23][0-9]\\|1[45][0-9]\\|180" "$TOPIC_CARD"; then
  echo "  ✅ 推荐时长符合 120-180 秒标准"
else
  echo "  ⚠️ 推荐时长可能不符合 120-180 秒标准"
fi

if grep -q "recommended_segments:.*[89]\\|1[0-2]" "$TOPIC_CARD"; then
  echo "  ✅ 推荐段数符合 8-12 段标准"
else
  echo "  ⚠️ 推荐段数可能不符合 8-12 段标准"
fi

if grep -q "模型能力匹配度" "$TOPIC_CARD"; then
  echo "  ✅ 包含模型能力匹配度评估"
else
  echo "  ⚠️ 缺少模型能力匹配度评估"
fi

echo ""

# 检查 02-script.md
echo "检查 02-script.md..."
SCRIPT="$TARGET_DIR/02-script.md"

if grep -q "P10" "$SCRIPT"; then
  echo "  ✅ 脚本包含至少10段（符合150秒/10段标准）"
else
  echo "  ⚠️ 脚本段数可能不足（建议≥10段）"
fi

# 检查是否有绝对日期
if grep -qE "202[0-9]-[0-9]{2}-[0-9]{2}" "$SCRIPT"; then
  echo "  ✅ 使用绝对日期"
else
  echo "  ⚠️ 可能未使用绝对日期（请避免'今天'/'昨天'）"
fi

echo ""

# 检查 03-image-prompts.md
echo "检查 03-image-prompts.md..."
IMAGE_PROMPTS="$TARGET_DIR/03-image-prompts.md"

if grep -q "禁止项" "$IMAGE_PROMPTS"; then
  echo "  ✅ 包含禁止项说明"
else
  echo "  ⚠️ 缺少禁止项说明"
fi

if grep -qE "不出现.*面部|无.*面部|避免.*面部" "$IMAGE_PROMPTS"; then
  echo "  ✅ 明确避免精确真人面部"
else
  echo "  ⚠️ 未明确避免精确真人面部（建议添加）"
fi

echo ""

# 检查 04-seedance-prompts.md
echo "检查 04-seedance-prompts.md..."
SEEDANCE_PROMPTS="$TARGET_DIR/04-seedance-prompts.md"

if grep -q "分镜声明" "$SEEDANCE_PROMPTS"; then
  echo "  ✅ 包含分镜声明"
else
  echo "  ⚠️ 缺少分镜声明"
fi

if grep -q "【风格】" "$SEEDANCE_PROMPTS" && grep -q "【时间轴】" "$SEEDANCE_PROMPTS"; then
  echo "  ✅ 使用结构化提示词格式"
else
  echo "  ⚠️ 结构化提示词格式可能不完整"
fi

echo ""

# 检查 06-assets-manifest.md
echo "检查 06-assets-manifest.md..."
ASSETS="$TARGET_DIR/06-assets-manifest.md"

if grep -q "图片数:" "$ASSETS"; then
  IMAGE_COUNT=$(grep "图片数:" "$ASSETS" | grep -oE "[0-9]+")
  if [[ $IMAGE_COUNT -le 9 ]]; then
    echo "  ✅ 图片数量≤9（符合Seedance限制）"
  else
    echo "  ⚠️ 图片数量>9（注意：Seedance单条视频最多9张图片参考）"
  fi
fi

echo ""

# 检查 07-production-checklist.md
echo "检查 07-production-checklist.md..."
CHECKLIST="$TARGET_DIR/07-production-checklist.md"

# 统计已勾选项
CHECKED_COUNT=$(grep -c "^- \[x\]" "$CHECKLIST" || true)
TOTAL_COUNT=$(grep -c "^- \[" "$CHECKLIST" || true)
COMPLETION_RATE=$((CHECKED_COUNT * 100 / TOTAL_COUNT))

echo "  生产检查完成度: $CHECKED_COUNT / $TOTAL_COUNT ($COMPLETION_RATE%)"

if [[ $COMPLETION_RATE -ge 80 ]]; then
  echo "  ✅ 检查完成度良好（≥80%）"
elif [[ $COMPLETION_RATE -ge 50 ]]; then
  echo "  ⚠️ 检查完成度中等（建议补充）"
else
  echo "  ❌ 检查完成度较低（请完成检查）"
fi

echo ""
echo "===================="
echo "✅ 检查完成"
echo ""
echo "💡 建议："
if [[ $COMPLETION_RATE -lt 100 ]]; then
  echo "  - 补充 07-production-checklist.md 中未勾选项"
fi
echo "  - 确保所有文件中的日期使用绝对日期格式"
echo "  - 确保所有提示词明确避免精确真人面部"
echo "  - 确保时长在 120-180 秒范围内"
echo ""
