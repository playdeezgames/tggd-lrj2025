Friend Class KeyItemTypeDescriptor
    Inherits ItemTypeDescriptor

    Public Sub New(itemType As String)
        MyBase.New(itemType, 1)
    End Sub

    Public Overrides Sub Initialize(item As IItem)
    End Sub

    Public Overrides Function CanSpawn(Location As ILocation) As Boolean
        Dim locationDescriptor = Location.LocationType.ToLocationTypeDescriptor
        If locationDescriptor.IsSolid Then
            Return False
        End If
        If Location.HasCharacter Then
            Return False
        End If
        Return True
    End Function
End Class
