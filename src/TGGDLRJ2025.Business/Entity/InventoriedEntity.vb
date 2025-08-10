Imports TGGDLRJ2025.Data

Public MustInherit Class InventoriedEntity
    Inherits Entity
    Implements IInventoriedEntity

    Protected Sub New(data As WorldData, sfxQueue As Queue(Of String))
        MyBase.New(data, sfxQueue)
    End Sub
    MustOverride ReadOnly Property InventoriedEntityData As InventoriedEntityData

    Public ReadOnly Property Items As IEnumerable(Of IItem) Implements IInventoriedEntity.Items
        Get
            Return InventoriedEntityData.ItemIds.Select(Function(x) New Item(data, sfxQueue, x))
        End Get
    End Property

    Public Sub AddItem(item As IItem) Implements IInventoriedEntity.AddItem
        InventoriedEntityData.ItemIds.Add(item.ItemId)
    End Sub

    Public Sub RemoveItem(item As IItem) Implements IInventoriedEntity.RemoveItem
        InventoriedEntityData.ItemIds.Remove(item.ItemId)
    End Sub

    Public Function GetItemTypeCount(itemType As String) As Integer Implements IInventoriedEntity.GetItemTypeCount
        Return Items.Count(Function(x) x.ItemType = itemType)
    End Function

    Public Function GetItemOfType(itemType As String) As IItem Implements IInventoriedEntity.GetItemOfType
        Return Items.FirstOrDefault(Function(x) x.ItemType = itemType)
    End Function
End Class
