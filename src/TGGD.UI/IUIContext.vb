Public Interface IUIContext
    Sub Refresh()
    Sub HandleCommand(command As String)
    ReadOnly Property Sfx As String
    Sub NextSfx()
End Interface
