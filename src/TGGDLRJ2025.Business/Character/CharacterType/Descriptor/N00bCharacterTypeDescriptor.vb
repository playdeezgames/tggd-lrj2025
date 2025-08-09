Friend Class N00bCharacterTypeDescriptor
    Inherits CharacterTypeDescriptor

    Public Sub New()
        MyBase.New(Business.CharacterType.N00b)
    End Sub

    Friend Overrides Sub Initialize(character As ICharacter)
        character.SetStatistic(StatisticType.Health, 100)
        character.SetStatisticMinimum(StatisticType.Health, 0)
        character.SetStatisticMaximum(StatisticType.Health, 100)
        character.SetStatistic(StatisticType.Satiety, 100)
        character.SetStatisticMinimum(StatisticType.Satiety, 0)
        character.SetStatisticMaximum(StatisticType.Satiety, 100)
    End Sub

    Friend Overrides Sub OnMove(character As ICharacter)
        Dim starving = character.GetStatistic(StatisticType.Satiety) <= character.GetStatisticMinimum(StatisticType.Satiety)
        If starving Then
            character.ChangeStatistic(StatisticType.Health, -1)
        Else
            character.ChangeStatistic(StatisticType.Satiety, -1)
        End If
    End Sub

    Friend Overrides Function CanSpawn(location As ILocation) As Boolean
        Return location.LocationType = Business.LocationType.StartingRoomFloor
    End Function
End Class
