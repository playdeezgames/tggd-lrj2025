Friend Class MoonPersonCharacterTypeDescriptor
    Inherits CharacterTypeDescriptor

    Public Sub New()
        MyBase.New(
            Business.CharacterType.MoonPerson,
            40,
            "Moonie",
            Sfx.EnemyHit,
            Sfx.EnemyMiss,
            Sfx.EnemyDeath)
        StatisticMinimums.Add(Health, 0)
        StatisticMaximums.Add(Health, 25)
        Statistics.Add(Health, 25)
        Statistics.Add(StatisticType.Attack, 20)
        Statistics.Add(StatisticType.Defend, 0)
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
