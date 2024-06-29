import boto3

def get_all_regions():
    ec2 = boto3.client('ec2')
    response = ec2.describe_regions()
    regions = [region['RegionName'] for region in response['Regions']]
    return regions

def get_unattached_volumes(ec2_client):
    response = ec2_client.describe_volumes(Filters=[{"Name": "status", "Values": ["available"]}])
    return [vol["VolumeId"] for vol in response["Volumes"]]

def delete_volume(ec2_client, volume_id):
    try:
        ec2_client.delete_volume(VolumeId=volume_id)
        print(f"Deleted volume {volume_id}")
    except Exception as e:
        print(f"Error deleting volume {volume_id}: {str(e)}")

if __name__ == "__main__":
    regions = get_all_regions()
    
    for region in regions:
        ec2_client = boto3.client('ec2', region_name=region)
        unattached_volumes = get_unattached_volumes(ec2_client)
        
        for vol_id in unattached_volumes:
            delete_volume(ec2_client, vol_id)
