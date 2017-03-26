# What is this?
 The ems (Easy Manage Server) is conducive to the management system and security considerations of system, using bash development

## Support & Requirements
- OS: CentOS, Ubuntu, Debian, Cygwin, MacOS
- openssh-client


## HowTo Install
```
$ ./chmod +x setup.sh
$ ./setup.sh --user=shazi7804
```

## HowTo add host
```
ems init [IP1,IP2 ...]
```

### ems command
You can login quickly
```
$ ems go mysite
```

You can also execute commands directly
```
$ ems go mysite ifconfig
```

Use sudo permissions command
```
$ ems go mysite sudo touch testfile
```

You can also use 'id' send command to site group
```
$ ems go --id 0,1 sudo touch testfile
```

### Import site
You must use the file import

Group,Alias,HostName,Port,IP

example:
```
dev,dev01,devserver,22,192.168.0.2
```

### Site List setting
Add you site setting
```
vi /etc/ems/site-conf.d/mysite.conf
```

- Group
You can sort site types. 

- Alias
Set your site alias login.

- HostName
Display hostname for identification.

- User
Login user, if use default user insert 'NA'.

- Port
The remote port.

- IP
The remote ip or domain.
