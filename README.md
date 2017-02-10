# What is this?
 The ems (Easy Manage Server) is conducive to the management system and security considerations of system, using bash development

## Support & Requirements
- OS: CentOS, Ubuntu, Debian, Cygwin, MacOS
- openssh-client
- rsync
- 


## HowTo Install
```
$ ./chmod +x setup.sh
$ ./setup.sh --prefix=/opt/ems
```
If you need setting default login user:
```
$ ./setup.sh --user=scott
```

## HowTo add host
```
ems init [IP1,IP2 ...]
```


### ems command

```
You can login quickly
$ ems mysite

You can also execute commands directly
$ ems mysite ls -l

Use sudo permissions command
$ ems mysite sudo ls -l
```

### Site List setting
Add you site setting
```
vi /etc/ems/site-conf.d/mysite.conf
```

- Type - You can sort site types. 
- Alias - Set your site alias login.
- Server - Display hostname for identification.
- User - The remote user name.
- Port - The remote port.
- IP - The remote ip or domain.
