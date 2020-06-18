# kernel

参考《操作系统真相还原》一书编写的代码，实验环境：Ubuntu 16.04 x64，实验文章在我的blog中，文件结构如下

```
.
├── boot
│   ├── include
│   │   └── boot.inc
│   ├── loader.S
│   └── mbr.S
├── build
│   ├── assert.o
│   ├── bitmap.o
│   ├── buildin_cmd.o
│   ├── console.o
│   ├── debug.o
│   ├── dir.o
│   ├── exec.o
│   ├── file.o
│   ├── fork.o
│   ├── fs.o
│   ├── ide.o
│   ├── init.o
│   ├── inode.o
│   ├── interrupt.o
│   ├── ioqueue.o
│   ├── kernel.bin
│   ├── kernel.map
│   ├── kernel.o
│   ├── keyboard.o
│   ├── list.o
│   ├── main.o
│   ├── memory.o
│   ├── pipe.o
│   ├── print.o
│   ├── process.o
│   ├── shell.o
│   ├── stdio-kernel.o
│   ├── stdio.o
│   ├── string.o
│   ├── switch.o
│   ├── sync.o
│   ├── syscall-init.o
│   ├── syscall.o
│   ├── thread.o
│   ├── timer.o
│   ├── tss.o
│   └── wait_exit.o
├── command
│   ├── cat
│   ├── cat.c
│   ├── cat.o
│   ├── compile.sh
│   ├── simple_crt.a
│   ├── start.o
│   └── start.S
├── device
│   ├── console.c
│   ├── console.h
│   ├── ide.c
│   ├── ide.h
│   ├── ioqueue.c
│   ├── ioqueue.h
│   ├── keyboard.c
│   ├── keyboard.h
│   ├── timer.c
│   └── timer.h
├── fs
│   ├── dir.c
│   ├── dir.h
│   ├── file.c
│   ├── file.h
│   ├── fs.c
│   ├── fs.h
│   ├── inode.c
│   ├── inode.h
│   └── super_block.h
├── kernel
│   ├── debug.c
│   ├── debug.h
│   ├── global.h
│   ├── init.c
│   ├── init.h
│   ├── interrupt.c
│   ├── interrupt.h
│   ├── kernel.S
│   ├── main.c
│   ├── memory.c
│   └── memory.h
├── lib
│   ├── kernel
│   │   ├── bitmap.c
│   │   ├── bitmap.h
│   │   ├── io.h
│   │   ├── list.c
│   │   ├── list.h
│   │   ├── print.h
│   │   ├── print.S
│   │   ├── stdio-kernel.c
│   │   └── stdio-kernel.h
│   ├── stdint.h
│   ├── stdio.c
│   ├── stdio.h
│   ├── string.c
│   ├── string.h
│   └── user
│       ├── assert.c
│       ├── assert.h
│       ├── syscall.c
│       └── syscall.h
├── makefile
├── shell
│   ├── buildin_cmd.c
│   ├── buildin_cmd.h
│   ├── pipe.c
│   ├── pipe.h
│   ├── shell.c
│   └── shell.h
├── thread
│   ├── switch.S
│   ├── sync.c
│   ├── sync.h
│   ├── thread.c
│   └── thread.h
└── userprog
    ├── exec.c
    ├── exec.h
    ├── fork.c
    ├── fork.h
    ├── process.c
    ├── process.h
    ├── syscall-init.c
    ├── syscall-init.h
    ├── tss.c
    ├── tss.h
    ├── wait_exit.c
    └── wait_exit.h

13 directories, 119 files
```

