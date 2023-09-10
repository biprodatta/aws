# aws

## useful commands:

#### command for copy a local db backup(present in same directory to s3 bucket with KMS key enabled)
aws s3 cp abc.bak s3://abc-app-dev --sse aws:kms --sse-kms-key-id arn:aws:kms:us-east-1:123456789012:key/1aceaf9c-ec5b-425a-b9b5-c5bee82am424

## useful Links


https://devopscube.com/mount-ebs-volume-ec2-instance/

https://stackoverflow.com/questions/11014584/ec2-cant-resize-volume-after-increasing-size
https://stackoverflow.com/questions/26770655/ec2-storage-attached-at-sda-is-dev-xvde1-cannot-resize
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html

https://aws.amazon.com/blogs/aws/aws-database-migration-service/


https://www.blazemeter.com/blog/how-to-integrate-your-github-repository-to-your-jenkins-project/