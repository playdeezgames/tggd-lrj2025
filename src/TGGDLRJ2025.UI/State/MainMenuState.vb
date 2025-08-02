Imports TGGD.UI

Friend Class MainMenuState
    Inherits PickerState

    Friend Const TUTORIAL_NAME = "Tutorial"
    Const TUTORIAL_TEXT = "Tutorial"
    Friend Const EMBARK_NAME = "Embark"
    Const EMBARK_TEXT = "Embark!"

    Public Sub New(
                  buffer As IUIBuffer(Of Integer),
                  world As Business.IWorld,
                  playSfx As Action(Of String))
        MyBase.New(
            buffer,
            world,
            playSfx,
            {
                (TUTORIAL_NAME, TUTORIAL_TEXT),
                (EMBARK_NAME, EMBARK_TEXT)
            },
            Font.CyFont5x7,
            Hue.LightCyan)
    End Sub

    Protected Overrides Function HandleRed() As IUIState
        Return Me
    End Function

    Protected Overrides Function HandleGreen(menuItemName As String) As IUIState
        Select Case menuItemName
            Case TUTORIAL_NAME
                Return New TutorialState(buffer, world, playSfx)
            Case Else
                Return Me
        End Select
    End Function
End Class
