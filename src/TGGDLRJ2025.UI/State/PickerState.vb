Imports TGGD.UI

Friend MustInherit Class PickerState
    Implements IUIState

    Protected ReadOnly buffer As IUIBuffer(Of Integer)
    Protected ReadOnly world As Business.IWorld
    Protected ReadOnly playSfx As Action(Of String)
    Private ReadOnly menuItems As IEnumerable(Of (Name As String, Caption As String))
    Private menuItemIndex As Integer = 0
    Private ReadOnly font As IUIFont(Of Integer)
    Private ReadOnly hue As Integer

    Public Sub New(
                  buffer As IUIBuffer(Of Integer),
                  world As Business.IWorld,
                  playSfx As Action(Of String),
                  menuItems As IEnumerable(Of (Name As String, Caption As String)),
                  fontName As String,
                  hue As Integer)
        Me.buffer = buffer
        Me.world = world
        Me.playSfx = playSfx
        Me.menuItems = menuItems
        Me.font = Fonts.GetFont(fontName)
        Me.hue = hue
    End Sub

    Public Sub Refresh() Implements IUIState.Refresh
        buffer.Fill(UI.Hue.Black)
        Dim y = buffer.Rows \ 2 - font.Height \ 2 - font.Height * menuItemIndex
        Dim index As Integer = 0
        For Each menuItem In menuItems
            If menuItemIndex = index Then
                buffer.Fill(0, y, buffer.Columns, font.Height, hue)
                font.WriteCentered(buffer, buffer.Columns \ 2, y, UI.Hue.Black, menuItem.Caption)
            Else
                font.WriteCentered(buffer, buffer.Columns \ 2, y, hue, menuItem.Caption)
            End If
            index += 1
            y += font.Height
        Next
    End Sub

    Public Function HandleCommand(command As String) As IUIState Implements IUIState.HandleCommand
        Select Case command
            Case UI.Command.Up
                menuItemIndex = (menuItemIndex + menuItems.Count - 1) Mod menuItems.Count
            Case UI.Command.Down
                menuItemIndex = (menuItemIndex + 1) Mod menuItems.Count
            Case UI.Command.Green
                Return HandleGreen(menuItems.ToArray()(menuItemIndex).Name)
            Case UI.Command.Red
                Return HandleRed()
        End Select
        Return Me
    End Function

    Protected MustOverride Function HandleRed() As IUIState

    Protected MustOverride Function HandleGreen(menuItemName As String) As IUIState
End Class
