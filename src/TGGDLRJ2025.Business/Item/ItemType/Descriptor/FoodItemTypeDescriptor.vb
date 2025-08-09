Friend Class FoodItemTypeDescriptor
    Inherits ItemTypeDescriptor

    Public Sub New()
        MyBase.New(Business.ItemType.Food, 100)
    End Sub

    Public Overrides Sub Initialize(item As IItem)
    End Sub

    Public Overrides Function CanSpawn(location As ILocation) As Boolean
        Dim locationDescriptor = location.LocationType.ToLocationTypeDescriptor
        If locationDescriptor.IsSolid Then
            Return False
        End If
        If location.HasCharacter Then
            Return False
        End If
        Return True
    End Function
End Class
