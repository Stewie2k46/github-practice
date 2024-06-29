import boto3

AWS_REGION = "ap-south-1"
ec2 = boto3.client("ec2", region_name=AWS_REGION)

def get_unattached_volumes():
    response = ec2.describe_volumes(Filters=[{"Name": "status", "Values": ["available"]}])
    return [vol["VolumeId"] for vol in response["Volumes"]]

def delete_volume(volume_id):
    try:
        ec2.delete_volume(VolumeId=volume_id)
        print(f"Deleted volume {volume_id}")
    except Exception as e:
        print(f"Error deleting volume {volume_id}: {str(e)}")

if __name__ == "__main__":
    unattached_volumes = get_unattached_volumes()
    for vol_id in unattached_volumes:
        delete_volume(vol_id)
