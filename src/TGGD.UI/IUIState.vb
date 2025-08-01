Public Interface IUIState
    Sub Refresh()
    Function HandleCommand(command As String) As IUIState
End Interface
