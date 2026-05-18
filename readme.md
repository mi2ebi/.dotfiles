to setup on a new device:

```sh
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/mi2ebi/.dotfiles tmpdotfiles
rsync -vr --exclude .git tmpdotfiles $HOME 
rm -r tmpdotfiles
```
