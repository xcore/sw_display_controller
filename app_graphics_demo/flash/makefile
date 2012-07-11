xnfile ?= ../src/ZLG_MTX110E16_400.xn
specpath ?= ../src

all:
	xcc "$(xnfile)" -I$(specpath) -g -O3 -Wcodes -Xmapper -Wcodes -lflash connect.xc programmer.c -o programmer.xe

verbose:
	xcc "$(xnfile)" -I$(specpath) -g -O3 -Wcodes -Xmapper -Wcodes -lflash connect.xc programmer.c -o programmer.xe -DVERBOSE
