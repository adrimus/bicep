Connect-AzAccount -Identity

$account = Get-AzAccount
$context = Get-AzContext

$account
$context

# Get the logged-in user's information
Get-MgUser -UserId 'me'

# Retrieve an automation variable
$automationVariable = Get-AutomationVariable -Name 'bcc'

$automationVariable