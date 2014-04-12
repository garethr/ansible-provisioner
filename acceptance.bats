#!/usr/bin/env bats

@test "no droplets exist" {
  run tugboat droplets
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "You don't appear to have any droplets." ]
}

@test "provisioner runs successfully" {
  run ansible-playbook -i hosts provision_digital_ocean.yml
  [ "$status" -eq 0 ]
}

@test "we can list hosts with ansible" {
  run ansible -i hosts all --list-hosts
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" == *"localhost"* ]]
}

@test "we can list hosts with tugboat" {
  run tugboat droplets
  [ "$status" -eq 0 ]
  [[ "$output" == *"production.web.1"* ]]
  [[ "$output" == *"active"* ]]
}

@test "clean up all droplets" {
  run tugboat destroy production.web.1 -c
  [ "$status" -eq 0 ]
}

@test "droplets have been cleaned up" {
  sleep 5 # the droplets are destroyed asyncronously
  run tugboat droplets
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "You don't appear to have any droplets." ]
}
