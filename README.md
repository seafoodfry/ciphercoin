# ciphercoin
stablecoin lab

---
## Dev


Requirements:
1. Make sure to update the ec2 key pair in [ec2.tf](./ec2.tf)

```bash
# Spin up the dev ec2.
make

# Run the output of the command to setup the INSTANCE_ID env var.
make instance_id

# Start the instance manager ssh session.
make ssh
```

In another terminal,
```bash
ssh ${INSTANCE_ID}
```

---
## AWS Permissions

The script `./run-cmd-in-shell.sh` will run one command per invokation.
We created
- [`exec-shell-with-envvars.sh`](./exec-shell-with-envvars.sh) to be executed as `./exec-shell-with-envvars.sh` and provide a brand new shell to run multiple commands under the same temporary STS role creds.
- [`source-envars-for-shell.sh`](./source-envars-for-shell.sh) to be executed as `. ./source-envars-for-shell.sh` to source the necessary env vars to run AWS commands under a temporary STS session.
    - If you installed the [AWS CLI 1Password plugin](https://developer.1password.com/docs/cli/shell-plugins/aws/) you'll need to uncomment the line in your `~/.zshrc` or `~/.bashrc` file where you first source `~/.config/op/plugins.sh`. Otherwise the AWS cli will always be picking up the default IAM user you set it up with.
    - We discovered this thanks to `aws configure list`.


---
## Maintenance

Remember to run the following every now and then:

```bash
rustup self update

rustup update
```

---
## Code Setup

[Get up and running with Foundry by installing the toolkit](https://getfoundry.sh/introduction/installation/)



---
## Infra Setup

### Choosing an EC2

For the family, we did the following:
1. Goto [Amazon EC2 instance types](https://aws.amazon.com/ec2/instance-types/)
1. Look around

Currently, the latest gen of graviton machines is T4g family.

We then compared pricing on the following pages
1. [https://aws.amazon.com/ec2/pricing/on-demand/](https://aws.amazon.com/ec2/pricing/on-demand/)
1. [https://aws.amazon.com/ec2/spot/pricing/](https://aws.amazon.com/ec2/spot/pricing/)

A `t4g.medium` looked like a descent starting point.

### Choosing an AMI

Went to the console, used the launch wizard and looked at the default AL2023 AMI offered, which was `ami-0aa7db6294d00216f`.
I then used the follwoing command to get more details:

```bash
./run-cmd-in-shell.sh aws ec2 describe-images --region us-east-1 --image-ids ami-0aa7db6294d00216f
```

## Session Manager

Goto
[Install the Session Manager plugin for the AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
because a session-manager plugin is necessary to connect to the EC2 without it having a public IP
via the session manager.

After that, we added the following to our `~/.ssh/config`:

```bash
Host i-*
    User ec2-user
    ProxyCommand /Users/user/go/src/github.com/seafoodfry/ciphercoin/infra/run-cmd-in-shell.sh aws ssm start-session --region us-east-1 --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'
```

This was, after running

```bash
./run-cmd-in-shell.sh aws ssm start-session --region us-east-1 \
    --target ${INSTANCE_ID} \
    --document-name AWS-StartSSHSession \
    --parameters portNumber=22
```

in a terminal, we can simply

```bash
ssh  ${INSTANCE_ID}
```

---
## Code Setup

```bash
forge init ciphercoin
```