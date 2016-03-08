# blacksmith-workspace-generator
Easy workspace generator for blacksmith and kubernetes on baremetal for three machines

## Get started
1. Edit `up/vars/kuber_env.sh`
2. Put the authorized ssh keys into `up/vars/ssh-keys.yaml`
3. Edit cloudconfig templates (`cloud/`), if necessary.
4. Download `kubelet`, `kube-proxy`, and `kubectl` from Kubernetes, and put them into `kubernetes/bin/`.
5. Execute `build.sh`
6. in `/build` execute the following command but replace SERVER with the http address which will host the build directory (e.g. my.domain.com/blacksmith)
```
grep --null -lr "REPO=X" | xargs --null sed -i 's|REPO=X|REPO=SERVER|g'
```

After booting up the first machine with a coreos image:
```
curl -L my.domain.com/coreos_install/1.sh | sh
```
After you finished installing coreos, execute the following command in the machine:
```
curl -L my.domain.com/up/1.sh | sh
```
Kubernetes and Blacksmith(WIP) will both be installed.

Booting the other two machines can be done similarly using 2.sh etc. files
