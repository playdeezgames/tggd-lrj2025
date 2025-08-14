Friend MustInherit Class ItemTypeDescriptor
    ReadOnly Property ItemType As String
    ReadOnly Property ItemCount As Integer
    ReadOnly Property PickUpSfx As String
    ReadOnly Property Attack As Integer
    ReadOnly Property Defend As Integer
    ReadOnly Property Durability As Integer
    ReadOnly Property Name As String
    Sub New(
           itemType As String,
           name As String,
           itemCount As Integer,
           attack As Integer,
           defend As Integer,
           durability As Integer,
           pickUpSfx As String)
        Me.ItemType = itemType
        Me.ItemCount = itemCount
        Me.PickUpSfx = pickUpSfx
        Me.Attack = attack
        Me.Defend = defend
        Me.Durability = durability
        Me.Name = name
    End Sub
    MustOverride Function CanSpawn(location As ILocation) As Boolean
    MustOverride Sub Initialize(item As IItem)
    MustOverride Sub OnUse(item As IItem, character As ICharacter)
    MustOverride Sub OnTake(item As Item, character As ICharacter)
End Class
