#!/bin/sh

# logit "\n"
# info "2 - Docker Daemon Configuration"

# 2.1
check_2_1="2.1  - Do not use lxc execution driver"
check=$(echo $check_2_1 | cut -d "-" -f 1)
check_description=$(echo $check_2_1 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

get_command_line_args docker | grep lxc >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # warn "$check_2_1"
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "LXC execution driver is used"
else
  # pass "$check_2_1"
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No LXC execution driver is used"
fi

# 2.2
check_2_2="2.2  - Restrict network traffic between containers"
check=$(echo $check_2_2 | cut -d "-" -f 1)
check_description=$(echo $check_2_2 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

get_command_line_args docker | grep "icc=false" >/dev/null 2>&1 
if [ $? -eq 0 ]; then
 # pass "$check_2_2"
 ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "Restriction of network traffic between containers is applied"
else
 # warn "$check_2_2"
 ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Restriction of network traffic between containers is not applied"
fi

# 2.3
check_2_3="2.3  - Set the logging level"
check=$(echo $check_2_3 | cut -d "-" -f 1)
check_description=$(echo $check_2_3 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

get_command_line_args docker | grep "log-level=\"debug\"" >/dev/null 2>&1
if [ $? -eq 0 ]; then
 # warn "$check_2_3"
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "No logging level is set"
else
 # pass "$check_2_3"
 ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "Logging level is set"
fi

# 2.4
check_2_4="2.4  - Allow Docker to make changes to iptables"
check=$(echo $check_2_4 | cut -d "-" -f 1)
check_description=$(echo $check_2_4 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

get_command_line_args docker | grep "iptables=false" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # warn "$check_2_4"
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Docker is not allowed to make changes to iptables"
else
  # pass "$check_2_4"
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "Docker is allowed to make changes to iptables"
fi

# 2.5
check_2_5="2.5  - Do not use insecure registries"
check=$(echo $check_2_5 | cut -d "-" -f 1)
check_description=$(echo $check_2_5 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

get_command_line_args docker | grep "insecure-registry" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # warn "$check_2_5"
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Insecure registries are set to be used"
else
  # pass "$check_2_5"
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No insecure registries are set to be used"
fi

# 2.6
check_2_6="2.6  - Setup a local registry mirror"
check=$(echo $check_2_6 | cut -d "-" -f 1)
check_description=$(echo $check_2_6 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')


get_command_line_args docker | grep "registry-mirror" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # pass "$check_2_6"
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "Local registry mirror is available"
else
  # info "$check_2_6"
  # info "     * No local registry currently configured"
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "No local mirror registry currently configured"
fi

# 2.7
check_2_7="2.7  - Do not use the aufs storage driver"
check=$(echo $check_2_7 | cut -d "-" -f 1)
check_description=$(echo $check_2_7 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

docker info 2>/dev/null | grep -e "^Storage Driver:\s*aufs\s*$" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # warn "$check_2_7"
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "AUFS storage driver is used"
else
  # pass "$check_2_7"
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No aufs storage driver is used"
fi

# 2.8
check_2_8="2.8  - Do not bind Docker to another IP/Port or a Unix socket"
check=$(echo $check_2_8 | cut -d "-" -f 1)
check_description=$(echo $check_2_8 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

get_command_line_args docker | grep "\-H" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # info "$check_2_8"
  # info "     * Docker daemon running with -H"
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Docker is bound to another IP/Port or a Unix socket"
else
 # pass "$check_2_8"
 ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "Docker is not bound to another IP/Port or a Unix socket"
fi

# 2.9
check_2_9="2.9  - Configure TLS authentication for Docker daemon"
check=$(echo $check_2_9 | cut -d "-" -f 1)
check_description=$(echo $check_2_9 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

get_command_line_args docker | tr "-" "\n" | grep -E '^(H|host)' | grep -vE '(unix|fd)://' >/dev/null 2>&1
if [ $? -eq 0 ]; then
  get_command_line_args docker | grep "tlsverify" | grep "tlskey" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    # pass "$check_2_9"
    # info "     * Docker daemon currently listening on TCP"
   ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "Docker daemon currently listening on TCP with TLS authentication"
  else
   # warn "$check_2_9"
   # warn "     * Docker daemon currently listening on TCP without --tlsverify"
   ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Docker daemon currently listening on TCP without --tlsverify"
  fi
else
  # info "$check_2_9"
  # info "     * Docker daemon not listening on TCP"
  ./docker-bench-security-logging.sh "$check" "$check_description" "info" "Docker daemon not listening on TCP"
fi

# 2.10
check_2_10="2.10 - Set default ulimit as appropriate"
check=$(echo $check_2_10 | cut -d "-" -f 1)
check_description=$(echo $check_2_10 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')


get_command_line_args docker | grep "default-ulimit" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  # pass "$check_2_10" 
   ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "Default ulimit as appropriate is set"
else
  # info "$check_2_10"
  # info "     * Default ulimit doesn't appear to be set"
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Default ulimit doesn't appear to be set"
fi

