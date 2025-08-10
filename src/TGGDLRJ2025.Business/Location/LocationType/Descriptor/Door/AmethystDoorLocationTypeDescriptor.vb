Friend Class AmethystDoorLocationTypeDescriptor
    Inherits LockedDoorLocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.AmethystDoor, True, EndingRoomFloor, AmethystKey)
    End Sub
End Class
