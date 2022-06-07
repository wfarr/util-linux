# Building

1. Clone this repository and get on this branch
1. vagrant up
1. Then:

```
sudo su -
cd
git clone https://github.com/wfarr/util-linux.git -b <this branch>

cd util-linux/
./autogen.sh

# this may fail a few times, keep installing deps until it passes

debuild -i -us -uc -b
```
