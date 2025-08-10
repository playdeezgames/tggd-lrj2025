Friend Class GoldDoorLocationTypeDescriptor
    Inherits LockedDoorLocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.GoldDoor, True, EndingRoomFloor, GoldKey)
    End Sub
End Class
