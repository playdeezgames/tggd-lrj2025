Friend Class ShieldItemTypeDescriptor
    Inherits ItemTypeDescriptor

    Public Sub New()
        MyBase.New(Business.ItemType.Shield, "Shield", 10, Sfx.Yoink)
        Statistics.Add(StatisticType.Defend, 10)
        Statistics.Add(StatisticType.ShieldDurability, 5)
    End Sub

    Public Overrides Sub OnUse(item As IItem, character As ICharacter)
    End Sub

    Public Overrides Sub OnTake(item As Item, character As ICharacter)
        If character.GetStatistic(StatisticType.ShieldDurability) <= character.GetStatisticMinimum(StatisticType.ShieldDurability) Then
            character.SetStatistic(StatisticType.ShieldDurability, item.GetStatistic(StatisticType.ShieldDurability))
            character.RemoveItem(item)
            character.SetStatistic(StatisticType.Defend, item.GetStatistic(StatisticType.Defend))
            character.AddMessage(
                Nothing,
                {
                    (Mood.Info, "You got"),
                    (Mood.Info, "a shield!")
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
        If location.HasCharacter Then
            Return False
        End If
        Return True
    End Function
End Class
