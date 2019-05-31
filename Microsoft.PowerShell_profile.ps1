function start_infocenter {
	cd C:\Users\PhilippN\oxid\oxvm_eshop\
	vagrant up
	cd oxideshop
	code .
}

function remove_local_users {
	$arr = Get-LocalUser
	for ($i = 0; $i -lt ($arr.length-1); $i++) {
		$arr[$i] | Remove-LocalUser
	}
}

function remove_domain_users {
    $loggedInUser = Get-WMIObject -class Win32_ComputerSystem | select username | foreach {$_.username.split('\')[1]}
	# Get all users in User folder that are not Administrator or logged in user.
    $users = Get-WmiObject -Class Win32_UserProfile | where{ $_.LocalPath.split('\')[1] -eq 'Users' -and $_.LocalPath.split('\')[-1] -ne $loggedInUser -and $_.LocalPath.split('\')[-1] -ne 'Administrator' }
    if ($users) {
        foreach ($user in $users) {
            $user.Delete()
        }
    }
}