#!/usr/bin/env bash
# ============================================================
# pi-web 中文版 升级脚本（翻译永不丢失）
# ------------------------------------------------------------
# 作用：从官方上游拉取最新代码，合并到你的中文 fork，
#       重新构建并安装为全局 pi-web 命令。
#       你提交在 fork 里的中文翻译会通过 git 合并保留下来。
#
# 用法：
#   bash scripts/cn-upgrade.sh
#
# 前置：
#   - 已配置 gh CLI 登录（git 凭证）
#   - remote: origin=你的fork, upstream=官方 agegr/pi-web
#   - 运行前请先关闭正在运行的 pi-web（否则全局安装会因文件占用失败）
# ============================================================
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

echo "==> [1/6] 拉取官方上游更新"
git fetch upstream

echo "==> [2/6] 合并 upstream/main 到本地 main"
echo "    （若翻译行与上游改动冲突，请手动解决后重新运行本脚本剩余步骤）"
git merge upstream/main --no-edit || {
  echo ""
  echo "!! 合并出现冲突。请编辑冲突文件、保留中文翻译，然后执行："
  echo "   git add -A && git commit --no-edit"
  echo "   再手动运行： npm install --legacy-peer-deps && npm run build && npm install -g --legacy-peer-deps ."
  exit 1
}

echo "==> [3/6] 安装依赖"
npm install --legacy-peer-deps

echo "==> [4/6] 构建（webpack，产出中文界面产物）"
npm run build

echo "==> [5/6] 安装为全局 pi-web 命令"
npm install -g --legacy-peer-deps .

echo "==> [6/6] 推送合并结果到你的 fork（备份翻译）"
git push origin main || echo "（推送失败可稍后手动 git push origin main）"

echo ""
echo "✅ 升级完成！现在任意终端运行 pi-web 即为最新中文版。"
