# Getting Started

## Setup

**Prerequisites:** make sure to go through the Terraform in the `infra/` directory.
We won't explain it here.

### AWS Session Manager

You will need the AWS Session Manager plugin installed because the dev EC2 we will be using will not be accessible otherwise.
Goto
[Install the Session Manager plugin for the AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html).

After that, we added the following to our `~/.ssh/config`:

```bash
Host i-*
    User ec2-user
    ProxyCommand /Users/user/go/src/github.com/seafoodfry/ciphercoin/infra/run-cmd-in-shell.sh aws ssm start-session --region us-east-1 --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'
```

**NOTE:** we are doing the above because our convention for interacting wit AWS depends on a script
that uses `Password and its CLI, `op`, to retrieve the credentials for an IAM user, that we in turn use to assume an AWS IAM role with real permissions.
If you are curious, our setup is outlined in
[seafoodfry.github.io/aws-lab-setup/](https://seafoodfry.github.io/aws/lab/2024/05/27/aws-lab-setup/).


## Bootstraping the Infra

To get a dev EC2 we run the following commands:
```bash
cd infra/

make
```

If the plan looks alright,
```bash
./run-cmd-in-shell.sh terraform apply a.plan
```

Now an EC2 should be somewhere in the cloud and we can begin attempting to setup
an SSH tunnel via the session manager.
(Though you may want to give it some time for the machine to startup and be ready.)
```bash
make instance_id

export INSTANCE_ID=<whatever the above command printed>

make ssh
```

The above will hang for a bit.
Whenever it terminates, you should be able to SSH into the machine by running

```bash
ssh ${INSTANCE_ID}
```


### Setting up your development env

To sync our working source code, run
```bash
make sync
```
**NOTE:** all these commands must be executed from the `infra/` directory because
our `~/.ssh/config` relies on the OP CLI wrapper script and the env file we got there.
(If you are adapting this to fit your needs, remember that.)

You all set!

---

## Gaining some familiarity with our stack

I haven't found a good tutorial to help get enough context to start doing cool things so here is an attempt at one.

**NOTE:** you still need to learn how Ethereum works on your own, otherwise this won't make much sense.
We really liked [ethereum.org/developers/docs](https://ethereum.org/developers/docs/).

A way to do dev is like so:

In one terminal, in the infra dir,
```bash
make sync
```
each time you do changes.

In another terminal, `ssh $INSTANCE_ID` and do things like:

```bash
tmux new -s dev

cd ciphercoin

tmux detach or Ctrl+b d
```

You can see your active tmux session by running
```bash
tmux ls
```

And you can get back in there by
```bash
tmux attach -t dev
```

We also got some targets in the Makefile to run an anvil node and cast

### TL;DR

```bash
tmux new -s dev

make anvil

make dev
# deploy contract with the deploy-contract.sh script

# Ctrl-b d
```

When you deploy the contract, you will see an "contract address" output, save it.

Then in another terminal
```bash
make cast
```

Then you can do things such as:
```bash
export CONTRACT_ADDR=0x...

cast call $CONTRACT_ADDR "number()" --rpc-url http://anvil-node:8545

cast send $CONTRACT_ADDR "increment()" --rpc-url http://anvil-node:8545 --private-key ${ANVIL_PRIV_KEY}

cast send $CONTRACT_ADDR  "setNumber(uint256)" 42 --rpc-url http://anvil-node:8545 --private-key ${ANVIL_PRIV_KEY}
```