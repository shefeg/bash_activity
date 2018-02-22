# DESCRIPTION:
# This script will be usefull if your AWS account is hacked and you want terminate all EC2 instances,
# but don't want to suspend account.
# 1. Processes all instances in all regions
# 2. Enables API termination
# 3. Terminates instaces

REGION_LIST=$(aws ec2 describe-regions --output text | cut -f3)
for region in $REGION_LIST; do
	echo "Processing region $region:"
	INSTANCES_LIST=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --region $region --output text)
	for instance in $INSTANCES_LIST; do
		echo "Enable termination instance $instance"
		aws ec2 modify-instance-attribute --instance-id $instance --no-disable-api-termination --region $region
	done
	
	for i in $INSTANCES_LIST; do
		echo "Terminating $i"
		aws ec2 terminate-instances --instance-ids $i --region $region
	done
done