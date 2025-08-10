Friend Class EmeraldDoorLocationTypeDescriptor
    Inherits LockedDoorLocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.EmeraldDoor, True, EndingRoomFloor, EmeraldKey)
    End Sub
End Class
