Imports TGGD.UI
Imports TGGDLRJ2025.Business

Friend Class NavigationState
    Implements IUIState

    Private ReadOnly buffer As IUIBuffer(Of Integer)
    Private ReadOnly world As Business.IWorld
    Private ReadOnly playSfx As Action(Of String)

    Public Sub New(
                  buffer As IUIBuffer(Of Integer),
                  world As Business.IWorld,
                  playSfx As Action(Of String))
        Me.buffer = buffer
        Me.world = world
        Me.playSfx = playSfx
    End Sub

    Public Sub Refresh() Implements IUIState.Refresh
        buffer.Fill(Hue.Black)
        DrawMap()
        DrawStatistics()
    End Sub

    Private Sub DrawStatistics()
        Dim font = Fonts.GetFont(UI.Font.CyFont3x5)
        Dim x As Integer = 0
        Dim y As Integer = buffer.Rows - font.Height
        Dim avatar = world.Avatar
        Dim text = $"H{avatar.GetStatistic(Business.StatisticType.Health):d3} "
        font.Write(buffer, x, y, Hue.Red, text)
        x += font.GetTextWidth(text)
        text = $"S{avatar.GetStatistic(Business.StatisticType.Satiety):d3}"
        font.Write(buffer, x, y, Hue.Magenta, text)
    End Sub

    Private Sub DrawMap()
        Dim font = Fonts.GetFont(UI.Font.BlueRoom)
        Dim avatarLocation = world.Avatar.Location
        Dim map = avatarLocation.Map
        Dim avatarColumn = avatarLocation.Column
        Dim avatarRow = avatarLocation.Row
        Dim centerX = (buffer.Columns - font.Width) \ 2
        Dim centerY = (buffer.Rows - font.Height) \ 2
        Dim minimumColumn = -((buffer.Columns - font.Width) \ 2 + font.Width - 1) \ font.Width
        Dim minimumRow = -((buffer.Rows - font.Height) \ 2 + font.Height - 1) \ font.Height
        Dim renderColumns = (buffer.Columns + font.Width - 1) \ font.Width
        Dim renderRows = (buffer.Rows + font.Height - 1) \ font.Height
        For Each column In Enumerable.Range(minimumColumn, renderColumns)
            For Each row In Enumerable.Range(minimumRow, renderRows)
                Dim location = map.GetLocation(column + avatarColumn, row + avatarRow)
                If location IsNot Nothing Then
                    Dim x = column * font.Width + centerX
                    Dim y = row * font.Height + centerY
                    DrawLocation(font, location, x, y)
                End If
            Next
        Next
    End Sub

    Private Sub DrawLocation(font As IUIFont(Of Integer), location As Business.ILocation, x As Integer, y As Integer)
        Dim properties = location.LocationType.ToLocationTypeDisplayProperties
        font.Write(buffer, x, y, properties.Hue, properties.Glyph)
        DrawCharacter(font, location.Character, x, y)
    End Sub

    Private Sub DrawCharacter(font As IUIFont(Of Integer), character As Business.ICharacter, x As Integer, y As Integer)
        If character Is Nothing Then
            Return
        End If
        Dim properties = character.CharacterType.ToCharacterTypeDisplayProperties
        font.Write(buffer, x, y, properties.Hue, properties.Glyph)
    End Sub

    Public Function HandleCommand(command As String) As IUIState Implements IUIState.HandleCommand
        Select Case command
            Case UI.Command.Up
                world.Avatar.AttemptMove(DirectionType.North)
                Return Neutral.DetermineState(buffer, world, playSfx)
            Case UI.Command.Down
                world.Avatar.AttemptMove(DirectionType.South)
                Return Neutral.DetermineState(buffer, world, playSfx)
            Case UI.Command.Left
                world.Avatar.AttemptMove(DirectionType.West)
                Return Neutral.DetermineState(buffer, world, playSfx)
            Case UI.Command.Right
                world.Avatar.AttemptMove(DirectionType.East)
                Return Neutral.DetermineState(buffer, world, playSfx)
            Case UI.Command.Red
                Return New GameMenuState(buffer, world, playSfx)
            Case Else
                Return Me
        End Select
    End Function
End Class
