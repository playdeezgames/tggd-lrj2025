Friend MustInherit Class ItemTypeDescriptor
    ReadOnly Property ItemType As String
    ReadOnly Property ItemCount As Integer
    ReadOnly Property PickUpSfx As String
    Protected Statistics As New Dictionary(Of String, Integer)
    ReadOnly Property Name As String
    Sub New(
           itemType As String,
           name As String,
           itemCount As Integer,
           pickUpSfx As String)
        Me.ItemType = itemType
        Me.ItemCount = itemCount
        Me.PickUpSfx = pickUpSfx
        Me.Name = name
    End Sub
    MustOverride Function CanSpawn(location As ILocation) As Boolean
    Overridable Sub Initialize(item As IItem)
        For Each entry In Statistics
            item.SetStatistic(entry.Key, entry.Value)
        Next
    End Sub
    MustOverride Sub OnUse(item As IItem, character As ICharacter)
    MustOverride Sub OnTake(item As Item, character As ICharacter)
End Class
