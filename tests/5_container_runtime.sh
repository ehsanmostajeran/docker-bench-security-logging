#!/bin/sh

#logit "\n"
#info "5  - Container Runtime"

# If containers is empty, there are no running containers
if [ -z "$containers" ]; then
 # info "     * No containers running, skipping Section 5"
./docker-bench-security-logging.sh "$check" "$check_description" "info" "No containers running, skipping Check Section No 5"
	else
  # Make the loop separator be a new-line in POSIX compliant fashion
  set -f; IFS=$'
'
  # 5.1
  check_5_1="5.1  - Verify AppArmor Profile, if applicable"
  check=$(echo $check_5_1 | cut -d "-" -f 1)
  check_description=$(echo $check_5_1 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
    policy=$(docker inspect --format 'AppArmorProfile={{ .AppArmorProfile }}' "$c")

    if [ "$policy" = "AppArmorProfile=" -o "$policy" = "AppArmorProfile=[]" -o "$policy" = "AppArmorProfile=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
        ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "No AppArmorProfile Found: $c"
#	warn "$check_5_1"
#        warn "     * No AppArmorProfile Found: $c"
        fail=1
      else
        ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "No AppArmorProfile Found: $c" 
#        warn "     * No AppArmorProfile Found: $c"
      fi
    fi
  done
 # We went through all the containers and found none without AppArmor
  if [ $fail -eq 0 ]; then
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "All containers are running with AppArmorProfile"  
 #  pass "$check_5_1"
  fi

# 5.2
  check_5_2="5.2  - Verify SELinux security options, if applicable"
  check=$(echo $check_5_2 | cut -d "-" -f 1)
  check_description=$(echo $check_5_2 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')


  fail=0
  for c in $containers; do
    policy=$(docker inspect --format 'SecurityOpt={{ .HostConfig.SecurityOpt }}' "$c")

    if [ "$policy" = "SecurityOpt=" -o "$policy" = "SecurityOpt=[]" -o "$policy" = "SecurityOpt=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
   #     warn "$check_5_2"
   #     warn "     * No SecurityOptions Found: $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "No SecurityOptions Found: $c"
   fail=1
      else
   #     warn "     * No SecurityOptions Found: $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "No SecurityOptions Found: $c"
      fi
    fi
  done
  # We went through all the containers and found none without SELinux
  if [ $fail -eq 0 ]; then
#      pass "$check_5_2"
./docker-bench-security-logging.sh "$check" "$check_description" "pass"  "All containers are running with SELinux security options"
 fi

 # 5.3
  check_5_3="5.3  - Verify that containers are running only a single main process"
  check=$(echo $check_5_3 | cut -d "-" -f 1)
  check_description=$(echo $check_5_3 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
#  printcheck=0
  for c in $containers; do
    processes=$(docker exec "$c" ps -el 2>/dev/null | tail -n +2 | grep -c -v "ps -el")
    if [ "$processes" -gt 1 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
      #  warn "$check_5_3"
     #   warn "     * Too many proccesses running: $c"
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Too many proccesses running: $c"
	  fail=1
 #       printcheck=1
      else
      #  warn "     * Too many proccesses running: $c"
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Too many proccesses running: $c"
	fi
    fi

    exec_check=$(docker exec "$c" ps -el 2>/dev/null)
    if [ $? -eq 255 ]; then
#        if [ $printcheck -eq 0 ]; then
#          warn "$check_5_3"
#          printcheck=1
#        fi
    #  warn "     * Docker exec fails: $c"
    ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Docker exec fails: $c"
	  fail=1
    fi

  done
  # We went through all the containers and found none with toom any processes
  if [ $fail -eq 0 ]; then
    #  pass "$check_5_3"
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "All containers are running only a single main process"
	fi

# 5.4
  check_5_4="5.4  - Restrict Linux Kernel Capabilities within containers"
   check=$(echo $check_5_4 | cut -d "-" -f 1)
  check_description=$(echo $check_5_4 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

 fail=0
  for c in $containers; do
    caps=$(docker inspect --format 'CapAdd={{ .HostConfig.CapAdd}}' "$c")

    if [ "$caps" != 'CapAdd=' -a "$caps" != 'CapAdd=[]' -a "$caps" != 'CapAdd=<no value>' -a "$caps" != 'CapAdd=<nil>' ]; then
      # If it's the first container, fail the test
  #    if [ $fail -eq 0 ]; then
    #    warn "$check_5_4"
    #    warn "     * Capabilities added: $caps to $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Capabilities added: $caps $c"
        fail=1
 #     else
 #       warn "     * Capabilities added: $caps to $c"
#	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Capabilities added: $caps $c"
  #    fi
    fi
  done
  # We went through all the containers and found none with extra capabilities
  if [ $fail -eq 0 ]; then
      # pass "$check_5_4"
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "All containers are running by defaul Capabilities"
  fi

# 5.5
  check_5_5="5.5  - Do not use privileged containers"
check=$(echo $check_5_5 | cut -d "-" -f 1)
  check_description=$(echo $check_5_5 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
    privileged=$(docker inspect --format '{{ .HostConfig.Privileged }}' "$c")

    if [ "$privileged" = "true" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
     #   warn "$check_5_5"
     #   warn "     * Container running in Privileged mode: $c"
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running in Privileged mode: $c"
	  fail=1
      else
     #   warn "     * Container running in Privileged mode: $c"
     ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running in Privileged mode: $c"
	 fi
    fi
  done
  # We went through all the containers and found no privileged containers
  if [ $fail -eq 0 ]; then
   #   pass "$check_5_5"
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No container is running in Privileged mode"
	fi

 # 5.6
  check_5_6="5.6  - Do not mount sensitive host system directories on containers"
  check=$(echo $check_5_6 | cut -d "-" -f 1)
  check_description=$(echo $check_5_6 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  # List of sensitive directories to test for. Script uses new-lines as a separator.
  # Note the lack of identation. It needs it for the substring comparison.
  sensitive_dirs='etc
boot
dev
lib
proc
sys
usr
.*'
  fail=0
#  containersq=$(docker ps -q | sed '1d' | awk '{print $NF}')
  for c in $containers; do
    volumes=$(docker inspect --format "{{ .Config.Volumes }}" "$c")
    # Go over each directory in sensitive dir and see if they exist in the volumes
    for v in $sensitive_dirs; do
      sensitive=0
      contains "$volumes" "$v:" && sensitive=1
      if [ $sensitive -eq 1 ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
      #    warn "$check_5_6"
      #    warn "     * Sensitive directory $v mounted in: $c"
       ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Sensitive directory $v mounted in: $c"
	   fail=1
        else
      #    warn "     * Sensitive directory $v mounted in: $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Sensitive directory $v mounted in: $c"
        fi
      fi
    done
  done
  # We went through all the containers and found none with sensitive mounts
  if [ $fail -eq 0 ]; then
    #  pass "$check_5_6"
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No container has mount sensitive host system directories"
  fi

# 5.7
  check_5_7="5.7  - Do not run ssh within containers"
  check=$(echo $check_5_7 | cut -d "-" -f 1)
  check_description=$(echo $check_5_7 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')


  fail=0
  printcheck=0
  for c in $containers; do

    processes=$(docker exec "$c" ps -el 2>/dev/null | grep -c sshd | awk '{print $1}')
    if [ "$processes" -ge 1 ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
      #  warn "$check_5_7"
      #  warn "     * Container running sshd: $c"
       ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running sshd: $c"
	 fail=1
        printcheck=1
      else
     #   warn "     * Container running sshd: $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running sshd: $c"
      fi
    fi

    exec_check=$(docker exec "$c" ps -el 2>/dev/null)
    if [ $? -eq 255 ]; then
        if [ $printcheck -eq 0 ]; then
      #    warn "$check_5_7"
          printcheck=1
        fi
   #   warn "     * Docker exec fails: $c"
     ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Docker exec fails: $c"
	  fail=1
    fi

  done
  # We went through all the containers and found none with sshd
  if [ $fail -eq 0 ]; then
   #   pass "$check_5_7"
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No container has sshd"
	fi

# 5.8
  check_5_8="5.8  - Do not map privileged ports within containers"
  check=$(echo $check_5_8 | cut -d "-" -f 1)
  check_description=$(echo $check_5_8 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
    # Port format is private port -> ip: public port
    ports=$(docker port "$c" | awk '{print $0}' | cut -d ':' -f2)

    # iterate through port range (line delimited)
    for port in $ports; do
    if [ ! -z "$port" ] && [ "0$port" -lt 1024 ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
       #   warn "$check_5_8"
       #   warn "     * Privileged Port in use: $port in $c"
        ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Privileged Port in use: $port in $c"
	  fail=1
        else
        #  warn "     * Privileged Port in use: $port in $c"
        ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Privileged Port in use: $port in $c"
	fi
      fi
    done
  done
  # We went through all the containers and found no privileged ports
  if [ $fail -eq 0 ]; then
  #    pass "$check_5_8"
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No container has Privileged Port mapped"
	fi

# 5.9
  check_5_9="5.9 - Do not use host network mode on container"
  check=$(echo $check_5_9 | cut -d "-" -f 1)
  check_description=$(echo $check_5_9 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
    mode=$(docker inspect --format 'NetworkMode={{ .HostConfig.NetworkMode }}' "$c")

    if [ "$mode" = "NetworkMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
     #   warn "$check_5_9"
     #   warn "     * Container running with networking mode 'host': $c"
     ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running with networking mode 'host': $c"
	   fail=1
      else
    #    warn "     * Container running with networking mode 'host': $c"
     ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running with networking mode 'host': $c"
	 fi
    fi
  done
  # We went through all the containers and found no Network Mode host
  if [ $fail -eq 0 ]; then
    #  pass "$check_5_9"
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No container uses host network mode"
  fi

# 5.10
  check_5_10="5.10 - Limit memory usage for container"
  check=$(echo $check_5_10 | cut -d "-" -f 1)
  check_description=$(echo $check_5_10 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
    memory=$(docker inspect --format '{{ .HostConfig.Memory }}' "$c")

    if [ "$memory" = "0" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
     #   warn "$check_5_10"
     #   warn "     * Container running without memory restrictions: $c"
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running without memory restrictions: $c"
	  fail=1
      else
     #   warn "     * Container running without memory restrictions: $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running without memory restrictions: $c"
      fi
    fi
  done
  # We went through all the containers and found no lack of Memory restrictions
  if [ $fail -eq 0 ]; then
   #   pass "$check_5_10"
  ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "All containers are running with memory restrictions"
  fi

# 5.11
  check_5_11="5.11 - Set container CPU priority appropriately"
  check=$(echo $check_5_11 | cut -d "-" -f 1)
  check_description=$(echo $check_5_11 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
    shares=$(docker inspect --format '{{ .HostConfig.CpuShares }}' "$c")

    if [ "$shares" = "0" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
    #    warn "$check_5_11"
    #    warn "     * Container running without CPU restrictions: $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running without CPU restrictions: $c" 
   fail=1
      else
     #   warn "     * Container running without CPU restrictions: $c"
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running without CPU restrictions: $c"
	fi
    fi
  done
  # We went through all the containers and found no lack of CPUShare restrictions
  if [ $fail -eq 0 ]; then
    #  pass "$check_5_11"
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "All containers are running with proper CPU setting"
  fi

# 5.12
  check_5_12="5.12 - Mount container's root filesystem as read only"
  check=$(echo $check_5_12 | cut -d "-" -f 1)
  check_description=$(echo $check_5_12 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
   read_status=$(docker inspect --format '{{ .HostConfig.ReadonlyRootfs }}' "$c")

    if [ "$read_status" = "false" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
     #   warn "$check_5_12"
     #   warn "     * Container running with root FS mounted R/W: $c"
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running with root FS mounted R/W: $c"
        fail=1
      else
      #  warn "     * Container running with root FS mounted R/W: $c"
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container running with root FS mounted R/W: $c"
	fi
    fi
  done
  # We went through all the containers and found no R/W FS mounts
  if [ $fail -eq 0 ]; then
   #   pass "$check_5_12"
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "All containers have container's root filesystem mounted as read only"
  fi

# 5.13
  check_5_13="5.13 - Bind incoming container traffic to a specific host interface"
  check=$(echo $check_5_13 | cut -d "-" -f 1)
  check_description=$(echo $check_5_13 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')


  fail=0
  for c in $containers; do
    for ip in $(docker port "$c" | awk '{print $3}' | cut -d ':' -f1); do
      if [ "$ip" = "0.0.0.0" ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
        #  warn "$check_5_13"
        #  warn "     * Port being bound to wildcard IP: $ip in $c"
        ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Port being bound to wildcard IP: $ip in $c" 
	 fail=1
        else
      #    warn "     * Port being bound to wildcard IP: $ip in $c"
       ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Port being bound to wildcard IP: $ip in $c"
	 fi
      fi
    done
  done
  # We went through all the containers and found no ports bound to 0.0.0.0
  if [ $fail -eq 0 ]; then
    #  pass "$check_5_13"
    ./docker-bench-security-logging.sh "$check" "$check_description" "pass" "All containers are running without any bind to a specific host interface"
  fi

# 5.14
  check_5_14="5.14 - Do not set the 'on-failure' container restart policy to always"
  check=$(echo $check_5_14 | cut -d "-" -f 1)
  check_description=$(echo $check_5_14 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
    policy=$(docker inspect --format 'RestartPolicyName={{ .HostConfig.RestartPolicy.Name }}' "$c")

    if [ "$policy" = "RestartPolicyName=always" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
     #   warn "$check_5_14"
     #   warn "     * Restart Policy set to always: $c"
        ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Restart Policy set to always: $c"
	fail=1
      else
     #   warn "     * Restart Policy set to always: $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Restart Policy set to always: $c"
      fi
    fi
  done
  # We went through all the containers and found none with restart policy always
  if [ $fail -eq 0 ]; then
   #   pass "$check_5_14"
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "All containers are running without restart policy"
  fi

 # 5.15
  check_5_15="5.15 - Do not share the host's process namespace"
  check=$(echo $check_5_15 | cut -d "-" -f 1)
  check_description=$(echo $check_5_15 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
    mode=$(docker inspect --format 'PidMode={{.HostConfig.PidMode }}' "$c")

    if [ "$mode" = "PidMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
     #   warn "$check_5_15"
     #   warn "     * Host PID namespace being shared with: $c"
        ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Host PID namespace being shared with: $c"
	fail=1
      else
     #   warn "     * Host PID namespace being shared with: $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Host PID namespace being shared with: $c"
      fi
    fi
  done
  # We went through all the containers and found none with PidMode as host
  if [ $fail -eq 0 ]; then
    #  pass "$check_5_15"
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No container is sharing host PID"
  fi

 # 5.16
  check_5_16="5.16 - Do not share the host's IPC namespace"
  check=$(echo $check_5_16 | cut -d "-" -f 1)
  check_description=$(echo $check_5_16 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
    mode=$(docker inspect --format 'IpcMode={{.HostConfig.IpcMode }}' "$c")

    if [ "$mode" = "IpcMode=host" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
      #  warn "$check_5_16"
      #  warn "     * Host IPC namespace being shared with: $c"
       ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Host IPC namespace being shared with: $c"
	 fail=1
      else
      #  warn "     * Host IPC namespace being shared with: $c"
      ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Host IPC namespace being shared with: $c"
	fi
    fi
  done
  # We went through all the containers and found none with IPCMode as host
  if [ $fail -eq 0 ]; then
   #   pass "$check_5_16"
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No container is sharing the host's IPC namespace"
  fi

 # 5.17
  check_5_17="5.17 - Do not directly expose host devices to containers"
  check=$(echo $check_5_17 | cut -d "-" -f 1)
  check_description=$(echo $check_5_17 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

  fail=0
  for c in $containers; do
    devices=$(docker inspect --format 'Devices={{ .HostConfig.Devices }}' "$c")

    if [ "$devices" != "Devices=" -a "$devices" != "Devices=[]" -a "$devices" != "Devices=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
      #  info "$check_5_17"
     #   info "     * Container has devices exposed directly: $c"
       ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container has devices exposed directly: $c"
	 fail=1
      else
      #  info "     * Container has devices exposed directly: $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container has devices exposed directly: $c"
      fi
    fi
  done
  # We went through all the containers and found none with devices
  if [ $fail -eq 0 ]; then
   #   pass "$check_5_17"
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "No container has host devices exposed in directly"
  fi

 # 5.18
  check_5_18="5.18 - Override default ulimit at runtime only if needed"
  check=$(echo $check_5_18 | cut -d "-" -f 1)
  check_description=$(echo $check_5_18 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')


  # List all the running containers, ouput their ID and host devices
  fail=0
  for c in $containers; do
    ulimits=$(docker inspect --format 'Ulimits={{ .HostConfig.Ulimits }}' "$c")

    if [ "$ulimits" = "Ulimits=" -o "$ulimits" = "Ulimits=[]" -o "$ulimits" = "Ulimits=<no value>" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
      #  info "$check_5_18"
      #  info "     * Container no default ulimit override: $c"
     ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container no default ulimit override: $c"
	   fail=1
      else
      #  info "     * Container no default ulimit override: $c"
	./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Container no default ulimit override: $c"
      fi
    fi
  done
  # We went through all the containers and found none without Ulimits
  if [ $fail -eq 0 ]; then
    #  pass "$check_5_18"
	./docker-bench-security-logging.sh "$check" "$check_description" "pass" "All containers have default ulimit"
  fi




fi 

