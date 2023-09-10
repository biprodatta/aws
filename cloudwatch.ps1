#Download the CloudWatch Agent installation package to the user's desktop.
Invoke-WebRequest -Uri https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi -OutFile $env:USERPROFILE\Downloads\amazon-cloudwatch-agent.msi

#Install the CloudWatch Agent
msiexec /i $env:USERPROFILE\Downloads\amazon-cloudwatch-agent.msi

Start-Sleep -s 40

Set-Location -Path 'C:\Program Files\Amazon\AmazonCloudWatchAgent'


#Apply CloudWatch Agent Configuration
.\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c file:"C:\ProgramFiles\windows-cloudwatch-config.json" -s


Get-Service amazoncloudwatchagent



