Friend Class StartingFloorLocationTypeDescriptor
    Inherits LocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.StartingRoomFloor)
    End Sub

    Friend Overrides Sub Initialize(location As ILocation)
    End Sub

    Friend Overrides Function CanEnter(location As ILocation, character As ICharacter) As Boolean
        Return True
    End Function
End Class
