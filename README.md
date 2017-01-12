# ems
 The ems (Easy Manage Server) is conducive to the management system and security considerations of system, using bash development

## HowTo Install
```
$ ./chmod +x setup.sh
$ ./setup.sh --prefix=/opt/ems
```

## HowTo add target

### ems commad
```
You can login quickly
$ ems mysite

You can also execute commands directly
$ ems mysite ls -l
```

### Site List setting
Add you site setting
```
vi /etc/ems/site-conf.d/mysite.conf
```

- Type      You can sort site types. 
- Alias     Set your site alias login.
- Server	Display hostname for identification.
- User		The remote user name.
- Port		The remote port.
- IP		Tje remote ip or domain.

