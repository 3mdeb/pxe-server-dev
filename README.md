# pxe-server-dev

## Requirements

```
sudo modprobe nfs nfsd
```

## Start

```
./up.sh
```

## Possible issues

* `rpc_pipefs`

```
nfs-server    | ==================================================================
nfs-server    |       STARTING SERVICES ...
nfs-server    | ==================================================================
nfs-server    | ----> mounting rpc_pipefs filesystem onto /var/lib/nfs/rpc_pipefs
nfs-server    | mount: mounting rpc_pipefs on /var/lib/nfs/rpc_pipefs failed: Permission denied
nfs-server    | ---->
nfs-server    | ----> ERROR: unable to mount rpc_pipefs filesystem onto /var/lib/nfs/rpc_pipefs
nfs-server    | ---->
```

See [AppArmor configuration](https://github.com/ehough/docker-nfs-server/blob/develop/doc/feature/apparmor.md#apparmor)
If you are Ubuntu 18 user, install [apparmor](https://launchpad.net/ubuntu/+source/apparmor) manually.

* `111` port already in use:

```
ERROR: for nfs-server  Cannot start service nfs-server: b'driver failed programming external connectivity on endpoint nfs-server (e2d2855b08c73af0e79b0d6854291cc15255d726b21059a8a647daf8c817903f): Error starting userland proxy: listen tcp 0.0.0.0:111: bind: address already in use'
```

Some other service is using 111 port on the host. Possible solution:

```
sudo service rpcbind stop
```
