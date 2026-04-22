#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TEMPLATE_DIR="$SCRIPT_DIR/init-templates"
TEMPLATE_HOOKS_DIR="$TEMPLATE_DIR/hooks"
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'

git config --global init.templateDir "$TEMPLATE_DIR" || printf -- "${RED}❌ 错误: 设置 Git 全局模板目录失败${NC}\n"

TARGET_DIR="$1"
[[ -z "$TARGET_DIR" ]] && exit 0
[[ ! -d "$TARGET_DIR" ]] && { printf -- "${RED}❌ 错误: 路径无效${NC}\n"; exit 1; }

shopt -s nullglob
SUCCESS_COUNT=0

for repo in "$TARGET_DIR"/*/; do
    repo=${repo%/}
    dirname="${repo##*/}"
    [[ "$dirname" == .* ]] && continue
    
    if [[ -d "$repo/.git" ]]; then
        printf -- "${CYAN}📂 处理中: %s${NC}\n" "$dirname"
        
        # 1. 物理替换 Hooks
        rm -rf "$repo/.git/hooks"
        cp -a "$TEMPLATE_HOOKS_DIR" "$repo/.git/hooks"
        
        # 2. 只有在有配置且有工具时才执行 install
        (
            cd "$repo" || exit
            # 定义查找顺序
            BIN_ORDER=(
                "./.venv/bin/prek"
                "./.venv/bin/pre-commit"
                "$(command -v prek)"
                "$(command -v pre-commit)"
            )

            if [[ -f ".pre-commit-config.yaml" ]]; then
                for CMD in "${BIN_ORDER[@]}"; do
                    if [[ -x "$CMD" ]]; then
                        "$CMD" install &>/dev/null
                        printf -- "   ${GREEN}✨ Hooks 部署成功${NC}\n"
                        break
                    fi
                done
            fi
        )
        ((SUCCESS_COUNT++))
    fi
done

printf -- "------------------------------------------------\n"
printf -- "${GREEN}🎉 搞定！共更新了 %d 个仓库${NC}\n" "$SUCCESS_COUNT"
