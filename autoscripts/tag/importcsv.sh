#!/bin/bash 

DATABASE=botman

TABLE=t_bot_view

C=vall"$dt".csv

D=botman-master-sql

ACCESS_TOKEN="$(sudo gcloud auth application-default print-access-token)"
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" --header 'Content-Type: application/json' --data '{"importContext":
                {"fileType": "csv",
                 "uri": "'$C'",
                 "csvImportOptions": {
      "table": "'$TABLE'"
    },
                 "database": "'$DATABASE'" }}' -X POST https://www.googleapis.com/sql/v1beta4/projects/poetic-primer-844/instances/$D/import
