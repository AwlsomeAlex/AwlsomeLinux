# AwlsomeLinux

Creating a Linux Distributon Seemed to be an impossible task, where only the huge people like Debian or Fedora could make them, or the best you can do is remix Ubuntu and hope it contents that urge of making something. However, thanks to Ivandavidov's Minimal Linux Live Project (https://github.com/ivandavidov/minimal) that dream is a reality for me. 

![AwlsomeLinux](https://github.com/AwlsomeAlex/AwlsomeLinux/blob/master/AwlsomeLinux.png?raw=true)

## NEWS: **AN INSTALL METHOD?!?**
Wow, this is quite surprising... just as I was getting ready to start the Installer, Ivandavidov had an unexpected package added to his project, mll-tools (Minimal Linux Live Tools) which included the mkfs.ext2 command, a simple partition editor, and a complete **INSTALLER!** I will now make plans to instead implement mll-tools into AwlsomeLinux, because instead of doing it on an ArchLinux Live CD, it can now be directly installed **ON A MINIMAL LINUX LIVE CD!** Afterwards I will start to make plans on reorganizing the Overlay Structure, maybe into something like a **Package Manager** where the applications are loaded to a /usr/package/(source), I'm not sure, but whats next is the Installer, and what is after will most likely be Dialog.

## What is AwlsomeLinux?
AwlsomeLinux right now is an idea, but by simplifing and replicating the process which Ivandavidov created for his project, I can use the series of scripts to create a system which I want, and eventually can become Self-Hosted. Once self-hosted, AwlsomeLinux can succeed. All that will be included at first will be the Linux Kernel, simple Glibc Libraries, Busybox, and Syslinux. Thats about it at that point. However thanks to the LFS Project being a huge reference point, by creating Overlay scripts, I can add features such as Nano Support (My Main Goal due to Ncurses not working), make it actually installable, and maybe even eventually add Xorg and add a simple GUI Interface. However this will all be impossible without the understandings of the Linux System at its finest, so AwlsomeLinux will take time to grow, but it will eventually. Eventually, I want to branch away the Ivandavidov's Commit Chart where I'm dependent on him, to where AwlsomeLinux will get to the point of being on Distrowatch, but that's a far away dream.

## Contributors:
* AwlsomeAlex (Creator of AwlsomeLinux)
* Ivandavidov (Creator of Minimal Linux Live) [AwlsomeLinux is a Fork of it.]


