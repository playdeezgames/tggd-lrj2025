Friend Class SilverDoorLocationTypeDescriptor
    Inherits LockedDoorLocationTypeDescriptor

    Public Sub New()
        MyBase.New(
            Business.LocationType.SilverDoor,
            True,
            EndingRoomFloor,
            SilverKey)
    End Sub
End Class
