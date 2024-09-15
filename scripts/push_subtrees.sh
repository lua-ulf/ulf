#!/bin/sh

git subtree push --prefix=deps/ulf.async ulf-async-upstream main
git subtree push --prefix=deps/ulf.core ulf-core-upstream main
git subtree push --prefix=deps/ulf.doc ulf-doc-upstream main
git subtree push --prefix=deps/ulf.lib ulf-lib-upstream main
git subtree push --prefix=deps/ulf.log ulf-log-upstream main
git subtree push --prefix=deps/ulf.sys ulf-sys-upstream main
git subtree push --prefix=deps/ulf.test ulf-test-upstream main
git subtree push --prefix=deps/ulf.util ulf-util-upstream main
git subtree push --prefix=deps/ulf.vim ulf-vim-upstream main
