Imports TGGD.UI

Friend Class GameMenuState
    Inherits PickerState

    Const CONTINUE_NAME = "Continue"
    Const CONTINUE_TEXT = "Continue"
    Const ABANDON_NAME = "Abandon"
    Const ABANDON_TEXT = "Abandon"

    Public Sub New(buffer As IUIBuffer(Of Integer), world As Business.IWorld, playSfx As Action(Of String))
        MyBase.New(
            buffer,
            world,
            playSfx,
            {
                (CONTINUE_NAME, CONTINUE_TEXT),
                (ABANDON_NAME, ABANDON_TEXT)
            },
            Font.CyFont4x6,
            Hue.Cyan)
    End Sub

    Protected Overrides Function HandleRed() As IUIState
        Return Neutral.DetermineState(buffer, world, playSfx)
    End Function

    Protected Overrides Function HandleGreen(menuItemName As String) As IUIState
        Select Case menuItemName
            Case CONTINUE_NAME
                Return Neutral.DetermineState(buffer, world, playSfx)
            Case ABANDON_NAME
                Return New MainMenuState(buffer, world, playSfx)
        End Select
        Throw New NotImplementedException()
    End Function
End Class
