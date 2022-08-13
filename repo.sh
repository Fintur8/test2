curl -s -u admin:vg52xgt72! http://192.168.1.8:8081/service/rest/v1/repositories | jq '.[] | select ( .format == "docker" ) | .name ' | sed 's/"//g'
