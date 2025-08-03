Friend Class FloorLocationTypeDescriptor
    Inherits LocationTypeDescriptor

    Public Sub New()
        MyBase.New(Business.LocationType.Floor)
    End Sub

    Friend Overrides Sub Initialize(location As ILocation)
    End Sub
End Class
