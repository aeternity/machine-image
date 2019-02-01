#!/usr/bin/env python
import boto3
from botocore.exceptions import ClientError

REGIONS = [
    "us-west-2",
    "eu-central-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "eu-west-2",
    "us-east-2",
    "eu-north-1"
]

AETERNITY_IMAGE_NAMES = [
    "aeternity-ubuntu-16.04",
    "epoch-ubuntu-16.04"
]

def get_account_id():
    sts = boto3.client("sts")
    return sts.get_caller_identity()["Account"]

def get_stale_amis(ec2_client, aeternity_image_names):
    amis = []

    image_names = []

    # Add wildcard to the list (or string) of image names.
    if isinstance(aeternity_image_names, list):
        image_names = [ "{0}*".format(image) for image in aeternity_image_names ]
    elif isinstance(aeternity_image_names, basestring):
        image_names = [ aeternity_image_names + "*" ]
    else:
        return []

    images = ec2_client.describe_images(
        Filters = [
            {
                "Name": "name",
                "Values": image_names
            }
        ],
        Owners = [
            get_account_id()
        ]
    )
    used_amis = get_used_amis(ec2_client)
    print(("Found used AMI: \n %s \n" % ( used_amis )))


    for image in images["Images"]:
        if image["ImageId"] not in used_amis:
            snaps = []
            for block in image["BlockDeviceMappings"]:
                if "Ebs" in block:
                    snaps.append(block["Ebs"]["SnapshotId"])
            amis.append({"ImageId": image["ImageId"],"CreationDate": image["CreationDate"],"Snapshots": snaps})

    amis.sort(key=lambda image: image["CreationDate"], reverse = True)

    print(("Not used AMI with snapshots:  \n %s \n") % (amis))

    return amis[3:]

def get_used_amis(ec2_client):
    used_amis = []
    response = ec2_client.describe_instances()

    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            used_amis.append(instance["ImageId"])
    return list(set(used_amis))

def deregister(ec2_client, ids):
    # Protect against empty list (from get_stale_amis) and potentially
    # deleting something that we do not want. Unclear how AWS/Boto
    # will handle empty list.
    if not ids:
        print("No ids to deregister")
        return

    print(("List to deregister: \n %s \n") % (ids))
    for i in ids:

        ec2_client.deregister_image(
            ImageId = i["ImageId"]
        )

        for snap in i["Snapshots"]:
            ec2_client.delete_snapshot(
                SnapshotId = snap
            )

try:
    for region in REGIONS:
        print(("Working in region: %s" % ( region )))
        ec2_client = boto3.client('ec2',region_name=region)
        deregister(ec2_client, get_stale_amis(ec2_client, AETERNITY_IMAGE_NAMES))

except:
    print("Unexpected error:", sys.exc_info()[0])
    exit(1)
