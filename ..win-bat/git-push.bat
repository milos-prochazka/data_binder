cd ..
if .%1.==.. goto syntax

dart-format .\ 2
dart-prep --enable-all .\

rem del /s *.bak

git add --all
git commit --all -m %1
rem git push origin master --force
git push --recurse-submodules=check --progress "origin" HEAD:refs/heads/master --force
pause

git gc
git gc --aggressive
git prune

goto end

:syntax
@echo Syntax: git-push "message"
:end
