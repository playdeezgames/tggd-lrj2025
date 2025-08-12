Friend Class MoonPersonCharacterTypeDescriptor
    Inherits CharacterTypeDescriptor

    Public Sub New()
        MyBase.New(Business.CharacterType.MoonPerson, 20, "Moonie")
    End Sub

    Friend Overrides Sub Initialize(character As ICharacter)
        character.SetStatistic(StatisticType.Health, 25)
        character.SetStatisticMinimum(StatisticType.Health, 0)
        character.SetStatisticMaximum(StatisticType.Health, 25)
        character.SetStatistic(StatisticType.Attack, 20)
        character.SetStatistic(StatisticType.Defend, 0)
    End Sub

    Friend Overrides Sub OnMove(character As ICharacter)
    End Sub

    Friend Overrides Function CanSpawn(location As ILocation) As Boolean
        Return Not location.HasCharacter AndAlso Not location.LocationType.ToLocationTypeDescriptor.IsSolid
    End Function
End Class
