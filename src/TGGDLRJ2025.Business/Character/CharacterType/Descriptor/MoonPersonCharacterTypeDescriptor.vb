Friend Class MoonPersonCharacterTypeDescriptor
    Inherits CharacterTypeDescriptor

    Public Sub New()
        MyBase.New(
            Business.CharacterType.MoonPerson,
            40,
            "Moonie",
            20,
            0,
            Sfx.EnemyHit,
            Sfx.EnemyMiss,
            Sfx.EnemyDeath)
    End Sub

    Friend Overrides Sub Initialize(character As ICharacter)
        character.SetStatistic(StatisticType.Health, 25)
        character.SetStatisticMinimum(StatisticType.Health, 0)
        character.SetStatisticMaximum(StatisticType.Health, 25)
        character.SetStatistic(StatisticType.Attack, character.CharacterType.ToCharacterTypeDescriptor.Attack)
        character.SetStatistic(StatisticType.Defend, character.CharacterType.ToCharacterTypeDescriptor.Defend)
    End Sub

    Friend Overrides Sub OnMove(character As ICharacter)
    End Sub

    Friend Overrides Sub OnHitEnemy(character As ICharacter, enemy As ICharacter)
    End Sub

    Friend Overrides Sub OnAttemptUseItemOfType(character As ICharacter, itemType As String)
    End Sub

    Friend Overrides Function CanSpawn(location As ILocation) As Boolean
        If location.HasCharacter Then
            Return False
        End If
        If location.IsSolid Then
            Return False
        End If
        If location.Column = 1 AndAlso location.Row = location.Map.Rows \ 2 Then
            Return False
        End If
        If location.Column = location.Map.Columns - 2 AndAlso location.Row = location.Map.Rows \ 2 Then
            Return False
        End If
        If location.Column = location.Map.Columns \ 2 AndAlso location.Row = 1 Then
            Return False
        End If
        If location.Column = location.Map.Columns \ 2 AndAlso location.Row = location.Map.Rows - 2 Then
            Return False
        End If
        Return True
    End Function
End Class
