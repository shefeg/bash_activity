#!/usr/bin/env bash

#Dry-run mode

echo "---------------------------------------------"
echo "Script start time: $(date +%Y-%m-%d_%H-%M-%S)"
START=$(date +%s)

DATE=$(date +%Y-%m-%d_%H-%M)
TAG_KEY="Name"
TAG_NAMES=$(aws ec2 describe-tags --filters "Name=key,Values=Name" "Name=resource-type, Values=instance" --output text | awk '{print $5}')

for tag_value in ${TAG_NAMES}; do
    echo "Requesting AMI for instances in \"$tag_value\"..."
    INSTANCE_IDS=$(aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].InstanceId' --filters "Name=tag:Name,Values=$tag_value")
    for instance in $INSTANCE_IDS; do
        echo "Making AMI for instance: \"$instance\""
        aws ec2 create-image --instance-id $instance --name "$(echo $tag_value - $DATE)" --description "$(echo $tag_value - $DATE)" --no-reboot --dry-run    #<-- DRY-RUN IS ADDED.
        echo $?
        [ $? -eq 255 ] || echo "AMI for instance \"$instance\" complete!"
    done
done

END=$(date +%s)
RUNTIME=$((END-START))

echo -e "\nScript runtime: ${RUNTIME}s"
echo -e "--------------------------------------------\n\n"