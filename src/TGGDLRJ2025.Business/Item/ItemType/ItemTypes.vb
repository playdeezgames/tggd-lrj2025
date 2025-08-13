Imports System.Runtime.CompilerServices

Public Module ItemTypes
    Private ReadOnly Descriptors As IReadOnlyDictionary(Of String, ItemTypeDescriptor) =
        New List(Of ItemTypeDescriptor) From
        {
            New KeyItemTypeDescriptor(ItemType.SilverKey),
            New KeyItemTypeDescriptor(ItemType.GoldKey),
            New KeyItemTypeDescriptor(ItemType.CarnelianKey),
            New KeyItemTypeDescriptor(ItemType.AmethystKey),
            New KeyItemTypeDescriptor(ItemType.SapphireKey),
            New KeyItemTypeDescriptor(ItemType.RubyKey),
            New KeyItemTypeDescriptor(ItemType.EmeraldKey),
            New FoodItemTypeDescriptor(),
            New SwordItemTypeDescriptor(),
            New ShieldItemTypeDescriptor(),
            New PotionItemTypeDescriptor()
        }.ToDictionary(Function(x) x.ItemType, Function(x) x)
    <Extension>
    Friend Function ToItemTypeDescriptor(itemType As String) As ItemTypeDescriptor
        Return Descriptors(itemType)
    End Function
    Friend ReadOnly Property All As IEnumerable(Of String)
        Get
            Return Descriptors.Keys
        End Get
    End Property
End Module
