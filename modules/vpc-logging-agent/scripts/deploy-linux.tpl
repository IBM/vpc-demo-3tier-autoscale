# =================================================================
# Copyright 2017 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# =================================================================
#!/bin/bash

# Determine package manager, exit if not apt or rpm

PKG_MANAGER=$( command -v yum || command -v apt-get ) || exit 1
PKG_MANAGER=`basename $PKG_MANAGER`

# Install based on package manager

case $PKG_MANAGER in

  "apt-get")

        # Wait for Cloud-Init to complete

        cloud-init status --wait

        # Configure LogDNA Agent
        echo "deb https://repo.logdna.com stable main" | sudo tee /etc/apt/sources.list.d/logdna.list
        curl --retry 12 https://repo.logdna.com/logdna.gpg | sudo apt-key add -
        sudo apt-get -o APT::Acquire::Retries=5 update

        # Ensure apt-get is not locked

        i=0
        tput sc
        while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
            case $(($i % 4)) in
                0 ) j="-" ;;
                1 ) j="\\" ;;
                2 ) j="|" ;;
                3 ) j="/" ;;
            esac
            tput rc
            echo -en "\r[$j] Waiting for other software managers to finish..." 
            sleep 0.5
            ((i=i+1))
        done

        # Install logdna agent
        sudo apt-get -o APT::Acquire::Retries=5 install logdna-agent < "/dev/null"
        sudo logdna-agent -k ${LOGDNA_KEY}
        sudo logdna-agent -s LOGDNA_APIHOST=api.${REGION}.logging.cloud.ibm.com
        sudo logdna-agent -s LOGDNA_LOGHOST=logs.private.${REGION}.logging.cloud.ibm.com

        %{ for DIR in DIRS ~}
          sudo logdna-agent -d ${DIR}
        %{ endfor ~}

        %{ for TAG in TAGS ~}
          sudo logdna-agent -d ${TAG}
        %{ endfor ~}

        sudo update-rc.d logdna-agent defaults
        systemctl start logdna-agent
        ;;

  "yum")

        cloud-init status --wait

        sudo rpm --import https://repo.logdna.com/logdna.gpg

        echo "[logdna]
        name=LogDNA packages
        baseurl=https://repo.logdna.com/el6/
        enabled=1
        gpgcheck=1
        gpgkey=https://repo.logdna.com/logdna.gpg" | sudo tee /etc/yum.repos.d/logdna.repo

        sudo yum -y install logdna-agent
        sudo logdna-agent -k ${LOGDNA_KEY}
        sudo logdna-agent -s LOGDNA_APIHOST=api.${REGION}.logging.cloud.ibm.com
        sudo logdna-agent -s LOGDNA_LOGHOST=logs.${REGION}.logging.cloud.ibm.com

        %{ for DIR in DIRS ~}
          sudo logdna-agent -d ${DIR}
        %{ endfor ~}

        %{ for TAG in TAGS ~}
          sudo logdna-agent -d ${TAG}
        %{ endfor ~}

        sudo chkconfig logdna-agent on
        sudo service logdna-agent start
        ;;
esac