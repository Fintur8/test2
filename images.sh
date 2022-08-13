count=$(curl -s -u admin:vg52xgt72! -X GET http://192.168.1.8:8081/service/rest/v1/search?repository=${1} |
 jq '.items[].name' | wc -l)
if [ $count -eq 0 ]
then
        echo "no-images"
else
        curl -s -u admin:vg52xgt72! -X GET http://192.168.1.8:8081/service/rest/v1/search?repository=${1} | jq '.items[] | .name + ":" + .version' | sed 's/"//g'
fi
