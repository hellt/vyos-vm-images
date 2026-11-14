# vyos-vm-images

[Ansible](https://www.ansible.com/) playbooks to build VyOS VM images.

## Requirements

- Linux with Docker
- At least 20 GB of free disk space

Docker is the only host dependency. The build image is based on
[`srl-labs/ansible-core`](https://github.com/srl-labs/ansible-core) and includes
Ansible, QEMU, and the filesystem tools. The build container needs `--privileged`
to mount the ISO and use loop devices; KVM is not required.

## Build a QEMU image with cloud-init

Run:

```sh
./build.sh
```

The script builds the Docker image, downloads the VyOS 2026.03 ISO inside the
container, and writes `images/vyos-2026.03-qemu.qcow2`. The ISO is cached in
`.cache/vyos.iso` and reused by subsequent builds. Cloud-init is installed from
the active VyOS rolling repository, without using the ISO's archived APT sources.

The defaults can be changed without installing any additional tools:

```sh
VYOS_ISO_URL=https://community-downloads.vyos.dev/stream/2026.03/vyos-2026.03-generic-amd64.iso \
DISK_SIZE=10 \
CLOUD_INIT_DS=NoCloud,ConfigDrive,None \
./build.sh
```

Additional arguments are passed to `ansible-playbook`. For example:

```sh
./build.sh -e enable_ssh=true -e guest_agent=qemu
```

Internally, the playbook runs with the equivalent of:

```sh
ansible-playbook qemu.yml \
  -e iso_local=/cache/vyos.iso \
  -e disk_size=10 \
  -e cloud_init=true \
  -e cloud_init_ds=NoCloud,ConfigDrive,None
```

For OVA builds, `ovftool` and a private signing key are still required.

## Supported Platforms

- QEMU with cloud-init (Docker)

    ```
    ./build.sh
    ```

- VMware Cloud-init

    ```
    ansible-playbook vmware.yml -e vyos_vmware_private_key_path=path_to_private_key
    ```

- VMware simple ova

    ```
    ansible-playbook vmware.yml -e vyos_vmware_private_key_path=path_to_private_key -e cloud_init=false -e ovf_template=simple
    ```

- Microsoft Hyper-V

    ```
    ansible-playbook hyperv.yml
    ```

- Vagrant libvirt

    ```
    ansible-playbook vagrant-libvirt.yml
    ```

## Additional (optional) parameters

- Path to local ISO image (default: /tmp/vyos.iso):

    ```
    -e iso_local=path
    ```

    Example:

    ```
    -e iso_local=/tmp/vyos/custom_image.iso
    ```

- Disk size (default: 10GB):

    ```
    -e disk_size=size
    ```

    Example for 2 GB:

    ```
    -e disk_size=2
    ```

- Enable Cloud-init (default: according to platform):

    ```
    -e cloud_init=true
    ```

- Configure custom Cloud-init datasources (default: according to platform):

    ```
    -e cloud_init_ds=datasources
    ```

    Example:
    ```
    -e cloud_init_ds=NoCloud,ConfigDrive,None
    ```

- Install guest agent. It can be `qemu`, `vmware` (default: none):

    ```
    -e guest_agent=agent
    ```

    Example:
    ```
    -e guest_agent=qemu
    ```

- Disable configuration stage modules in Cloud-init. Mostly useful when you are building for non-cloud environments, where Cloud-init meta-data is not available (default: false):
    ```
    -e cloud_init_disable_config=true
    ```

- Create an archive with files required to PXE boot (default: false):

    ```
    -e pxe=true
    ```

- Keep default `vyos` user with password `vyos` in configuration when building an image with Cloud-init (default: false):

    ```
    -e keep_user=true
    ```

- Select a type of partition table for a disk image. Supported: `mbr`, `gpt`, `hybrid` (default: `hybrid`):

    ```
    -e parttable_type=hybrid
    ```
- Select default console for boot. Supported: `kvm`, `serial` (default: depending on platform):

    ```
    -e grub_console=serial
    ```

- Install custom packages. Can be a list in the `files/custom_packages_list.txt` file separated by spaces, or deb files inside the `files/custom_debs/` directory:

    ```
    -e custom_packages=true
    ```

- Copy custom files. All files from inside the `files/custom_files/` directory will be copied to the target filesystem recursively:

    ```
    -e custom_files=true
    ```

- Enable DHCP on eth0 (default: `false`):

    ```
    -e enable_dhcp=true
    ```

- Enable SSH (default: `false`):

    ```
    -e enable_ssh=true
    ```

- Remove `login` from configuration. Unlike `keep_user`, this option will completely remove `system login` from configuration.

    ```
    -e without_login=true
    ```
