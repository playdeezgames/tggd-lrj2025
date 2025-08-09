Friend Class AmethystDoorLocationTypeDescriptor
    Inherits LocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.AmethystDoor, True)
    End Sub

    Friend Overrides Sub Initialize(location As ILocation)
    End Sub

    Friend Overrides Sub Bump(location As ILocation, character As ICharacter)
        location.LocationType = Business.LocationType.EndingRoomFloor
    End Sub

    Friend Overrides Function CanEnter(location As ILocation, character As ICharacter) As Boolean
        Return False
    End Function
End Class
