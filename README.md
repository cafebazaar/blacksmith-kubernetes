# blacksmith-workspace-generator
Easy workspace generator for blacksmith and kubernetes on baremetal for three
machines.

Without editing the configuration variables, you will get this configuration by
going through these steps:

![Network Map](https://github.com/cafebazaar/blacksmith-workspace-generator/raw/master/Doc/images/Network.png)

The generated workspace will use a flag named **state** to configure the
machines through this state machine:

![State Machine](https://github.com/cafebazaar/blacksmith-workspace-generator/raw/master/Doc/images/StateMachine.png)

Although the upper branch happens in a temporary blacksmith (The bootstrapper of
the bootstrappers), but we are generating only *one* workspace. This way the
generating process will be simpler, and also we will be able to replace the
special nodes (Bootstrapper nodes) without the temporary blacksmith.

## Prepare the Workspace
1. Customize `kuber_env.sh` to match your needs.
2. Put the authorized ssh keys into `ssh-keys.yaml`
3. Make sure you've imported the [CoreOS gpg key](https://coreos.com/security/image-signing-key/).
4. Download binary files into `binaries` (See `binaries/download-all.sh`).
5. Customize cloudconfig/ignition/bootparams (located inside `blacksmith/`) to
match your needs, if necessary.
  1. For example,
6. Execute `build.sh`

## The Bootstrapper of the Bootstrappers (_BoB_)
This machine will bootstrap the special nodes (Bootstrapper1, Bootstrapper2, and
Bootstrapper3) through `DHCP`, so it should be connected to the `eno1` interface
of the special nodes. And because of the effect of the `DHCP` server on the
network, I recommend you to isolate this network from your usual network from
the beginning.

Note: The following steps requires some interactions with the `Blacksmith`
running on the _BoB_ through web browser or curl. But you can bootstrap the
special nodes without any interaction, by pre-configuring the required flags
and then attaching _BoB_ to the special nodes and boot the special nodes
from network.

1. Copy the generated `build/workspace` to _BoB_, if you can't use your
main machine as _BoB_.
2. Start the machines from

## Adding a new Worker
1. Configure the new machines to **always** boot from network.
2. Boot once.
3. The node should be added to the UI of the Blacksmith. Add flag
`state=init-worker` for this new node, and boot the machine. The worker should
be rebooted automatically after the initialization is completed. First is
rebooted by `reboot_service_script.sh` when the state is changed to
`init-worker`, then by `initialize.sh`, after partitioning the storage of the
machines. If everything goes right, you'll see `state=worker` for this node
after the reboots.

## Working with the Kubernetes cluster
After executing `buidl.sh`, two files will be added to the root this project:

* `kubeconfig`
* `ca.key`

TODO: kubectl create '{"apiVersion":"v1","kind":"Namespace","metadata":{"name":"kube-system"}}'
