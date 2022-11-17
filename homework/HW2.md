# HW2: shell

Download the sh.c and then implement the features.

method 1: directly type in tty
```sh
$ ./a.out

ls > y
cat < y | sort | uniq | wc > y1
cat y1
rm y1
ls | sort | uniq | wc
rm y
```
method 2: use `t.sh` to execute the commands
```sh
$ ./a.out < t.sh
```

## Coding
Code base on `sh.c`. Read it and Complete it.

`main()` read commands, fork a sub-process for each command. And then call `parsecmd()` to parse command. Call `runcmd()` to execute the result of the `parsecmd()`.

### Parse

In parsecmd() call-link: parsecmd() -> parseline() -> parsepipe()

`parsepipe()` -> `parseexec()`, to parse first sub-command, return cmd structure; if there is pipe symbol '|', call itself recursively to parse later commands, return cmd structure; then call `pipecmd()` integrate the two structures into a pipeline cmd structure.


### Implemente

Because the parse part is diffcult to understand, I just skip it and read runcmd() instead.

parsecmd() parse cmd into three types: exec, pipe and redirect.

#### Executing simple commands
> hint: You may want to change the 6.828 shell to always try /bin, if the program doesn't exist in the current working directory, so that below you don't have to type "/bin" for each program. If you are ambitious you can implement support for a PATH variable.

for "ls", we need to lead command to folder "/bin/" to search. Key syscall:
```c
int access(const char * pathname, int mode) 
/*
R_OK      // 测试读许可权
W_OK      // 测试写许可权
X_OK      // 测试执行许可权
F_OK      // 测试文件是否存在
*/
```
now complete `' '` part:
```c
case ' ':
  ecmd = (struct execcmd*)cmd;
  if(ecmd->argv[0] == 0)
    _exit(0);
  //fprintf(stderr, "exec not implemented\n");
  // Your code here ...
  if(access(ecmd->argv[0], F_OK) == 0) {
    execv(ecmd->argv[0], ecmd->argv);
  }
  else {
    const char* BinPath = "/bin/";
    int PathLen = strlen(BinPath) + strlen(ecmd->argv[0]);
    char* Abs_Path = (char*)malloc(PathLen+1);
    strcpy(Abs_Path, BinPath);
    strcat(Abs_Path, ecmd->argv[0]);
    if(access(Abs_Path, F_OK) == 0) {
      execv(Abs_Path, ecmd->argv);
    }
    else {
      fprintf(stderr, "%s Command not found\n", ecmd->argv[0]);
    }
  }
  break;
```


#### I/O redirection

```
echo "6.828 is cool" > x.txt
cat < x.txt
```

> hint: You might find the man pages for open and close useful.
> 
> file descriptor 0 (standard input); 
> 
> file descriptor 1 (standard output); 
> 
> file descriptor 2 (standard error)

```c
struct cmd*
redircmd(struct cmd *subcmd, char *file, int type)
{
    struct redircmd *cmd;
    
    cmd = malloc(sizeof(*cmd));
    memset(cmd, 0, sizeof(*cmd));
    cmd->type = type;
    cmd->cmd = subcmd;
    cmd->file = file;
    cmd->mode = (type == '<') ?  O_RDONLY : O_WRONLY|O_CREAT|O_TRUNC;
    cmd->fd = (type == '<') ? 0 : 1;
    return (struct cmd*)cmd;
}
```
As we can see, struct rcmd have been defined, if '>' `rcmd->fd = 1(stdout)`; if '<' `cmd->fd = 0(stdin)`. So we just need to close fd in rcmd, and open the file we need to read/write. So that system will allocate the lowest fd to the file. And then call `runcmd()`. Code as follows:

```c
case '>':
  case '<':
    rcmd = (struct redircmd*)cmd;
    //fprintf(stderr, "redir not implemented\n");
    // Your code here ...
    // fprintf(stdout, "rcmd->fd = %d\n", rcmd->fd);
    close(rcmd->fd);      // if > rcmd->fd = 1(stdout); if < cmd->fd = 0(stdin)
    if(open(rcmd->file, rcmd->flags, 0644) < 0) {  // redirect to stdin
      fprintf(stderr, "Unable to open file: %s\n", rcmd->file);
      exit(0);
    }
    runcmd(rcmd->cmd);
    break;
```

#### Pipe

system call `pipee(int p[])`, which creates a new pipe and records the read and write file descriptors in the array `p`. p[0] is read end, p[1] is write end.

system call `dup(int old_fd)`, which duplicates a file descriptor that point to where old_df point, the new fd will be the lowest free fd.

The following example code runs the program wc with standard input connected
to the read end of a pipe.
```c
int p[2];
char *argv[2];
argv[0] = "wc";
argv[1] = 0;
pipe(p);
if(fork() == 0) {
close(0);
dup(p[0]);
close(p[0]);
close(p[1]);
exec("/bin/wc", argv);
} else {
close(p[0]);
write(p[1], "hello world\n", 12);
close(p[1]);
}
```
The program calls pipe, which creates a new pipe and records the read and write file
descriptors in the array p. After fork, both parent and child have file descriptors referring to the pipe. The child dups the read end onto file descriptor 0, closes the file descriptors in p, and execs wc. When wc reads from its standard input, it reads from the pipe. The parent closes the read side of the pipe, writes to the pipe, and then closes the write side.



```c
struct pipecmd {
  int type;          // |
  struct cmd *left;  // left side of pipe
  struct cmd *right; // right side of pipe
};
```

