set shell = CreateObject("WScript.Shell")
command = "powershell.exe -executionpolicy bypass -nologo -File .\AHNotifier.ps1"
shell.Run command,0