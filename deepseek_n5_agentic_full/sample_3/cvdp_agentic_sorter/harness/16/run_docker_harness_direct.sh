#!/bin/bash

# Auto-generated script to run harness Docker container
# Usage: run_docker_harness_direct.sh [-d] (where -d enables debug mode with bash entrypoint)
set -e

# Parse command line arguments
DEBUG_MODE=false
while getopts 'd' flag; do
  case "${flag}" in
    d) DEBUG_MODE=true ;;
  esac
done

# Use shared bridge network: cvdp-bridge-cvdp_v1-0-4_agentic_code_generation_no_commercial-ec
NETWORK_CREATED=0

# Check if network exists, create if needed
if ! docker network inspect cvdp-bridge-cvdp_v1-0-4_agentic_code_generation_no_commercial-ec &>/dev/null; then
  echo "Creating Docker network cvdp-bridge-cvdp_v1-0-4_agentic_code_generation_no_commercial-ec..."
  docker network create --driver bridge cvdp-bridge-cvdp_v1-0-4_agentic_code_generation_no_commercial-ec
  NETWORK_CREATED=1
fi

# Function to clean up resources
cleanup() {
  echo "Cleaning up Docker resources..."
  docker compose -f /home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/docker-compose.yml -p cvdp_agentic_sorter_16_1775579844 kill direct 2>/dev/null || true
  docker rmi cvdp_agentic_sorter_16_1775579844-direct 2>/dev/null || true
  if [ $NETWORK_CREATED -eq 1 ]; then
    echo "Removing Docker network cvdp-bridge-cvdp_v1-0-4_agentic_code_generation_no_commercial-ec..."
    docker network rm cvdp-bridge-cvdp_v1-0-4_agentic_code_generation_no_commercial-ec 2>/dev/null || true
  fi
}

# Set up cleanup trap
trap cleanup EXIT

# Run the harness container
echo "Running harness with project name: cvdp_agentic_sorter_16_1775579844"
# Get current user and group IDs
USER_ID=$(id -u)
GROUP_ID=$(id -g)

if [ "$DEBUG_MODE" = true ]; then
  echo "DEBUG MODE: Starting container with bash entrypoint"
  docker compose -f /home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/docker-compose.yml -p cvdp_agentic_sorter_16_1775579844 run --rm --user $USER_ID:$GROUP_ID -e HOME=/code/rundir --entrypoint bash -v "/home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/docs:/code/docs" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/rundir:/code/rundir" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/rtl:/code/rtl" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/verif:/code/verif" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/src:/code/src" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/src/llm_lib:/pysubj" --rm -w /code/rundir direct
else
  docker compose -f /home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/docker-compose.yml -p cvdp_agentic_sorter_16_1775579844 run --rm --user $USER_ID:$GROUP_ID -e HOME=/code/rundir -v "/home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/docs:/code/docs" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/rundir:/code/rundir" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/rtl:/code/rtl" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/verif:/code/verif" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/deepseek_n5_agentic_full/sample_3/cvdp_agentic_sorter/harness/16/src:/code/src" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/src/llm_lib:/pysubj" --rm -w /code/rundir direct
fi
exit_code=$?

# Exit with the same code as the docker command
exit $exit_code
