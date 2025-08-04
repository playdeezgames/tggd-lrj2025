Imports TGGD.UI

Friend Class ConfirmState
    Inherits PickerState
    Const NO_TEXT = "No"
    Const YES_TEXT = "Yes"
    Private ReadOnly caption As String
    Private ReadOnly captionHue As Integer
    Private ReadOnly onConfirm As Func(Of IUIState)
    Private ReadOnly onCancel As Func(Of IUIState)

    Public Sub New(
                  buffer As IUIBuffer(Of Integer),
                  world As Business.IWorld,
                  playSfx As Action(Of String),
                  caption As String,
                  fontName As String,
                  menuItemHue As Integer,
                  captionHue As Integer,
                  onConfirm As Func(Of IUIState),
                  onCancel As Func(Of IUIState))
        MyBase.New(buffer, world, playSfx, {(NO_TEXT, NO_TEXT), (YES_TEXT, YES_TEXT)}, fontName, menuItemHue)
        Me.caption = caption
        Me.captionHue = captionHue
        Me.onConfirm = onConfirm
        Me.onCancel = onCancel
    End Sub

    Public Overrides Sub Refresh()
        MyBase.Refresh()
        font.WriteCentered(buffer, buffer.Columns \ 2, 0, captionHue, caption)
    End Sub

    Protected Overrides Function HandleRed() As IUIState
        Return OnCancel()
    End Function

    Protected Overrides Function HandleGreen(menuItemName As String) As IUIState
        Select Case menuItemName
            Case YES_TEXT
                Return OnConfirm()
            Case NO_TEXT
                Return OnCancel()
            Case Else
                Throw New NotImplementedException
        End Select
    End Function
End Class
