$text = '
	 /$$$$$$$   /$$$$$$  /$$    /$$  /$$$$$$  /$$   /$$ /$$$$$$$$
	| $$__  $$ /$$__  $$| $$   | $$ /$$__  $$| $$  | $$|__  $$__/
	| $$  \ $$| $$  \__/| $$   | $$| $$  \ $$| $$  | $$   | $$   
	| $$$$$$$/|  $$$$$$ |  $$ / $$/| $$$$$$$$| $$  | $$   | $$   
	| $$____/  \____  $$ \  $$ $$/ | $$__  $$| $$  | $$   | $$   
	| $$       /$$  \ $$  \  $$$/  | $$  | $$| $$  | $$   | $$   
	| $$      |  $$$$$$/   \  $/   | $$  | $$|  $$$$$$/   | $$   
	|__/       \______/     \_/    |__/  |__/ \______/    |__/   
'
$WelcomeMessage = '{0}' -f $text
$colors = @(
	'green','yellow','cyan','blue','white'
)
$colorcount = $colors.count -1
[int]$color = 0..$colorcount | Get-Random
clear-host
Write-Host $WelcomeMessage -ForegroundColor  $colors[$color]