#!/usr/bin/env sh

# shellcheck disable=SC1091,SC2034,SC2086,SC2153,SC2236,SC3037,SC3045,SC2046

if [ "$(uname -s)" = "Darwin" ]; then
	export VENV=".venv"
else
	export VENV="/opt/venv"
fi
export PATH="${VENV}/bin:$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

# get the root directory
GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

if [ -n "$GIT_ROOT" ]; then
	TLD="$(git rev-parse --show-toplevel)"
else
	TLD="${SCRIPT_DIR}"
fi

# expect the .env file to be in the root directory
ENV_FILE="${TLD}/.env"

# source .env file skipping commented lines
[ -f "${ENV_FILE}" ] && export $(grep -v '^#' ${ENV_FILE} | xargs)

# iterate to an available port
move_port() {
	echo "Port $1 is in use, trying $PORT"
	while [ ! -z "$(lsof -i :$PORT | grep LISTEN | awk '{print $2}')" ]; do
		echo "Port $PORT is in use, trying $((PORT+1))"
		PORT=$((PORT+1))
	done
	echo "Port $PORT is available. Using it instead of $1"
}

# check if port is available
port_check() {
	if [ $# -eq 0 ] && [ -z $PORT ]; then
		PORT=8000
	elif [ $# -gt 0 ] 2>/dev/null; then
		PORT="$1"
	fi
	[ -z "$(lsof -i :$PORT | grep LISTEN | awk '{print $2}')" ] || move_port "$PORT"
}

server() {
	# gunicorn/uvicorn
	gunicorn -w 2 -k uvicorn.workers.UvicornWorker main:app -b "0.0.0.0:${PORT}" --log-file -

	# django
	# python "${SRV_DIR}/manage.py" runserver
}

main() {
	port_check "$@"
	server
}
main "$@"
