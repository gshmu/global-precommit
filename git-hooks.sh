#!/bin/bash

TEMPLATE_HOOKS_DIR="init-templates/hooks"
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'

TARGET_DIR="$1"
[[ -z "$TARGET_DIR" || ! -d "$TARGET_DIR" ]] && { printf -- "${RED}❌ 错误: 路径无效${NC}\n"; exit 1; }

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
            # 简单的优先级逻辑
            [[ -x "./.venv/bin/prek" ]] && EXE="./.venv/bin/prek" || EXE="./.venv/bin/pre-commit"

            if [[ -x "$EXE" && -f ".pre-commit-config.yaml" ]]; then
                "$EXE" install &>/dev/null
                printf -- "   ${GREEN}✨ Hooks 部署成功${NC}\n"
            fi
        )
        ((SUCCESS_COUNT++))
    fi
done

printf -- "------------------------------------------------\n"
printf -- "${GREEN}🎉 搞定！共更新了 %d 个仓库${NC}\n" "$SUCCESS_COUNT"
