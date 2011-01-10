#!/bin/bash
# web.sh -- http://localhost:9009/
#folder=folder_with_imges
cd $folder

stderr() {
  echo "$@" 1>&2
}

[[ -z "$RESP" ]] && RESP=/tmp/webresp
[ -p $RESP ] || mkfifo $RESP

while true ; do
	( cat $RESP ) | nc -l -p 9009 | (
		REQ=$(while read L && [ " " "<" "$L" ] ; do echo "$L" ; done)
		stderr "$REQ"
		stderr "[`date '+%Y-%m-%d %H:%M:%S'`] ${REQ%%$'\n'*}"

		REQ=${REQ#* } REQ=${REQ% HTTP*}

    page=$(cat foo.esh | sed 's/{{ myvar }}/lolwut/g')

    {
      echo
      echo -e HTTP/1.1 200 OK
      echo Content-Type: text/html
      echo Server: bash/2.0
      echo Connection: Close
      echo Content-Length: ${#page}
      echo 

      echo "$page"

      echo
    } > $RESP
    stderr END
	)
done
