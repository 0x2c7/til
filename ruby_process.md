# Processes in Unix system and how to handle them in Ruby

In unix system, everything process has a unique process id (called pid). The pid is unique at runtime. It means that two processes at a random moment doesn't have a common pid

- Every process is spawned from another process. That process is called parent process. It is identified with Parent Process Id (`ppid`). The process spawning happens every where. For example, when starting a terminal, a process is spawn by the operating system with pid `a`. Then, in this terminal, we start a Ruby IRB, it creates a process with pid `b` and its parent is `a`. In the IRB, we spawn another process with pid `c`, and of course its parent is `b`.

- Everything in the Unix-like systems is considered to be a file, from hard drive to a network socket. Whenever a resource touch that file (aka resource), that process holds a unique file descriptor for that file. The file descriptor is the least unused value in the whole process. This mechanism is used to manage the resources used by a process. File descriptor is different between processes and nearly has no relation. Whenever a resource is closed, the file descriptor is clean. STDIN, STDOUT, STDERR are the primary resources used by the process. Each process has a particular limit for resource using, such as the number of concurrent resource reading, concurrent running process of a user.

- Each process has a set of environment variables. These variables belong to a particular process and its children. Two processes don't share the environment variables.

- After running, the processes return a status code, typically, it denotes the running result of the process. By convention, 0 means that "No error", otherwise, the system is considered to have some error in runtime

- A process could *Fork* to spawn a copy of the current process. It inherit a copy of all memory used by the parent process and file descriptor of the parent process. The newly created process is child and it considers parent process as the currently running process.

- A careless fork could raise many problems with the system. For example, exhaust the memory of the whole system, create orphan processes, etc. Orphan processes are the one whose parents are dead for some reason. Ideally, all the child processes must be cleaned up after the parent is dead. However, if the parent forgets to clean up or even the clean up code has problem, orphan processes are born.

- It is fun that Daemon processes are the Intentionally Orphan Processes. It means that their parents are killed intentionally so that it will run forever (how cruel is that :D)

- Process Forking is costly, especially when the parent has a heavy memory footprint. That's why the kernel use Copy-on-Write mechanism to increase the speed of the whole system. In detail, all things belong to memory are not copy until it is modify. Read operators are fine.

- In ruby, the default behavior is that the parent stops whenever it finishes its job. It doesn't care its children. To wait for all the children to stop before top, we use `Process.wait`. This method returns the pid of the currently stop process. If there are more than one child process, we must call `Process.wait` multiple times. The return value of this method is the pid of recently stopped process. Besides this method, we have `Process.wait2`. This methods return `[pid, status]` of the process. We could specific which pid to wait for with `Process.waitpid` and `Process.waitpid2`

- On the contrary of the orphan process situation, zombie processes are the ones that finished their jobs but still not killed because its parent has not finished its job. The kernel must wait for the parent to finish and then kill the child processes. If the parent runs for a long time or even run forever (daemon for example), zombie processes become a huge waste of resource. To solve this with Ruby, use `Process.detach`.

- When a child process die, it will send CHLD signal to the parent process. It is good to trap for this signal and handle the signal in background in case we want the parent to do heavy works while still wait for the child processes. Notice the case that there are many signals sent at once.

- Signal is a simple pice of information (usually a number) that a process sends to other process. At the beginning, it is just a way to identify the way to kill a process from other process. This signal could be trap and handle as the wish of the process. However, a process must be nice. SIGKILL and SIGSTOP could not be trapped or blocked.

- Pipe is uni-directional stream of data. it includes a pair of reader and writer. The reader is read-only and the write is write-only. Any data written into write stream is the output of the read stream. That's the mechanism to transfer the data between parent processes and their child processes. Socket is bio-directional stream of data. It can both receive and send data.

- The first process when a computer starts is `init` process with pid `1`. Everything is the children or grand-children of this process.

- The parent of orphan processes are always 1.

- Each process belongs to a process group. Process group is usually the pid of the group leader. Typically, the child process inherit the group its parent.

- In a terminal interface, when type some command, the terminal create a new process to handle that command and attach the stdout to the current interface. That process is the group leader of the new process group. When the interface sends INTERUPT signal (via `Ctrl-C`) to the whole *process group*, not the process itself. So, the parent process is killed, so do the child processes.

- In some situation, for example, a pipe in the interface `ps aux | grep abc`, each command creates a process as well as the group leader of each process. That means that those command doesn't have any relation in the process group wise. However, when press `Ctrl-C`, all of those processes and their children are all killed. That's because they belong to a same abstraction group called Session Group.

- Back to above one, actually, when sending signal to session group, it forwards the signal to its process group and then each process group forwards to its processes.Terminals can only be assigned to session leaders.

- `execve` system call is used to transform the current process into another thing total different. All file descriptor is still opened and passed into the new process. However, in ruby world, all file descriptors are cleaned up.

