Friend Class SapphireDoorLocationTypeDescriptor
    Inherits LockedDoorLocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.SapphireDoor, True, EndingRoomFloor, SapphireKey)
    End Sub
End Class
