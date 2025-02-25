#!/usr/bin/env sh
INSTALLER=""
check_available_installer() {
  # check if uv is installed
  if command -v uv > /dev/null 2>&1; then
    echo "uv is installed"
    INSTALLER="uv"
    return
  fi
  echo "No valid installer is not installed"
  echo "Please install pipx or uv in your Dockerfile/VM image before running this script"
  exit 1
}

if [ -n "${BASE_URL}" ]; then
  BASE_URL_FLAG="--ServerApp.base_url=${BASE_URL}"
fi

BOLD='\033[0;1m'

# check if jupyterlab is installed
if ! command -v jupyter-lab > /dev/null 2>&1; then
  # install jupyterlab
  check_available_installer
  printf "$${BOLD}Installing jupyterlab!\n"
  case $INSTALLER in
    uv)
      uv pip install -q jupyterlab \
        && printf "%s\n" "🥳 jupyterlab has been installed"
      JUPYTERPATH="$HOME/.venv/bin/"
      ;;
    pipx)
      pipx install jupyterlab \
        && printf "%s\n" "🥳 jupyterlab has been installed"
      JUPYTERPATH="$HOME/.local/bin"
      ;;
  esac
else
  printf "%s\n\n" "🥳 jupyterlab is already installed"
fi


printf "☢️ unsetting proxy vars..."
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY

printf "👷 Starting jupyterlab in background..."
printf "check logs at ${LOG_PATH}"
$JUPYTERPATH/jupyter-lab --no-browser \
  "$BASE_URL_FLAG" \
  --ServerApp.ip='*' \
  --ServerApp.port="${PORT}" \
  --ServerApp.token='' \
  --ServerApp.password='' \
  > "${LOG_PATH}" 2>&1 &
