# store arguments in variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

hostname=$(hostname -f)

# check all five arguments are available in bash command
if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi
# find host_usage table columns values
memory_free=$(vmstat --unit M | tail -1 | awk '{print $4}' | xargs)
cpu_idel=$(vmstat --unit M | tail -1 | awk -v col="15" '{print $col}' | xargs)
cpu_kernel=$(vmstat --unit M | tail -1 | awk -v col="14" '{print $col}' | xargs)
disk_io=$(vmstat --unit M -d | tail -1 | awk -v col="9" '{print $col}' | xargs)
disk_available=$(df -BM | tail -1 | awk '{print $4}' | xargs | tr -dc '0-9')
timestamp=$(vmstat --unit M -t | tail -1 | awk '{print $18, $19}' | xargs)

#insert data into table host_usage
insert_stmt="INSERT INTO host_usage ("timestamp", host_id , memory_free , cpu_idel , cpu_kernel, disk_io , disk_available) select '$timestamp', "id" , '$memory_free' , '$cpu_idel' , '$cpu_kernel', '$disk_io' , '$disk_available' from host_info where hostname='$hostname' "

#set up env var for pql cmd
export PGPASSWORD=$psql_password
#Insert data into a database
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"

exit
$?
