Imports TGGD.UI

Friend Class GameMenuState
    Inherits PickerState

    Const CONTINUE_TEXT = "Continue"
    Const ABANDON_TEXT = "Abandon"

    Public Sub New(buffer As IUIBuffer(Of Integer), world As Business.IWorld, playSfx As Action(Of String))
        MyBase.New(
            buffer,
            world,
            playSfx,
            {
                (CONTINUE_TEXT, CONTINUE_TEXT),
                (ABANDON_TEXT, ABANDON_TEXT)
            },
            UI.Font.CyFont5x7,
            Hue.Cyan)
    End Sub

    Protected Overrides Function HandleRed() As IUIState
        Return Neutral.DetermineState(buffer, world, playSfx)
    End Function

    Protected Overrides Function HandleGreen(menuItemName As String) As IUIState
        Select Case menuItemName
            Case CONTINUE_TEXT
                Return Neutral.DetermineState(buffer, world, playSfx)
            Case ABANDON_TEXT
                Return New ConfirmState(
                    buffer,
                    world,
                    playSfx,
                    "Abandon?",
                    UI.Font.CyFont5x7,
                    Hue.LightGray,
                    Hue.Red,
                    Function()
                        world.Abandon()
                        Return New MainMenuState(buffer, world, playSfx)
                    End Function,
                    Function() New GameMenuState(buffer, world, playSfx))
        End Select
        Throw New NotImplementedException()
    End Function
End Class
