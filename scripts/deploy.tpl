#!/bin/bash

set -x

# parameters via substitution in the form __a__ done in terraform, look for all occurrances
# FRONT_BACK values of FRONT or BACK indicating the type of instance
# REMOTE_URL instances can reach out to a remote if provided
# MAIN_PY contents of the main.py python program
# POSTGRESQL_CREDENTIALS contents of the postgresql credentials
# ubuntu has a /root directory
# these will be empty or a values

# fix apt install it is prompting: Restart services during package upgrades without asking? <Yes><No>
export DEBIAN_FRONTEND=noninteractive


# Install python libraries
apt update -y
apt install python3-pip -y
pip3 install --upgrade pip
pip3 install fastapi uvicorn psycopg2-binary

# Configure Service and start
cat > /etc/systemd/system/threetier.service  << 'EOF'
[Service]
Environment="FRONT_BACK=${FRONT_BACK}"
Environment="REMOTE_URL=${REMOTE_URL}"
WorkingDirectory=/root
ExecStart=/usr/local/bin/uvicorn main:app --host 0.0.0.0 --port 8000
EOF

systemctl start threetier