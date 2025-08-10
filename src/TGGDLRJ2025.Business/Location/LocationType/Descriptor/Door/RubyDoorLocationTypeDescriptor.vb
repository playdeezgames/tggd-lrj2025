Friend Class RubyDoorLocationTypeDescriptor
    Inherits LockedDoorLocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.RubyDoor, True, EndingRoomFloor, RubyKey)
    End Sub
End Class
