Imports TGGD.UI
Imports TGGDLRJ2025.Business

Friend Module Neutral
    Friend Function DetermineState(
                                  buffer As IUIBuffer(Of Integer),
                                  world As IWorld,
                                  playSfx As Action(Of String)) As IUIState
        If world.HasMessages Then
            Return New MessageState(buffer, world, playSfx)
        Else
            Return New NavigationState(buffer, world, playSfx)
        End If
    End Function
End Module
