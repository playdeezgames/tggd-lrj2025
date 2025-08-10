Friend MustInherit Class ItemTypeDescriptor
    ReadOnly Property ItemType As String
    ReadOnly Property ItemCount As Integer
    ReadOnly Property PickUpSfx As String
    Sub New(
           itemType As String,
           itemCount As Integer,
           pickUpSfx As String)
        Me.ItemType = itemType
        Me.ItemCount = itemCount
        Me.PickUpSfx = pickUpSfx
    End Sub
    MustOverride Function CanSpawn(location As ILocation) As Boolean
    MustOverride Sub Initialize(item As IItem)
    MustOverride Sub OnUse(item As IItem, character As ICharacter)
End Class
