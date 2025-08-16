Friend Class N00bCharacterTypeDescriptor
    Inherits CharacterTypeDescriptor

    Public Sub New()
        MyBase.New(
            Business.CharacterType.N00b,
            0,
            "N00b",
            Sfx.PlayerHit,
            Sfx.PlayerMiss,
            Sfx.PlayerDeath)
        StatisticMinimums.Add(Health, 0)
        StatisticMaximums.Add(Health, 100)
        Statistics.Add(Health, 100)
        StatisticMinimums.Add(Satiety, 0)
        StatisticMaximums.Add(Satiety, 100)
        Statistics.Add(Satiety, 100)
        Statistics.Add(StatisticType.Attack, 10)
        Statistics.Add(StatisticType.Defend, 5)
        Statistics.Add(SwordDurability, 0)
        StatisticMinimums.Add(SwordDurability, 0)
        Statistics.Add(ShieldDurability, 0)
        StatisticMinimums.Add(ShieldDurability, 0)
    End Sub

    Friend Overrides Sub Initialize(character As ICharacter)
        MyBase.Initialize(character)
    End Sub

    Friend Overrides Sub OnMove(character As ICharacter)
        Dim starving = character.GetStatistic(StatisticType.Satiety) <= character.GetStatisticMinimum(StatisticType.Satiety)
        If starving Then
            If character.GetItemTypeCount(ItemType.Food) > 0 Then
                character.World.PlaySfx(Sfx.Eat)
                character.UseItem(character.GetItemOfType(ItemType.Food))
            Else
                character.ChangeStatistic(StatisticType.Health, -1)
            End If
        Else
            character.ChangeStatistic(StatisticType.Satiety, -1)
        End If
        Dim location = character.Location
        Dim items = location.Items.ToList
        For Each item In items
            character.World.PlaySfx(item.PickUpSfx)
            character.AddItem(item)
            location.RemoveItem(item)
            item.Take(character)
        Next
    End Sub

    Friend Overrides Sub OnAttemptUseItemOfType(character As ICharacter, itemType As String)
        Dim itemTypeDescriptor = itemType.ToItemTypeDescriptor
        If Not character.HasItemType(itemType) Then
            character.AddMessage(
                Nothing,
                {
                    (Mood.Info, "You have"),
                    (Mood.Info, $"no {itemTypeDescriptor.Name}")
                })
            Return
        End If
        itemTypeDescriptor.OnUse(character.GetItemOfType(itemType), character)
    End Sub

    Friend Overrides Function CanSpawn(location As ILocation) As Boolean
        Return location.LocationType = Business.LocationType.StartingRoomFloor
    End Function
End Class
