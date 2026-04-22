# pai-hooks

通过 Git template 自动安装 `pre-commit` / `prek` hook。

我主要是想解决一个很烦的问题：每个项目都要手动跑一次 `pre-commit install` 或 `prek install`，很容易忘。一旦忘了，本地提交就可能绕过检查，等 CI 或别人发现时已经晚了。

这个仓库把常用 hooks 放进 Git template 里。配置好之后，新 clone / init 出来的仓库会自动带上这些 hooks；在 checkout 时，也会根据项目里的 `.pre-commit-config.yaml` 自动尝试安装 `pre-commit` 或 `prek` hook。

默认 hook 也保留了 Git LFS 的逻辑，所以对使用 LFS 的仓库是兼容的。

核心是这条全局配置：

```bash
git config --global init.templateDir /path/to/this-repo/init-templates
```

`git-hooks.sh` 会帮我设置这条配置。设置后，它会影响之后所有 `git init` / `git clone` 出来的仓库。

## 做了什么

- 使用 `init-templates/hooks` 维护统一的 Git hooks 模板。
- 通过 `git-hooks.sh` 设置 `git config --global init.templateDir`。
- 新仓库自动带上默认 hooks。
- checkout 时自动尝试安装 `pre-commit` / `prek` hook。
- 可以批量把模板 hooks 同步到已有仓库。
- 默认兼容 Git LFS。

## 使用

只配置 Git template，用来解决之后新 clone / init 的仓库：

```bash
bash git-hooks.sh
```

这一步会设置 `git config --global init.templateDir`。之后新 clone / init 出来的仓库，会自动带上 `init-templates/hooks` 里的默认 hooks。

如果仓库已经 clone 过了，Git template 不会回头修改这些已有仓库。对已有仓库所在的父级目录执行：

```bash
bash git-hooks.sh /path/to/repos-parent-dir
```

这里传的是“仓库父级目录”。脚本会先设置全局 Git template，然后只处理这个目录下面第一层子目录里的 Git 仓库，把模板 hooks 同步到它们的 `.git/hooks`，不会递归扫描更深层目录。

之后正常 clone / init 仓库即可。

## 安装多个 hook

脚本只会执行基础的 `pre-commit install` / `prek install`。

如果一个项目希望安装多个 hook 类型，比如同时安装 `pre-commit`、`pre-push`、`commit-msg`，应该在项目自己的 `.pre-commit-config.yaml` 里配置 `default_install_hook_types`：

```yaml
default_install_hook_types:
  - pre-commit
  - pre-push
  - commit-msg
```

这样自动 install 时就会按项目配置安装对应的 hooks。
