Friend Class ShieldItemTypeDescriptor
    Inherits ItemTypeDescriptor

    Public Sub New()
        MyBase.New(Business.ItemType.Shield, "Shield", 0, 0, 10, 5, Sfx.Yoink)
    End Sub

    Public Overrides Sub Initialize(item As IItem)
    End Sub

    Public Overrides Sub OnUse(item As IItem, character As ICharacter)
    End Sub

    Public Overrides Sub OnTake(item As Item, character As ICharacter)
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
