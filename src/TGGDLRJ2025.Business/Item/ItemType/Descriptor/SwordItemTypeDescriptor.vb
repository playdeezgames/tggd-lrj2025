Friend Class SwordItemTypeDescriptor
    Inherits ItemTypeDescriptor

    Public Sub New()
        MyBase.New(
            Business.ItemType.Sword,
            "Sword",
            10,
            Sfx.Yoink)
        Statistics.Add(StatisticType.Attack, 20)
        Statistics.Add(StatisticType.SwordDurability, 5)
    End Sub

    Public Overrides Sub OnUse(item As IItem, character As ICharacter)
    End Sub

    Public Overrides Sub OnTake(item As Item, character As ICharacter)
        If character.GetStatistic(StatisticType.SwordDurability) <= character.GetStatisticMinimum(StatisticType.SwordDurability) Then
            character.SetStatistic(StatisticType.SwordDurability, item.GetStatistic(StatisticType.SwordDurability))
            character.RemoveItem(item)
            character.SetStatistic(StatisticType.Attack, item.GetStatistic(StatisticType.Attack))
            character.AddMessage(
                Nothing,
                {
                    (Mood.Info, "You got"),
                    (Mood.Info, "a sword!")
                })
        Else
            character.AddMessage(
                Nothing,
                {
                    (Mood.Info, "Good to"),
                    (Mood.Info, "have a"),
                    (Mood.Info, "back-up!")
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
