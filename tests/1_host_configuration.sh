#!/bin/sh

# Load dependencies
. ./output_lib.sh
. ./helper_lib.sh

# 1.1
check_1_1="1.1  - Create a separate partition for containers"
check=$(echo $check_1_1 | cut -d "-" -f 1)
check_description=$(echo $check_1_1 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
grep /var/lib/docker /etc/fstab >/dev/null 2>&1
if [ $? -eq 0 ]; then
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
fi

# 1.2
check_1_2="1.2  - Use an updated Linux Kernel"
check=$(echo $check_1_2 | cut -d "-" -f 1)
check_description=$(echo $check_1_2 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
kernel_version=$(uname -r | cut -d "-" -f 1)
do_version_check 3.10 "$kernel_version"
if [ $? -eq 11 ]; then
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
fi

# 1.5
check_1_5="1.5  - Remove all non-essential services from the host - Network"
check=$(echo $check_1_5 | cut -d "-" -f 1)
check_description=$(echo $check_1_5| cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
# Check for listening network services.
listening_services=$(netstat -na | grep -v tcp6 | grep -v unix | grep -c LISTEN)
if [ "$listening_services" -eq 0 ]; then
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to get listening services for check - $check_1_5"
else
  if [ "$listening_services" -gt 5 ]; then
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Host listening on: $listening_services ports"
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
  fi
fi

# 1.6
check_1_6="1.6  - Keep Docker up to date"
check=$(echo $check_1_6 | cut -d "-" -f 1)
check_description=$(echo $check_1_6 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
docker_version=$(docker version | grep -i -A1 '^server' | grep -i 'version:' \
  | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
docker_current_version="1.10.2"
docker_current_date="2016-02-22"
do_version_check "$docker_current_version" "$docker_version"
if [ $? -eq 11 ]; then
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Using $docker_version, when $docker_current_version is current as of $docker_current_date"
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "Using $docker_version which is current as of $docker_current_date"
fi

# 1.7
check_1_7="1.7  - Only allow trusted users to control Docker daemon"
check=$(echo $check_1_7 | cut -d "-" -f 1)
check_description=$(echo $check_1_7 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
docker_users=$(getent group docker)
docker_users=$(echo "$docker_users" | cut -d ":" -f 4)
./docker-bench-security-logging.sh "$check" "$check_description" "info" "{ users: [$docker_users] }"

# 1.8
check_1_8="1.8  - Audit docker daemon"
check=$(echo $check_1_8 | cut -d "-" -f 1)
check_description=$(echo $check_1_8 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
command -v auditctl >/dev/null 2>&1
if [ $? -eq 0 ]; then
  auditctl -l | grep /usr/bin/docker >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
fi

# 1.9
check_1_9="1.9  - Audit Docker files and directories - /var/lib/docker"
check=$(echo $check_1_9 | cut -d "-" -f 1)
check_description=$(echo $check_1_9 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
directory="/var/lib/docker"
if [ -d "$directory" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $directory >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
    else
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
    fi
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "$directory not found"
fi

# 1.10
check_1_10="1.10 - Audit Docker files and directories - /etc/docker"
check=$(echo $check_1_10 | cut -d "-" -f 1)
check_description=$(echo $check_1_10 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
directory="/etc/docker"
if [ -d "$directory" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $directory >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
    else
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
    fi
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "$directory not found"
fi

# 1.11
check_1_11="1.11 - Audit Docker files and directories - docker-registry.service"
check=$(echo $check_1_11 | cut -d "-" -f 1)
check_description=$(echo $check_1_11 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
file="$(get_systemd_service_file docker-registry.service)"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
    else
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
    fi
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "docker-registry.service not found"
fi

# 1.12
check_1_12="1.12 - Audit Docker files and directories - docker.service"
check=$(echo $check_1_12 | cut -d "-" -f 1)
check_description=$(echo $check_1_12 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
file="$(get_systemd_service_file docker.service)"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
    else
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
    fi
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "$file not found"
fi

# 1.13
check_1_13="1.13 - Audit Docker files and directories - /var/run/docker.sock"
check=$(echo $check_1_13 | cut -d "-" -f 1)
check_description=$(echo $check_1_13 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
file="/var/run/docker.sock"
if [ -e "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
    else
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
    fi
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "$file not found"
fi

# 1.14
check_1_14="1.14 - Audit Docker files and directories - /etc/sysconfig/docker"
check=$(echo $check_1_14 | cut -d "-" -f 1)
check_description=$(echo $check_1_14 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
file="/etc/sysconfig/docker"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
    else
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
    fi
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "$file not found"
fi

# 1.15
check_1_15="1.15 - Audit Docker files and directories - /etc/sysconfig/docker-network"
check=$(echo $check_1_15 | cut -d "-" -f 1)
check_description=$(echo $check_1_15 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
file="/etc/sysconfig/docker-network"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
    else
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
    fi
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "$file not found"
fi

# 1.16
check_1_16="1.16 - Audit Docker files and directories - /etc/sysconfig/docker-registry"
check=$(echo $check_1_16 | cut -d "-" -f 1)
check_description=$(echo $check_1_16 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
file="/etc/sysconfig/docker-registry"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
    else
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
    fi
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "$file not found"
fi

# 1.17
check_1_17="1.17 - Audit Docker files and directories - /etc/sysconfig/docker-storage"
check=$(echo $check_1_17 | cut -d "-" -f 1)
check_description=$(echo $check_1_17 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
file="/etc/sysconfig/docker-storage"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
    else
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
    fi
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "$file not found"
fi

# 1.18
check_1_18="1.18 - Audit Docker files and directories - /etc/default/docker"
check=$(echo $check_1_18 | cut -d "-" -f 1)
check_description=$(echo $check_1_18 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')
file="/etc/default/docker"
if [ -f "$file" ]; then
  command -v auditctl >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    auditctl -l | grep $file >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      ./docker-bench-security-logging.sh "$check" "$check_description" "pass"
    else
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn"
    fi
  else
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Failed to inspect: auditctl command not found."
  fi
else
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "$file not found"
fi
