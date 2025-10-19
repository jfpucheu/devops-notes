# 🧠 Git Cheat Sheet --- Essential Commands

## ⚙️ Initial Configuration

``` bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --list
```

## 📂 Create or Clone a Repository

``` bash
git init
git clone https://github.com/user/project.git
```

## 🔄 Track Changes

``` bash
git status
git add file.txt
git add .
git diff
```

## 💾 Save Changes (Commits)

``` bash
git commit -m "Clear commit message"
git commit -am "Message"
```

## 🧩 History and Tracking

``` bash
git log
git log --oneline --graph --decorate
git show <hash>
```

## 🌿 Branches

``` bash
git branch
git branch new-branch
git checkout new-branch
git switch -c new-branch
git merge other-branch
git branch -d branch
```

## ☁️ Working with a Remote Repository

``` bash
git remote -v
git remote add origin https://github.com/user/project.git
git push -u origin main
git pull
git fetch
```

## ♻️ Undo / Fix Changes

``` bash
git restore file.txt
git restore --staged file.txt
git reset --hard HEAD
git revert <hash>
```

## 🧼 Clean Up

``` bash
git clean -fd
```

## 📦 Useful Commands

``` bash
git stash
git stash pop
git tag v1.0
```
