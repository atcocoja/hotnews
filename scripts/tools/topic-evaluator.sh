#!/usr/bin/env bash
set -euo pipefail

# 选题评估脚本
# 根据项目核心原则评估一个热点话题是否值得制作
# 第一优先级：模型能力匹配度

show_usage() {
  cat <<EOF
用法: scripts/tools/topic-evaluator.sh

交互式评估一个热点话题是否符合项目要求。

评估维度：
1. 模型能力匹配度（最重要）
2. 画面生成难度
3. 人物面部依赖度
4. 叙事完整性
5. 时长适配性

EOF
}

# 评分计算
MODEL_FIT_MIN=60
TOTAL_MIN=200

echo "📊 热点话题选题评估工具"
echo "===================="
echo ""

# 收集基本信息
echo "📝 话题基本信息"
read -p "话题标题: " TOPIC_TITLE
read -p "热度来源（微博/抖音/小红书）: " HOT_SOURCE
read -p "热度值/排名: " HOT_VALUE
echo ""

# 评估维度1：模型能力匹配度（权重40%）
echo "🎯 维度1：模型能力匹配度（权重40%）"
echo "这个话题能充分发挥 image-2 和 Seedance 2.0 的优势吗？"
echo ""
read -p "画面生成难度（1=很难，5=很容易）: " IMAGE_SCORE
read -p "动作/运动表现需求（1=静态为主，5=丰富动态）: " MOTION_SCORE
read -p "风格一致性要求（1=很难统一，5=容易统一）: " STYLE_SCORE
MODEL_FIT=$((IMAGE_SCORE * 10 + MOTION_SCORE * 8 + STYLE_SCORE * 8))
echo "模型能力匹配度得分: $MODEL_FIT / 120"
echo ""

# 评估维度2：人物面部依赖度（权重30%，越低越好）
echo "👤 维度2：人物面部依赖度（权重30%，反向计分）"
echo "AI生成精确真人面部有风险，依赖度越低越好"
echo ""
read -p "是否需要精确还原特定人物面部（1=不需要，5=必须精确）: " FACE_NEED
read -p "能否用背影/侧影/剪影替代（1=完全可以，5=无法替代）: " FACE_AVOID
FACE_RISK=$(( (5 - FACE_NEED) * 15 + (5 - FACE_AVOID) * 10 ))
echo "人物面部风险得分: $FACE_RISK / 125（越高越好）"
echo ""

# 评估维度3：叙事完整性（权重20%）
echo "📖 维度3：叙事完整性（权重20%）"
echo ""
read -p "故事是否有明确起承转合（1=模糊，5=清晰）: " STORY_SCORE
read -p "是否有戏剧性反转/冲突（1=平淡，5=强烈）: " DRAMA_SCORE
STORY_QUALITY=$((STORY_SCORE * 8 + DRAMA_SCORE * 8))
echo "叙事完整性得分: $STORY_QUALITY / 80"
echo ""

# 评估维度4：时长适配性（权重10%）
echo "⏱️ 维度4：时长适配性（权重10%）"
echo "2-3分钟能讲清楚吗？"
echo ""
read -p "信息量是否适中（1=过少或过多，5=刚好）: " LENGTH_FIT
read -p "是否有明确结尾（1=没有，5=有）: " ENDING_SCORE
LENGTH_SCORE=$((LENGTH_FIT * 6 + ENDING_SCORE * 6))
echo "时长适配性得分: $LENGTH_SCORE / 60"
echo ""

# 计算总分
TOTAL_SCORE=$((MODEL_FIT + FACE_RISK + STORY_QUALITY + LENGTH_SCORE))
MAX_SCORE=385
PERCENTAGE=$((TOTAL_SCORE * 100 / MAX_SCORE))

echo ""
echo "===================="
echo "📊 评估结果"
echo "===================="
echo "话题: $TOPIC_TITLE"
echo "来源: $HOT_SOURCE"
echo "热度: $HOT_VALUE"
echo ""
echo "总分: $TOTAL_SCORE / $MAX_SCORE ($PERCENTAGE%)"
echo ""

# 判断是否通过
if [ $PERCENTAGE -ge 70 ]; then
  echo "✅ 推荐制作"
  if [ $MODEL_FIT -lt $MODEL_FIT_MIN ]; then
    echo "⚠️ 警告：模型能力匹配度偏低（$MODEL_FIT < $MODEL_FIT_MIN），需谨慎"
  fi
elif [ $PERCENTAGE -ge 50 ]; then
  echo "⚠️ 谨慎考虑"
  echo "模型能力匹配度: $MODEL_FIT / 120 (建议≥$MODEL_FIT_MIN)"
  echo "人物面部风险: $FACE_RISK / 125"
  echo "建议：如果匹配度偏低，可以考虑其他话题"
else
  echo "❌ 不推荐制作"
  echo "主要原因："
  if [ $MODEL_FIT -lt $MODEL_FIT_MIN ]; then
    echo "  - 模型能力匹配度过低（$MODEL_FIT < $MODEL_FIT_MIN）"
  fi
  if [ $FACE_RISK -lt 50 ]; then
    echo "  - 人物面部依赖度过高（AI生成精确面部风险大）"
  fi
  if [ $STORY_QUALITY -lt 40 ]; then
    echo "  - 叙事结构不够清晰"
  fi
fi

echo ""
echo "💡 建议："
if [ $IMAGE_SCORE -le 2 ]; then
  echo "  - 画面生成难度较高，考虑简化场景或使用抽象风格"
fi
if [ $MOTION_SCORE -ge 4 ]; then
  echo "  - 动态需求丰富，充分发挥 Seedance 2.0 的视频生成能力"
fi
if [ $FACE_NEED -ge 4 ]; then
  echo "  - ⚠️ 需要精确人物面部，建议用背影/侧影/剪影替代"
fi
if [ $STORY_SCORE -le 2 ]; then
  echo "  - 叙事结构需要优化，建议增加转折或冲突"
fi
echo ""
