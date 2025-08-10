Friend Class CarneliianDoorLocationTypeDescriptor
    Inherits LockedDoorLocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.CarnelianDoor, True, EndingRoomFloor, CarnelianKey)
    End Sub
End Class
