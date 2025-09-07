#!/bin/bash
set -x
set -e

systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent