Friend Class KeyItemTypeDescriptor
    Inherits ItemTypeDescriptor

    Public Sub New(itemType As String)
        MyBase.New(itemType, 1, 0, 0, 0, Sfx.Yoink)
    End Sub

    Public Overrides Sub Initialize(item As IItem)
        item.SetTag(TagType.Key)
    End Sub

    Public Overrides Sub OnUse(item As IItem, character As ICharacter)
        character.RemoveItem(item)
    End Sub

    Public Overrides Sub OnTake(item As Item, character As ICharacter)
        If Not character.HasTag(TagType.KeyMessage) Then
            character.SetTag(TagType.KeyMessage)
            character.AddMessage(Nothing,
                {
                    (Mood.Info, "Save keys"),
                    (Mood.Info, "to open"),
                    (Mood.Info, "doors")
                })
        End If
    End Sub

    Public Overrides Function CanSpawn(Location As ILocation) As Boolean
        Dim locationDescriptor = Location.LocationType.ToLocationTypeDescriptor
        If locationDescriptor.IsSolid Then
            Return False
        End If
        If Location.HasCharacter Then
            Return False
        End If
        Return Location.LocationType = LocationType.RoomFloor
    End Function
End Class
