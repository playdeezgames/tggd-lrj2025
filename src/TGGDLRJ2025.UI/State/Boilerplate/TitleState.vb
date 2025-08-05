Imports TGGD.Business
Imports TGGD.UI

Friend Class TitleState
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
        buffer.Fill(Black)
        Dim font = Fonts.GetFont(UI.Font.CyFont8x8)
        font.WriteCentered(buffer, buffer.Columns \ 2 + 1, 1, Hue.Blue, "The")
        font.WriteCentered(buffer, buffer.Columns \ 2 + 1, 9, Hue.Blue, "Blue")
        font.WriteCentered(buffer, buffer.Columns \ 2 + 1, 17, Hue.Blue, "Room")
        font.WriteCentered(buffer, buffer.Columns \ 2 + 1, 25, Hue.Blue, "of")
        font.WriteCentered(buffer, buffer.Columns \ 2 + 1, 33, Hue.Blue, "SPLORR!!")

        font.WriteCentered(buffer, buffer.Columns \ 2, 0, Hue.LightBlue, "The")
        font.WriteCentered(buffer, buffer.Columns \ 2, 8, Hue.LightBlue, "Blue")
        font.WriteCentered(buffer, buffer.Columns \ 2, 16, Hue.LightBlue, "Room")
        font.WriteCentered(buffer, buffer.Columns \ 2, 24, Hue.LightBlue, "of")
        font.WriteCentered(buffer, buffer.Columns \ 2, 32, Hue.LightBlue, "SPLORR!!")

        font = Fonts.GetFont(UI.Font.CyFont3x5)
        Dim y = buffer.Rows - font.Height * 3
        font.WriteCentered(buffer, buffer.Columns \ 2, y, Hue.DarkGray, "lowrezjam-2025")
        y += font.Height
        font.WriteCentered(buffer, buffer.Columns \ 2, y, Hue.DarkGray, "TheGrumpyGameDev")
        y += font.Height
        buffer.Fill(0, y, buffer.Columns, font.Height, Hue.LightGray)
        font.WriteCentered(buffer, buffer.Columns \ 2, y, Hue.Black, "<space>")

        font = Fonts.GetFont(UI.Font.BlueRoom)
        font.Write(buffer, 0, 0, Hue.Brown, Chr(1))
    End Sub

    Public Function HandleCommand(command As String) As IUIState Implements IUIState.HandleCommand
        Select Case command
            Case UI.Command.Green
                Return New MainMenuState(buffer, world, playSfx)
            Case Else
                Return Me
        End Select
    End Function
End Class
