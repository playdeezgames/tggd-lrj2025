Friend Class FinalSignLocationTypeDescriptor
    Inherits LocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.FinalSign, True)
    End Sub

    Friend Overrides Sub Initialize(location As ILocation)
    End Sub

    Friend Overrides Sub Bump(location As ILocation, character As ICharacter)
        character.AddMessage({(Mood.Info, $"Have you"), (Mood.Info, $"checked"), (Mood.Info, $"yer"), (Mood.Info, $"butthole?")})
        'TODO: you have won the game
    End Sub

    Friend Overrides Function CanEnter(location As ILocation, character As ICharacter) As Boolean
        Return False
    End Function
End Class
