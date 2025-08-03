Imports TGGD.UI
Imports TGGDLRJ2025.Business

Friend Module Neutral
    Friend Function DetermineState(
                                  buffer As IUIBuffer(Of Integer),
                                  world As IWorld,
                                  playSfx As Action(Of String)) As IUIState
        Return New NavigationState(buffer, world, playSfx)
    End Function
End Module
