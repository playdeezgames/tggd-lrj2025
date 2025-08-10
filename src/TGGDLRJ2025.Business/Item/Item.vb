Imports TGGDLRJ2025.Data

Public Class Item
    Inherits Entity
    Implements IItem

    Public Sub New(data As WorldData, sfxQueue As Queue(Of String), itemId As Integer)
        MyBase.New(data, sfxQueue)
        Me.ItemId = itemId
    End Sub
    Private ReadOnly Property ItemData As ItemData
        Get
            Return data.Items(ItemId)
        End Get
    End Property


    Public ReadOnly Property ItemId As Integer Implements IItem.ItemId

    Public ReadOnly Property ItemType As String Implements IItem.ItemType
        Get
            Return ItemData.ItemType
        End Get
    End Property

    Protected Overrides ReadOnly Property EntityData As EntityData
        Get
            Return ItemData
        End Get
    End Property

    Public ReadOnly Property PickUpSfx As String Implements IItem.PickUpSfx
        Get
            Return ItemType.ToItemTypeDescriptor.PickUpSfx
        End Get
    End Property
End Class
