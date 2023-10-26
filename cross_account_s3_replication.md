# S3 Cross Account Replication

### What is S3 Replication?
S3 Replication refers to the process of copying the contents of a S3 bucket to another S3 bucket automatically without any manual intervention, post the setup process. The destination bucket can be in the same region as the source bucket or even different region from the source bucket.

# What is S3 Cross Account Replication?
S3 Cross Account Replication refers to copying the contents of the S3 bucket from one account to another S3 bucket in a different account. It's possible that both the accounts may or may not be owned by the same individual or organization.

## The below is a hands on tutorial to perform S3 Cross Account Replication Requirement
Replicate the contents of the source bucket → ‘may-medium-bucket’ in ‘Data’ account to the below destination buckets:

    ● ‘may-medium-bucket-replica-dev’ in ‘Dev’ account
    ● ‘may-medium-bucket-replica-test’ in ‘Test’ account

## Pre-Requisites
All the buckets — source and destination should have ‘Bucket Versioning’ enabled (This can be
set at the time of bucket creation)

Create the following S3 buckets in their respective account:
‘may-medium-bucket’ in ‘Data’ account
‘may-medium-bucket-replica-dev’ in ‘Dev’ account
‘may-medium-bucket-replica-test’ in ‘Test’ account

## Changes — High Level
Changes required to configure S3 Cross Account Replication are:
    1. Create a role for cross account replication in the source account (in this case is
    ‘Data’ account)
    2. Create a replication rule against the source bucket in the source account (‘Data’
    account) to destination buckets in destination accounts (‘Dev’ and ‘Test’ account)
    3. Apply a bucket policy on the destination bucket in destination account (‘Dev’ and
    ‘Test’ account)
## 1. Create a role for cross account replication in the source account

    1. Navigate to IAM console in the ‘Data’ account

    2. Create a policy. Provide a name to the policy (say ‘cross-account-bucket-replication-policy’) and add policy contents based on the below syntax:

    ```json
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "GetSourceBucketConfiguration",
        "Effect": "Allow",
        "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:GetBucketAcl",
            "s3:GetReplicationConfiguration",
            "s3:GetObjectVersionForReplication",
            "s3:GetObjectVersionAcl",
            "s3:GetObjectVersionTagging"
        ],
        "Resource": [
            "arn:aws:s3:::original-bucket-may",
            "arn:aws:s3:::original-bucket-may/*"
        ]
        },
        {
        "Sid": "ReplicateToDestinationBuckets",
        "Effect": "Allow",
        "Action": [
            "s3:List*",
            "s3:*Object",
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags"
        ],
        "Resource": [
            "arn:aws:s3:::original-bucket-may-replica-dev/*",
            "arn:aws:s3:::original-bucket-may-replica-prod/*"
        ]
        },
        {
        "Sid": "PermissionToOverrideBucketOwner",
        "Effect": "Allow",
        "Action": [
            "s3:ObjectOwnerOverrideToBucketOwner"
        ],
        "Resource": [
            "arn:aws:s3:::original-bucket-may-replica-dev/*",
            "arn:aws:s3:::original-bucket-may-replica-prod/*"
        ]
        }
    ]
    }
    ```

3. Important points to note with respect to the above specified policy statement:

● Line # 17 and # 18 refers to the source bucket in ‘Data’ account.
● Line # 32, 33, 42, 43 refers to the destination buckets in ‘Dev’ account and ‘Prod’ account.

4. The above policy has 3 statements:

    ● Sid — ‘GetSourceBucketConfiguration’ → provides access to get replication
    configuration and to get object version for replication on the source bucket
    ● Sid — ‘ReplicateToDestinationBuckets’ → provides access to replicate to the
    destination buckets. Multiple destination buckets can be specified in the array
    ● Sid — ‘PermissionToOverrideBucketOwner’ → provides access to
    ObjectOwnerOverrideToBucketOwner so that the destination bucket can own the
    replicated objects in the destination account that were replicated from the source
    account

5. Save the policy

6. Create a role with the following information:

7. Select service as S3

8. Select use case as ‘Allow S3 to call AWS Services on your behalf’

9. Select the policy created above

10. Provide a name to the role (say ‘cross-account-bucket-replication-role’) and save the role

## 2 — Create a replication rule against the source bucket in the source account

1. Navigate to the source bucket in the ‘Data’ account → ‘original-bucket-may’ and go to the
‘Management’

2. Create a replication rule with the following as inputs:
    ● Provide a rule name → example: ‘replicate-to-dev’
    ● Set status as ‘Enabled’
    ● Choose rule scope as “This rule applies to all objects in the bucket” (Choose as
    needed)
    ● Select the destination to be a bucket in another account. Enter the destination
    account # and the destination bucket name. In this case enter the ‘Dev’ account #
    and destination bucket name as ‘original-bucket-may-replica-dev’
    ● Select option to change object ownership to destination bucket owner
    ● Select IAM role as the role created as part of the step ‘#1 — Create a role in the
    source account’
    ● Select all the available additional replication options. These provide ability to
    replicate content quickly, monitor the progress of replication through cloudwatch
    metrics, replicate delete markers and replicate metadata changes
    ● Save

3. In case of multiple destination buckets, create another replication rule but this time to replicate to ‘Prod’ account with destination bucket as ‘original-bucket-may-replica-prod’

## 3 — Apply a bucket policy on the destination bucket
    1.This step has to be performed for each destination bucket individually in each of the accounts.

    2. Navigate to destination bucket in its respective account → say ‘original-bucket-may-replica-dev’ in ‘Dev’ account.

    3. Navigate to the permissions tab, edit bucket policy by providing the below and save the policy:

    ```json
    {
    "Version": "2012-10-17",
    "Id": "PolicyForDestinationBucket",
    "Statement": [
        {
        "Sid": "Permissions on objects and buckets",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::999999999999:role/cross-account-bucket-replication-role"
        },
        "Action": [
            "s3:List*",
            "s3:GetBucketVersioning",
            "s3:PutBucketVersioning",
            "s3:ReplicateDelete",
            "s3:ReplicateObject"
        ],
        "Resource": [
            "arn:aws:s3:::original-bucket-may-replica-dev",
            "arn:aws:s3:::original-bucket-may-replica-dev/*"
        ]
        },
        {
        "Sid": "Permission to override bucket owner",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::999999999999:root"
        },
        "Action": "s3:ObjectOwnerOverrideToBucketOwner",
        "Resource": "arn:aws:s3:::original-bucket-may-replica-dev/*"
        }
    ]
    }
    ```
4. Important points to note with respect to the above specified policy statement:

    ● Line # 9 refers to the role arn created as part of #1 — Create a role in the source
    account
    ● Line # 19, # 20 and #30 refers to the destination bucket. In this specific case, its
    destination bucket in ‘Dev’ account

5. The above policy has 2 statements:

    Sid — ‘Permissions on objects and buckets’ → Indicates that the destination bucket specified on
    line # 19, 20 can replicate content based on the role defined in the source account as on line # 9.
    The role will have the source bucket

    Sid — ‘Permission to override bucket owner’ → Indicates that the destination bucket specified
    on line #30 has permission to override the ownership from source account mentioned on line # 34

6. If there are multiple destination buckets to replicate in different account, repeat the above
steps. In this example, repeat the above steps for ‘original-bucket-may-replica-prod’ in the ‘Prod’
account. 
Below is the policy specific to this destination bucket — ‘original-bucket-may-replica-prod’

```json
{
  "Version": "2012-10-17",
  "Id": "PolicyForDestinationBucket",
  "Statement": [
    {
      "Sid": "Permissions on objects and buckets",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::999999999999:role/cross-account-bucket-replication-role"
      },
      "Action": [
        "s3:List*",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning",
        "s3:ReplicateDelete",
        "s3:ReplicateObject"
      ],
      "Resource": [
        "arn:aws:s3:::original-bucket-may-replica-prod/*",
        "arn:aws:s3:::original-bucket-may-replica-prod"
      ]
    },
    {
      "Sid": "Permission to override bucket owner",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::999999999999:root"
      },
      "Action": "s3:ObjectOwnerOverrideToBucketOwner",
      "Resource": "arn:aws:s3:::original-bucket-may-replica-prod/*"
    }
  ]
}
```
## Verification Test
    ● Add an object in the source bucket
    ● The added object will reflect in the destination buckets under their respective
    accounts
    ● To watch cloud watch metrics, go to the source bucket → Select the tab ‘Metrics’
    ● Scroll down to the sub-section — ‘Replication Metrics’ and select replication rule
    ● Select the option to ‘Display Charts’. This will show charts for → Operations
    pending replication, Replication Latency and Bytes pending replication. This will
    help to reflect the state of replication