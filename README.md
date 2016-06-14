# blacksmith-workspace-generator
Easy workspace generator for [Blacksmith] to configure a [kubernetes] cluster,
according to [CoreOS + Kubernetes Step By Step guide][k8sguide].

[blacksmith]: https://github.com/cafebazaar/blacksmith
[kubernetes]: http://kubernetes.io/
[k8sguide]: https://coreos.com/kubernetes/docs/latest/getting-started.html

Without editing the configuration variables, you will get this configuration by
going through these steps:

![Network Map](https://github.com/cafebazaar/blacksmith-workspace-generator/raw/master/Doc/images/Network.png)

The generated workspace will use a flag named **state** to configure the
machines through this state machine:

![State Machine](https://github.com/cafebazaar/blacksmith-workspace-generator/raw/master/Doc/images/StateMachine.png)

Although the upper branch happens in a temporary Blacksmith (The bootstrapper of
the bootstrappers), but we are generating only *one* workspace. This way the
generating process will be simpler, and also we will be able to replace the
special nodes (Bootstrapper nodes) without the temporary Blacksmith.

## Prepare the Workspace
1. Customize `config.sh` to match your needs.

2. Put the authorized ssh keys into `ssh-keys.yaml`

3. Make sure you've imported the [CoreOS gpg key](https://coreos.com/security/image-signing-key/).

4. Download binary files into `binaries` (See `binaries/download-all.sh`).

5. Customize cloudconfig/ignition/bootparams (located inside `blacksmith/`) to
match your needs, if necessary.
  * For example, we've configured the eno2 interface of the bootstrappers there.
  * TODO: After implementing [global flags](https://github.com/cafebazaar/blacksmith/issues/32),
    we'll be able to parametrize these customizations, and move the params to the UI.

6. Execute `build.sh`

## The Bootstrapper of the Bootstrappers (_BoB_)
This machine will bootstrap the special nodes (Bootstrapper1, Bootstrapper2, and
Bootstrapper3) through `DHCP`, so it should be connected to the `eno1` interface
of the special nodes. And because of the effect of the `DHCP` server on the
network, I recommend you to isolate this network from your usual network from
the beginning.

Note: The following steps requires some interactions with the `Blacksmith`
running on the _BoB_ through a web browser (You can directly
[call the api](https://github.com/cafebazaar/blacksmith/blob/master/docs/API.md)
using `curl`).

1. Copy the generated `workspace` to _BoB_, if you can't use your
main machine as _BoB_.

2. Start a temporary etcd instance. we did it with docker:

  ```
  HostIP=192.168.64.2 docker run -d -p 4001:4001 -p 2380:2380 -p 2379:2379 --name etcd quay.io/coreos/etcd:v2.2.4 -name etcd0 -advertise-client-urls http://${HostIP}:2379,http://${HostIP}:4001 -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 -initial-advertise-peer-urls http://${HostIP}:2380  -listen-peer-urls http://0.0.0.0:2380  -initial-cluster-token etcd-cluster-1  -initial-cluster etcd0=http://${HostIP}:2380  -initial-cluster-state new
  ```
3. Start Blacksmith with the generated `workspace`:

  ```
  HostIP=192.168.64.2 docker run --name blacksmith -d --net=host -v $(pwd)/workspace:/workspace cafebazaar/blacksmith -etcd http://${HostIP}:2379 -if eth0 -cluster-name cafecluster -lease-start 192.168.64.51 -lease-range 20 -lease-subnet 255.255.240.0 -router 192.168.64.1 -dns 192.168.100.1
  ```

4. Go to the Blacksmith UI ([http://192.168.64.2:8000/ui/](http://192.168.64.2:8000/ui/)).

5. Start the Bootstrapper machines once from network. They should appear in the
   nodes list when they got their IP from the _BoB_. (Note: For some hardwares,
   you may see two nodes per machine. One of those two IPs is for their IPMI/iLO/...
   system.)

6. Add a new flag for the Bootstrapper machines:
   * `desired-state`: `bootstrapper1`
   * `desired-state`: `bootstrapper2`
   * `desired-state`: `bootstrapper3`

7. Update the `state` flag of the Bootstrapper machines to `init-install-coreos`.

8. Reboot the machines again from network.

9. The machines will install CoreOS on their storage device, and will reboot
   when done. They should **boot from disk** after this point. You should be
   able to `ping` the machines on their new IPs, which you have configured in
   `config.sh`.

10. On bootstrapper1, when the container images are downloaded and you're able
    to see `k8s_kube-apiserver...` in the `docker ps` list, run this command to
    create a required namespace:

    ```
    curl -H "Content-Type: application/json" -XPOST -d'{"apiVersion":"v1","kind":"Namespace","metadata":{"name":"kube-system"}}' "http://127.0.0.1:8080/api/v1/namespaces"
    ```

## Adding a new Worker
1. Configure the new machines to **always** boot from network.

2. Boot once.

3. They should appear in the nodes list when they got their IP from the active
Blacksmith on one of the bootstrappers. Add flag `state=init-worker` for this
new node, and reboot the machine. The worker should be rebooted automatically
after the initialization is completed. If everything goes right, you'll see
`state=worker` for this node after the reboots.

## Working with the Kubernetes cluster
`buidl.sh` generate these files as the takeaways:

* `Takeaways/kubeconfig`
* `Takeaways/ca.pem`
* `Takeaways/ca.key`
* `Takeaways/admin.pfx`
* `Takeaways/dns-addon.yml`
