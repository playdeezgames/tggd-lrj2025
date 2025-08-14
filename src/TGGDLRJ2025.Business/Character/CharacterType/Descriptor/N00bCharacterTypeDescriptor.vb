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
    End Sub

    Friend Overrides Sub Initialize(character As ICharacter)
        character.SetStatistic(StatisticType.Health, 100)
        character.SetStatisticMinimum(StatisticType.Health, 0)
        character.SetStatisticMaximum(StatisticType.Health, 100)
        character.SetStatistic(StatisticType.Satiety, 100)
        character.SetStatisticMinimum(StatisticType.Satiety, 0)
        character.SetStatisticMaximum(StatisticType.Satiety, 100)
        character.SetStatistic(StatisticType.Attack, 10)
        character.SetStatistic(StatisticType.Defend, 5)
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

    Friend Overrides Function CanSpawn(location As ILocation) As Boolean
        Return location.LocationType = Business.LocationType.StartingRoomFloor
    End Function
End Class
