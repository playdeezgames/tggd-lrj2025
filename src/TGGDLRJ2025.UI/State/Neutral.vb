Imports TGGD.UI
Imports TGGDLRJ2025.Business

Friend Module Neutral
    Friend Function DetermineState(
                                  buffer As IUIBuffer(Of Integer),
                                  world As IWorld,
                                  playSfx As Action(Of String)) As IUIState
        If world.HasMessages Then
            Return New MessageState(buffer, world, playSfx)
        End If
        If world.Avatar.IsDead Then
            Return New DeadState(buffer, world, playSfx)
        End If
        Return New NavigationState(buffer, world, playSfx)
    End Function
End Module
