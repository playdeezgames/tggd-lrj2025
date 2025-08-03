Friend Class BlueWallLocationTypeDescriptor
    Inherits LocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.BlueWall)
    End Sub

    Friend Overrides Sub Initialize(location As ILocation)
    End Sub
End Class
