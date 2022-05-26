#Script para cambiar el backgrount remoto - creando una tarea programada para hacer el cambio directo al usuario.
#Para que el script funcione necesitas editar el nombre de la computadora y el username 
cls
Function Start-Process-Active{
    param
    (
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [string]$Executable,
        [string]$Argument,
        [string]$WorkingDirectory,
        [string]$UserID

    )

    if (($Session -eq $null) -or ($Session.Availability -ne [System.Management.Automation.Runspaces.RunspaceAvailability]::Available))
    {
        $Session.Availability
        throw [System.Exception] "Session is not availabile"
    }


    Invoke-Command -Session $Session -ArgumentList $Executable,$Argument,$WorkingDirectory,$UserID -ScriptBlock {
        param($Executable, $Argument, $WorkingDirectory, $UserID)
        $action = New-ScheduledTaskAction -Execute $Executable -Argument $Argument -WorkingDirectory $WorkingDirectory
        $principal = New-ScheduledTaskPrincipal -userid $UserID
        $task = New-ScheduledTask -Action $action -Principal $principal
        $taskname = "_StartProcessActiveTask"
        try 
        {
            $registeredTask = Get-ScheduledTask $taskname -ErrorAction SilentlyContinue
        } 
        catch 
        {
            $registeredTask = $null
        }
        if ($registeredTask)
        {
            Unregister-ScheduledTask -InputObject $registeredTask -Confirm:$false
        }
        $registeredTask = Register-ScheduledTask $taskname -InputObject $task

        Start-ScheduledTask -InputObject $registeredTask

        Unregister-ScheduledTask -InputObject $registeredTask -Confirm:$false

    }

}

#To delete previous Sessions 
Get-PSSession | Remove-PSSession

# TO EDIT: COMPUTERNAME AND USER
$Computer = "ELP-jaime-LX"
$UserComputer = "elp-jaimer"

#Line to Encript your password and create a file
#Read-Host "Enter Password" -AsSecureString |  ConvertFrom-SecureString | Out-File ".\Password.txt"

#Encrypted username and password
$UserSession = "expeditors\t2-cjs-josem"
$FilePassSession = ".\Password.txt"
$MyCredential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserSession, (Get-Content $FilePassSession | ConvertTo-SecureString)
$Session1 = New-PSSession $Computer -Credential $MyCredential

#Copy script and image to a computer
Copy-Item -ToSession $Session1 ".\image.jpg" -Destination "C:\Temp\image.jpg"
Copy-Item -ToSession $Session1 ".\Set-Wallpaper Function.ps1" -Destination "C:\Temp\ps.ps1"

#Using Function to create, execute and delete task schedule
#EDIT: Script Path
Start-Process-Active -Session $Session1 -Executable Powershell.exe -Argument '-ExecutionPolicy Bypass -WindowStyle Hidden "C:\temp\ps.ps1"' -WorkingDirectory C:\Temp\ -UserID $UserComputer

#To delete files on remote computer
#EDIT: Script and image PATH
Invoke-Command -Session $Session1 -ScriptBlock {
    Start-Sleep 2
    Remove-Item C:\temp\ps.ps1 -Force
    #Remove-Item C:\Temp\image.jpg -Force
}