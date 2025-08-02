Imports TGGD.UI

Friend Class TutorialState
    Implements IUIState

    Private ReadOnly buffer As IUIBuffer(Of Integer)
    Private ReadOnly world As Business.IWorld
    Private ReadOnly playSfx As Action(Of String)
    Private stepIndex As Integer = 0
    Private stepContent As IReadOnlyList(Of (Text As IEnumerable(Of String), Command As String)) =
        New List(Of (Text As IEnumerable(Of String), Command As String)) From
        {
            (
                {"<W>, <Z>", "<UpArrow>", "go up!"},
                UI.Command.Up
            ),
            (
                {"<S>", "<Down", "Arrow>", "go down!"},
                UI.Command.Down
            ),
            (
                {"<Q>, <A>", "<Left", "Arrow>", "go left!"},
                UI.Command.Left
            ),
            (
                {"<D>", "<Right", "Arrow>", "go right!"},
                UI.Command.Right
            ),
            (
                {"<Space>", "action!"},
                UI.Command.Green
            ),
            (
                {"<Escape>", "cancel!"},
                UI.Command.Red
            )
        }

    Public Sub New(
                  buffer As IUIBuffer(Of Integer),
                  world As Business.IWorld,
                  playSfx As Action(Of String))
        Me.buffer = buffer
        Me.world = world
        Me.playSfx = playSfx
    End Sub

    Public Sub Refresh() Implements IUIState.Refresh
        buffer.Fill(UI.Hue.Black)
        Dim font = Fonts.GetFont(UI.Font.CyFont5x7)
        Dim y = buffer.Rows \ 2 - stepContent.Count * font.Height \ 2
        For Each line In stepContent(stepIndex).Text
            font.WriteCentered(buffer, buffer.Columns \ 2, y, UI.Hue.White, line)
            y += font.Height
        Next
    End Sub

    Public Function HandleCommand(command As String) As IUIState Implements IUIState.HandleCommand
        If command = stepContent(stepIndex).Command Then
            stepIndex += 1
            If stepIndex >= stepContent.Count Then
                Return New MainMenuState(buffer, world, playSfx)
            End If
        End If
        Return Me
    End Function
End Class
