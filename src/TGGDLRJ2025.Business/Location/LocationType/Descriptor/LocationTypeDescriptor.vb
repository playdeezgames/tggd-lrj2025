Friend MustInherit Class LocationTypeDescriptor
    ReadOnly Property LocationType As String
    Sub New(locationType As String)
        Me.LocationType = locationType
    End Sub
    Friend MustOverride Sub Initialize(location As ILocation)
End Class
