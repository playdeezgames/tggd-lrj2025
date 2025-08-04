Imports TGGD.UI

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
        Dim map = world.GetMap(0)
        Dim font = Fonts.GetFont(UI.Font.BlueRoom)
        For Each column In Enumerable.Range(0, map.Columns)
            For Each row In Enumerable.Range(0, map.Rows)
                Dim location = map.GetLocation(column, row)
                Dim x = column * font.Width
                Dim y = row * font.Height
                DrawLocation(font, location, x, y)
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
        Return Me
    End Function
End Class
