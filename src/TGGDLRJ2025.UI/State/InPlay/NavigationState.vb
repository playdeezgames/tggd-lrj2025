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
        DrawKeys()
    End Sub

    Private Sub DrawKeys()
        Dim font = Fonts.GetFont(UI.Font.BlueRoom)
        Dim x As Integer = buffer.Rows - font.Height * 5 \ 4
        Dim y As Integer = 0
        Dim keyItems = world.Avatar.Items.Where(Function(z) z.HasTag(TagType.Key))
        For Each keyItem In keyItems
            DrawItem(font, keyItem, x, y)
            y += font.Height \ 2
        Next
    End Sub

    Private Sub DrawStatistics()
        Dim font = Fonts.GetFont(UI.Font.CyFont3x5)
        buffer.Fill(0, 0, buffer.Columns, font.Height, Hue.DarkerGray)
        Dim y As Integer = 0
        Dim avatar = world.Avatar
        Dim x = DrawHealth(font, 0, y, avatar)
        x = DrawSatiety(font, x, y, avatar)
        Dim spriteFont = Fonts.GetFont(UI.Font.BlueRoom)
        y = buffer.Rows - spriteFont.Height
        buffer.Fill(0, y, buffer.Columns, spriteFont.Height, Hue.DarkerGray)
        x = DrawFood(spriteFont, font, 0, y, avatar)
        x = DrawPotions(spriteFont, font, x, y, avatar)
        x = DrawSwords(spriteFont, font, x, y, avatar)
        DrawShields(spriteFont, font, x, y, avatar)
    End Sub

    Private Function DrawFood(spriteFont As IUIFont(Of Integer), font As IUIFont(Of Integer), x As Integer, y As Integer, avatar As ICharacter) As Integer
        Dim displayProperties = ItemTypeDisplayProperties.ToItemTypeDisplayProperties(ItemType.Food)
        Dim count = avatar.GetItemTypeCount(ItemType.Food)
        Dim result = spriteFont.Write(buffer, x, y, displayProperties.Hue, displayProperties.Glyph)
        font.Write(buffer, x, y, Hue.White, $"{count}")
        Return result
    End Function

    Private Function DrawPotions(spriteFont As IUIFont(Of Integer), font As IUIFont(Of Integer), x As Integer, y As Integer, avatar As ICharacter) As Integer
        Dim displayProperties = ItemTypeDisplayProperties.ToItemTypeDisplayProperties(ItemType.Potion)
        Dim count = avatar.GetItemTypeCount(ItemType.Potion)
        Dim result = spriteFont.Write(buffer, x, y, displayProperties.Hue, displayProperties.Glyph)
        font.Write(buffer, x, y, Hue.White, $"{count}")
        Return result
    End Function

    Private Function DrawSwords(spriteFont As IUIFont(Of Integer), font As IUIFont(Of Integer), x As Integer, y As Integer, avatar As ICharacter) As Integer
        Dim displayProperties = ItemTypeDisplayProperties.ToItemTypeDisplayProperties(ItemType.Sword)
        Dim count = avatar.GetItemTypeCount(ItemType.Sword) + If(avatar.GetStatistic(StatisticType.SwordDurability).Value > 0, 1, 0)
        Dim result = spriteFont.Write(buffer, x, y, displayProperties.Hue, displayProperties.Glyph)
        font.Write(buffer, x, y, Hue.White, $"{count}")
        Return result
    End Function

    Private Function DrawShields(spriteFont As IUIFont(Of Integer), font As IUIFont(Of Integer), x As Integer, y As Integer, avatar As ICharacter) As Integer
        Dim displayProperties = ItemTypeDisplayProperties.ToItemTypeDisplayProperties(ItemType.Shield)
        Dim count = avatar.GetItemTypeCount(ItemType.Shield) + If(avatar.GetStatistic(StatisticType.ShieldDurability).Value > 0, 1, 0)
        Dim result = spriteFont.Write(buffer, x, y, displayProperties.Hue, displayProperties.Glyph)
        font.Write(buffer, x, y, Hue.White, $"{count}")
        Return result
    End Function

    Private Function DrawSatiety(font As IUIFont(Of Integer), x As Integer, y As Integer, avatar As ICharacter) As Integer
        Dim Text = $"S{avatar.GetStatistic(Business.StatisticType.Satiety):d3} "
        Return font.Write(buffer, x, y, Hue.Magenta, Text)
    End Function

    Private Function DrawHealth(font As IUIFont(Of Integer), x As Integer, y As Integer, avatar As ICharacter) As Integer
        Dim Text = $"H{avatar.GetStatistic(Business.StatisticType.Health):d3} "
        Return font.Write(buffer, x, y, Hue.Red, Text)
    End Function

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
        DrawItems(font, location.Items, x, y)
        DrawThreat(font, location, x, y)
        DrawCharacter(font, location.Character, x, y)
    End Sub

    Private Sub DrawThreat(font As IUIFont(Of Integer), location As ILocation, x As Integer, y As Integer)
        If Not location.IsSolid AndAlso location.Threatens(world.Avatar) Then
            font.Write(buffer, x, y, Hue.DarkRed, Chr(12))
        End If
    End Sub

    Private Sub DrawItems(font As IUIFont(Of Integer), items As IEnumerable(Of IItem), x As Integer, y As Integer)
        For Each item In items
            DrawItem(font, item, x, y)
        Next
    End Sub

    Private Sub DrawItem(font As IUIFont(Of Integer), item As IItem, x As Integer, y As Integer)
        Dim properties = item.ItemType.ToItemTypeDisplayProperties
        font.Write(buffer, x, y, properties.Hue, properties.Glyph)
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
            Case UI.Command.Green
                world.Avatar.AttemptUseItemOfType(ItemType.Potion)
                Return Neutral.DetermineState(buffer, world, playSfx)
            Case Else
                Return Me
        End Select
    End Function
End Class
