function start_infocenter {
	cd C:\Users\PhilippN\oxid\oxvm_eshop\
	vagrant up
	cd oxideshop
	code .
}

function remove_localUsers {
	$arr = Get-LocalUser
	for ($i = 0; $i -lt ($arr.length-1); $i++) {
		$arr[$i] | Remove-LocalUser
	}
}

function remove_users_except($user) {
	Get-WmiObject -Class Win32_UserProfile | where{ $_.LocalPath.split('\')[-1] -ne $user -and $_.LocalPath.split('\')[-1] -ne 'Administrator' } | foreach{ $_.Delete() }
}