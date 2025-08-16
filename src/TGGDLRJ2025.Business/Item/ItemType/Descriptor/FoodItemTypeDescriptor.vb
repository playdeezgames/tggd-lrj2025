Friend Class FoodItemTypeDescriptor
    Inherits ItemTypeDescriptor

    Const FOOD_SATIETY_BENEFIT = 25

    Public Sub New()
        MyBase.New(Business.ItemType.Food, "Blueberry", 50, Sfx.Take)
    End Sub

    Public Overrides Sub Initialize(item As IItem)
    End Sub

    Public Overrides Sub OnUse(item As IItem, character As ICharacter)
        character.ChangeStatistic(StatisticType.Satiety, FOOD_SATIETY_BENEFIT)
        character.RemoveItem(item)
        If Not character.HasTag(TagType.EatMessage) Then
            character.SetTag(TagType.EatMessage)
            character.AddMessage(
                Nothing,
                {
                    (Mood.Info, "Hungry?"),
                    (Mood.Info, "Blueberries"),
                    (Mood.Info, "satisfy!")
                })
        End If
    End Sub

    Public Overrides Sub OnTake(item As Item, character As ICharacter)
        If Not character.HasTag(TagType.FoodMessage) Then
            character.SetTag(TagType.FoodMessage)
            character.AddMessage(
                Nothing,
                {
                    (Mood.Info, "Blueberry"),
                    (Mood.Info, "(fer when"),
                    (Mood.Info, "yer"),
                    (Mood.Info, "hungry!)")
                })
        End If
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
