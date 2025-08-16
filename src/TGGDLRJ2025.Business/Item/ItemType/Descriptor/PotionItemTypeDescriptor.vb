Friend Class PotionItemTypeDescriptor
    Inherits ItemTypeDescriptor

    Public Sub New()
        MyBase.New(Business.ItemType.Potion, "Potion", 25, Sfx.Yoink)
        Statistics.Add(Health, 50)
    End Sub

    Public Overrides Sub OnUse(item As IItem, character As ICharacter)
        character.ChangeStatistic(StatisticType.Health, item.GetStatistic(StatisticType.Health).Value)
        character.AddMessage(
            Nothing,
            {
                (Mood.Info, $"+{item.GetStatistic(StatisticType.Health).Value} health"),
                (Mood.Info, $"you have"),
                (Mood.Info, $"{character.GetStatistic(StatisticType.Health).Value}/{character.GetStatisticMaximum(StatisticType.Health)}")
            })
        character.RemoveItem(item)
    End Sub

    Public Overrides Sub OnTake(item As Item, character As ICharacter)
        If Not character.HasTag(TagType.PotionMessage) Then
            character.SetTag(TagType.PotionMessage)
            character.AddMessage(Nothing,
                {
                    (Mood.Info, "<space>"),
                    (Mood.Info, "to drink"),
                    (Mood.Info, "potion.")
                })
        End If
    End Sub

    Public Overrides Function CanSpawn(location As ILocation) As Boolean
        Dim locationDescriptor = location.LocationType.ToLocationTypeDescriptor
        If locationDescriptor.IsSolid Then
            Return False
        End If
        If location.HasCharacter AndAlso location.Character.IsAvatar Then
            Return False
        End If
        Return True
    End Function
End Class
