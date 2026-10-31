#!/bin/sh
# Dissects every tests/fixtures/*.txt (text2pcap hex dump, client -> port 7777)
# with the plugin from src/ and compares the Terraria tree with *.expected, then
# compares the registered fields (filter name, label, type) with tests/fields.expected.
# Usage: tests/run.sh [--update]
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
FIXTURES="$ROOT/tests/fixtures"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# An empty HOME hides an installed copy of the plugin from the personal plugin dir.
mkdir -p "$WORK/home"
export HOME="$WORK/home"
export XDG_CONFIG_HOME="$WORK/home/.config"
export LUA_PATH="$ROOT/src/?.lua;$ROOT/src/?/init.lua;;"

update=0
[ "${1:-}" = "--update" ] && update=1

failed=0
for fixture in "$FIXTURES"/*.txt; do
	name=$(basename "$fixture" .txt)
	pcap="$WORK/$name.pcap"
	actual="$WORK/$name.actual"
	expected="$FIXTURES/$name.expected"

	if ! text2pcap -q -T 50000,7777 "$fixture" "$pcap" >"$WORK/text2pcap.log" 2>&1; then
		cat "$WORK/text2pcap.log"
		exit 1
	fi

	{
		tshark -X "lua_script:$ROOT/src/terraria.lua" -r "$pcap" \
			-T fields -e frame.number -e _ws.col.info 2>&1
		tshark -X "lua_script:$ROOT/src/terraria.lua" -r "$pcap" -O terraria 2>&1 \
			| grep -vE '^(Frame|Ethernet II|Internet Protocol|Transmission Control Protocol)|^\s*$'
	} | sed -E 's/^ \*\* \(tshark:[0-9]+\) [0-9:.]+ /** /' >"$actual"

	if [ "$update" -eq 1 ]; then
		cp "$actual" "$expected"
		echo "updated $name"
	elif diff -u "$expected" "$actual"; then
		echo "ok      $name"
	else
		echo "FAIL    $name"
		failed=1
	fi
done

# The trees above show labels only; this catches renamed or retyped filter fields.
fields_actual="$WORK/fields.actual"
fields_expected="$ROOT/tests/fields.expected"
tshark -X "lua_script:$ROOT/src/terraria.lua" -G fields 2>&1 \
	| awk -F '\t' '$5 == "terraria" { print $3 "\t" $2 "\t" $4 }' \
	| LC_ALL=C sort >"$fields_actual"

if [ "$update" -eq 1 ]; then
	cp "$fields_actual" "$fields_expected"
	echo "updated fields"
elif diff -u "$fields_expected" "$fields_actual"; then
	echo "ok      fields"
else
	echo "FAIL    fields"
	failed=1
fi

exit "$failed"
