Imports TGGD.UI

Friend Class DeadState
    Implements IUIState

    Private ReadOnly buffer As IUIBuffer(Of Integer)
    Private ReadOnly world As Business.IWorld
    Private ReadOnly playSfx As Action(Of String)

    Public Sub New(buffer As IUIBuffer(Of Integer), world As Business.IWorld, playSfx As Action(Of String))
        Me.buffer = buffer
        Me.world = world
        Me.playSfx = playSfx
    End Sub

    Public Sub Refresh() Implements IUIState.Refresh
        buffer.Fill(Hue.Black)
        Dim font = Fonts.GetFont(UI.Font.CyFont5x7)
        Dim y = (buffer.Rows - font.Height) \ 2
        Dim text = $"Yer Dead!"
        font.WriteCentered(buffer, buffer.Columns \ 2, y, UI.Hue.Red, text)
    End Sub

    Public Function HandleCommand(command As String) As IUIState Implements IUIState.HandleCommand
        If command = UI.Command.Green Then
            world.Abandon()
            Return New MainMenuState(buffer, world, playSfx)
        End If
        Return Me
    End Function
End Class
