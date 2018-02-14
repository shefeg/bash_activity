#!/usr/bin/env bash

#Dry-run mode

LOG_FILE="test.log"
echo "---------------------------------------------" | tee -a $LOG_FILE
echo "Script start time: $(date +%Y-%m-%d_%H-%M-%S)" | tee -a $LOG_FILE
START=$(date +%s)

DATE=$(date +%Y-%m-%d_%H-%M)
TAG_KEY="Name"
TAG_NAMES=$(aws ec2 describe-tags --filters "Name=key,Values=Name" "Name=resource-type, Values=instance" --output text | awk '{print $5}')
INSTANCE_ID=$(aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].InstanceId' --filters "Name=tag-key,Values=$TAG_KEY" "Name=value,Values=$")

for tag_value in ${TAG_NAMES}; do
    echo "Requesting AMI for instance $tag_value..." | tee -a $LOG_FILE
    INSTANCE_ID=$(aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].InstanceId' --filters "Name=tag:Name,Values=$tag_value")
    aws ec2 create-image --instance-id $INSTANCE_ID --name "$(echo $tag_value - $DATE)" --description "$(echo $tag_value - $DATE)" --no-reboot --dry-run    #<-- DRY-RUN IS ADDED.
    echo $? | tee -a $LOG_FILE
    [ $? -eq 255 ] || echo "AMI request for \"$tag_value\" complete!" | tee -a $LOG_FILE
done

END=$(date +%s)
RUNTIME=$((END-START))

echo -e "\nScript runtime: ${RUNTIME}s" | tee -a $LOG_FILE
echo -e "--------------------------------------------\n\n" | tee -a $LOG_FILE