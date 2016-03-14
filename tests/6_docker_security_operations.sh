#!/bin/sh

# logit "\n"
# info "6  - Docker Security Operations"

# 6.5
check_6_5="6.5 - Use a centralized and remote log collection service"
check=$(echo $check_6_5 | cut -d "-" -f 1)
check_description=$(echo $check_6_5 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

# If containers is empty, there are no running containers
if [ -z "$containers" ]; then
 # info "$check_6_5"
 # info "     * No containers running"
 ./docker-bench-security-logging.sh "$check" "$check_description" "info" "No containers running"
else
  fail=0
  set -f; IFS=$'
'
  for c in $containers; do
    volumes=$(docker inspect --format '{{ .Config.Volumes }}' "$c")

    if [ "$volumes" = "map[]" ]; then
      # If it's the first container, fail the test
      if [ $fail -eq 0 ]; then
      #  info "$check_6_5"
      #  info "     * Container has no volumes, ensure centralized logging is enabled : $c"
      ./docker-bench-security-logging.sh "$check" "$check_description" "info" "Container has no volumes, ensure centralized logging is enabled : $c"
        fail=1
      else
      #  info "     * Container has no volumes, ensure centralized logging is enabled : $c"
      ./docker-bench-security-logging.sh "$check" "$check_description" "info" "Container has no volumes, ensure centralized logging is enabled : $c"
      fi
    fi
  done
  # Only alert if there are no volumes. If there are volumes, can't know if they
  # are used for logs
fi
# Make the loop separator go back to space
set +f; unset IFS

# 6.6
check_6_6="6.6 - Avoid image sprawl"
check=$(echo $check_6_6 | cut -d "-" -f 1)
check_description=$(echo $check_6_6 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

images=$(docker images -q | sort -u | wc -l | awk '{print $1}')
active_images=0

for c in $(docker inspect -f "{{.Image}}" $(docker ps -qa)); do
  if docker images --no-trunc -a | grep "$c" > /dev/null ; then
    active_images=$(( active_images += 1 ))
  fi
done

if [ "$images" -gt 100 ]; then
 # warn "$check_6_6"
 # warn "     * There are currently: $images images"
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "There are currently: $images images"
else
 # info "$check_6_6"
 # info "     * There are currently: $images images"
 ./docker-bench-security-logging.sh "$check" "$check_description" "info" "There are currently: $images images"
fi

if [ "$active_images" -lt "$((images / 2))" ]; then
 # warn "     * Only $active_images out of $images are in use"
 ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "Only $active_images out of $images are in use"
fi

# 6.7
check_6_7="6.7 - Avoid container sprawl"
check=$(echo $check_6_7 | cut -d "-" -f 1)
check_description=$(echo $check_6_7 | cut -d "-" -f 2,3 | sed -e 's/^[ \t]*//')

total_containers=$(docker info 2>/dev/null | grep "Containers" | awk '{print $2}')
running_containers=$(docker ps -q | wc -l | awk '{print $1}')
diff="$((total_containers - running_containers))"
if [ "$diff" -gt 25 ]; then
 # warn "$check_6_7"
 # warn "     * There are currently a total of $total_containers containers, with only $running_containers of them currently running"
  ./docker-bench-security-logging.sh "$check" "$check_description" "warn" "There are currently a total of $total_containers containers, with only $running_containers of them currently running"
else
 # info "$check_6_7"
 # info "     * There are currently a total of $total_containers containers, with $running_containers of them currently running"
 ./docker-bench-security-logging.sh "$check" "$check_description" "info" "There are currently a total of $total_containers containers, with $running_containers of them currently running"
fi
