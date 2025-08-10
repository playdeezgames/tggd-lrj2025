Friend Class FoodItemTypeDescriptor
    Inherits ItemTypeDescriptor

    Const FOOD_SATIETY_BENEFIT = 25

    Public Sub New()
        MyBase.New(Business.ItemType.Food, 100)
    End Sub

    Public Overrides Sub Initialize(item As IItem)
    End Sub

    Public Overrides Sub OnUse(item As IItem, character As ICharacter)
        character.ChangeStatistic(StatisticType.Satiety, FOOD_SATIETY_BENEFIT)
        character.RemoveItem(item)
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
