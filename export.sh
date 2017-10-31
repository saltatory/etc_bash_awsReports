#!/bin/bash
export output=`pwd`
export role="default sk ads slots solitaire-nonprod solitaire-prod"
export region="us-west-2"

export files="ec2.txt rds.txt redshift.txt"
for file in $files
do
	rm ${output}/${file}
done

for profile in $role
do
	echo $profile $output 
	aws ec2 describe-instances \
		--profile $profile --region $region \
		--output text \
		--query 'Reservations[*].Instances[*].[InstanceId, InstanceType, Placement.AvailabilityZone, Tags[?Key==`Name`] | [0].Value]' | \
	while read line
	do
		printf "${profile}\t${line}\n" >> ${output}/ec2.txt
	done

	aws rds describe-db-instances \
		--profile $profile \
		--region $region \
		--output text \
		--query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,Engine,MultiAZ, DBName, DBClusterIdentifier, StorageType]' | \
	while read line
	do
		printf "${profile}\t${line}\n" >> ${output}/rds.txt
	done

	aws redshift describe-clusters \
		--profile $profile \
		--region $region \
		--output text \
		--query 'Clusters[*].[ClusterIdentifier, NodeType, AvailabilityZone, ClusterNodes.Count, DBName]' | \
	while read line
	do
		printf "${profile}\t${line}\n" >> ${output}/redshift.txt
	done
done
