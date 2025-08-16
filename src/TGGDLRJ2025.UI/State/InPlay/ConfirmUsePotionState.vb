Imports TGGD.UI

Friend Class ConfirmUsePotionState
    Inherits ConfirmState

    Public Sub New(buffer As IUIBuffer(Of Integer), world As Business.IWorld, playSfx As Action(Of String))
        MyBase.New(
            buffer,
            world,
            playSfx,
            "Use Potion?",
            UI.Font.CyFont3x5,
            Hue.LightGray,
            Hue.Yellow,
            Function()
                world.Avatar.AttemptUseItemOfType(Business.ItemType.Potion)
                Return Neutral.DetermineState(buffer, world, playSfx)
            End Function,
            Function()
                Return Neutral.DetermineState(buffer, world, playSfx)
            End Function)
    End Sub
End Class
