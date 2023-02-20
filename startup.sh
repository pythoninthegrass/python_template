#!/usr/bin/env sh

# shellcheck disable=SC1091,SC2034,SC2086,SC2153,SC2236,SC3037,SC3045,SC2046

if [ "$(uname -s)" = "Darwin" ]; then
	export VENV=".venv"
else
	export VENV="/opt/venv"
fi
export PATH="${VENV}/bin:$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

# . "${VENV}/bin/activate"

# BASE_DIR="$(dirname "$(readlink -f "$0")")"
# SRV_DIR="${BASE_DIR}/app/commerce"

move_port() {
	echo "Port $1 is in use, trying $PORT"
	while [ ! -z "$(lsof -i :$PORT | grep LISTEN | awk '{print $2}')" ]; do
		echo "Port $PORT is in use, trying $((PORT+1))"
		PORT=$((PORT+1))
	done
	echo "Port $PORT is available. Using it instead of $1"
}

port_check() {
	if [ -z "$1" ]; then
		PORT=8000
	elif [ "$1" -gt 0 ] 2>/dev/null; then
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
