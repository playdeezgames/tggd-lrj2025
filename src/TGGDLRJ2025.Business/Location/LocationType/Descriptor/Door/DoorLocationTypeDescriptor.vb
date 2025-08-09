Friend Class DoorLocationTypeDescriptor
    Inherits LocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.Door, True)
    End Sub

    Friend Overrides Sub Initialize(location As ILocation)
    End Sub

    Friend Overrides Sub Bump(location As ILocation, character As ICharacter)
        Dim nextLocationId = location.GetStatistic(StatisticType.DestinationLocationId).Value
        Dim nextLocation = location.World.GetLocation(nextLocationId)
        nextLocation.Character = character
    End Sub

    Friend Overrides Function CanEnter(location As ILocation, character As ICharacter) As Boolean
        Return False
    End Function
End Class
