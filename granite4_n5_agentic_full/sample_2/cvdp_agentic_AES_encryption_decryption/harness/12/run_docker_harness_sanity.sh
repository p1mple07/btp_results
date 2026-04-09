#!/bin/bash

# Auto-generated script to run harness Docker container
# Usage: run_docker_harness_sanity.sh [-d] (where -d enables debug mode with bash entrypoint)
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
  docker compose -f /home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/docker-compose.yml -p cvdp_agentic_aes_encryption_decryption_12_1775669183 kill sanity 2>/dev/null || true
  docker rmi cvdp_agentic_aes_encryption_decryption_12_1775669183-sanity 2>/dev/null || true
  if [ $NETWORK_CREATED -eq 1 ]; then
    echo "Removing Docker network cvdp-bridge-cvdp_v1-0-4_agentic_code_generation_no_commercial-ec..."
    docker network rm cvdp-bridge-cvdp_v1-0-4_agentic_code_generation_no_commercial-ec 2>/dev/null || true
  fi
}

# Set up cleanup trap
trap cleanup EXIT

# Run the harness container
echo "Running harness with project name: cvdp_agentic_aes_encryption_decryption_12_1775669183"
# Get current user and group IDs
USER_ID=$(id -u)
GROUP_ID=$(id -g)

if [ "$DEBUG_MODE" = true ]; then
  echo "DEBUG MODE: Starting container with bash entrypoint"
  docker compose -f /home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/docker-compose.yml -p cvdp_agentic_aes_encryption_decryption_12_1775669183 run --rm --user $USER_ID:$GROUP_ID -e HOME=/code/rundir --entrypoint bash -v "/home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/docs:/code/docs" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/rundir:/code/rundir" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/rtl:/code/rtl" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/verif:/code/verif" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/src:/code/src" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/src/llm_lib:/pysubj" --rm -w /code/rundir --env OPENAI_USER_KEY=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 sanity
else
  docker compose -f /home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/docker-compose.yml -p cvdp_agentic_aes_encryption_decryption_12_1775669183 run --rm --user $USER_ID:$GROUP_ID -e HOME=/code/rundir -v "/home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/docs:/code/docs" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/rundir:/code/rundir" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/rtl:/code/rtl" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/verif:/code/verif" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/granite4_n5_agentic_full/sample_2/cvdp_agentic_AES_encryption_decryption/harness/12/src:/code/src" -v "/home/shashwat/btp/innocent/slm_agent_cvdp/src/llm_lib:/pysubj" --rm -w /code/rundir --env OPENAI_USER_KEY=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 sanity
fi
exit_code=$?

# Exit with the same code as the docker command
exit $exit_code
