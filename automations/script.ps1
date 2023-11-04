# input variable value

$client = Get-Content input.json | jq -r ". | keys[0]"
$clientid = Get-Content input.json | jq -r ".$client.ClientId"
$clientsecret = Get-Content input.json | jq -r ".$client.ClientSecret"
$authenticationtype = Get-Content input.json | jq -r ".$client.AuthenticationType"
$channeltype = Get-Content input.json | jq -r ".$client.ChannelType"
$usertype = Get-Content input.json | jq -r ".$client.UserType"
$priorityorder = Get-Content input.json | jq -r ".$client.PriorityOrder"

# update script
$all = Get-Content client_details.json | ConvertFrom-Json

$all.AccountSettings | Foreach-Object { if ($_.CustomizationKey -eq $client) {
        $b = $_.Channels
        $b | Foreach-Object { if ($_.ChannelType -eq "External") {
                $_.ClientId =  $clientid
                $_.ClientSecret = $clientsecret
                $_.AuthenticationType = $authenticationtype
                $_.ChannelType = $channeltype
                $_.UserType = $usertype
                $_.PriorityOrder = $priorityorder
                Write-Output $_
            }
        }
    } 
} | ConvertTo-Json -Depth 10

$all | ConvertTo-Json -depth 32 | set-content '/Users/biprodatta/Documents/GitHub/aws/automations/updated_client_details.json'