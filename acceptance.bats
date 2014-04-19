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

@test "we can count the correct number hosts" {
  run bash -c "ansible -i hosts all --list-hosts | wc -l | tr -d ' '"
  [ "$status" -eq 0 ]
  [ "$output" -eq 2 ]
}

@test "we can list hosts with tugboat" {
  run tugboat droplets
  [ "$status" -eq 0 ]
  [[ "$output" == *"production.web.1"* ]]
  [[ "$output" == *"active"* ]]
}

@test "per host serverspec tests pass" {
  run rake spec
  [ "$status" -eq 0 ]
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
