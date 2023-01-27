# store arguments in variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# check all five arguments that are available in bash command
if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi
# find host_info table columns values
hostname=$(hostname -f)
cpu_number=$(lscpu | grep '^CPU(s):' | awk '{print $2}' | xargs)
cpu_architecture=$(lscpu | grep '^Architecture:' | awk '{print $2}' | xargs)
cpu_model=$(lscpu | grep '^Model name:' | awk -F 'Model name:' '{print $2}' | xargs)
cpu_mhz=$(lscpu | grep '^CPU MHz:' | awk -F 'MHz:' '{print $2}' | xargs)
L2_cache=$(lscpu | grep '^L2 cache:' | awk -F 'cache:' '{print $2}' | xargs | tr -dc '0-9')
total_mem=$(vmstat -s --unit M | grep 'total memory' | awk '{print $1}')
date=$(date '+%F %T')

#insert data into table host_info
insert_stmt="INSERT INTO host_info VALUES (DEFAULT,'$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model','$cpu_mhz', '$L2_cache', '$date' , '$total_mem')"

#set up env var for pql cmd
export PGPASSWORD=$psql_password
#Insert data into a database
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"

exit
$?
