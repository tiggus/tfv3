sts () {
    export account="123456" 
    export tfprofile=$(cat ~/.aws/config | grep -B2 $account | grep -m 1 profile | sed -e 's/\[profile //g' -e 's/\]//g')
    aws-assume $tfprofile
    export sts=$(aws sts get-caller-identity --output json | jq -r '.Account')
    if [ "$account" = "$sts" ]; then
        echo \\n"\033[32msts / account -> \033[0m" "[ $account / $sts ]"
        echo \\n"\033[32mprofile ->\033[0m" $tfprofile
        echo \\n"\033[32mterraform ->\033[0m" fmt
        terraform fmt
        # echo \\n"\033[32mterraform ->\033[0m" vars\\n

        # export ec2s=$(aws ec2 describe-instances --output json | jq -r '.Reservations[].Instances[].InstanceId' | xargs | sed -e 's/ /","/g')
        # export ec2var="instance_ids"
        # export ec2tf=$(echo 'variable "'$ec2var'" {'\\n'  default = ["'$ec2s'"]'\\n"  type = list"\\n"}")
        # echo $ec2tf

        # export buckets_euw1=$(aws s3api list-buckets  --region eu-west-1 --bucket-region eu-west-1 --output json | jq -r '.Buckets[].Name' | xargs | sed -e 's/ /","/g')
        # export bucketvar_euw1="bucket_ids_euw1"
        # export buckettf_euw1=$(echo 'variable "'$bucketvar_euw1'" {'\\n'  default = ["'$buckets_euw1'"]'\\n"  type = set(string)"\\n"}")
        # echo $buckettf_euw1

        # export buckets_euw2=$(aws s3api list-buckets  --region eu-west-2 --bucket-region eu-west-2 --output json | jq -r '.Buckets[].Name' | xargs | sed -e 's/ /","/g')
        # export bucketvar_euw2="bucket_ids_euw2"
        # export buckettf_euw2=$(echo 'variable "'$bucketvar_euw2'" {'\\n'  default = ["'$buckets_euw2'"]'\\n"  type = set(string)"\\n"}")
        # echo $buckettf_euw2

        # export sqs=$(aws sqs list-queues --max-items 1000 --output json  | jq -r '.QueueUrls[]' | sed 's/.*\///' | xargs | sed -e 's/ /","/g')
        # export sqsvar="sqs_queues"
        # export sqstf=$(echo 'variable "'$sqsvar'" {'\\n'  default = ["'$sqs'"]'\\n"  type = list"\\n"}")

        # file='variables.tf'
        # touch $file
        # grep -qF -- "$ec2var" "$file" || echo "$ec2tf" >> "$file" 
        # grep -qF -- "$bucketvar_euw1" "$file" || echo "$buckettf_euw1" >> "$file" 
        # grep -qF -- "$bucketvar_euw2" "$file" || echo "$buckettf_euw2" >> "$file" 
        # grep -qF -- "$sqsvar" "$file" || echo "$sqstf" >> "$file"

    else
        echo \\n"\033[31merror ->\033[0m" account mismatch
    fi
}

sts
