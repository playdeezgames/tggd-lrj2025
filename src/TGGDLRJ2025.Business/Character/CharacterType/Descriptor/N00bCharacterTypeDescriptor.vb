Friend Class N00bCharacterTypeDescriptor
    Inherits CharacterTypeDescriptor

    Public Sub New()
        MyBase.New(Business.CharacterType.N00b)
    End Sub

    Friend Overrides Sub Initialize(character As ICharacter)
    End Sub

    Friend Overrides Function CanSpawn(location As ILocation) As Boolean
        Return location.LocationType = Business.LocationType.StartingRoomFloor
    End Function
End Class
