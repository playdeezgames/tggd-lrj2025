Friend MustInherit Class CharacterTypeDescriptor
    Friend ReadOnly Property CharacterType As String
    Friend ReadOnly Property CharacterCount As Integer
    Friend ReadOnly Property Name As String
    Friend ReadOnly Property HitSfx As String
    Friend ReadOnly Property MissSfx As String
    Friend ReadOnly Property DeathSfx As String
    Sub New(
           characterType As String,
           characterCount As Integer,
           name As String,
           hitSfx As String,
           missSfx As String,
           deathSfx As String)
        Me.CharacterType = characterType
        Me.CharacterCount = characterCount
        Me.Name = name
        Me.HitSfx = hitSfx
        Me.MissSfx = missSfx
        Me.DeathSfx = deathSfx
    End Sub
    Friend MustOverride Sub Initialize(character As ICharacter)
    Friend MustOverride Function CanSpawn(location As ILocation) As Boolean
    Friend MustOverride Sub OnMove(character As ICharacter)
    Friend Sub OnInteract(agent As ICharacter, target As ICharacter, isCounter As Boolean)
        If Not target.IsDead Then
            Dim attack = agent.GetStatistic(StatisticType.Attack).Value
            Dim defend = target.GetStatistic(StatisticType.Defend).Value
            Dim lines As New List(Of (Mood As String, Text As String))
            Dim damage = attack - defend
            Dim sfx As String = Nothing
            If damage > 0 Then
                sfx = target.CharacterType.ToCharacterTypeDescriptor.HitSfx
                lines.Add((Mood.Info, $"{agent.Name}"))
                lines.Add((Mood.Info, $"hits"))
                lines.Add((Mood.Info, $"for {damage}!"))
                target.ChangeStatistic(StatisticType.Health, -damage)
                If Not target.IsDead Then
                    lines.Add((Mood.Info, $"{target.GetStatistic(Health).Value} left!"))
                End If
            Else
                sfx = agent.CharacterType.ToCharacterTypeDescriptor.MissSfx
                lines.Add((Mood.Info, $"{agent.Name} misses!"))
            End If
            agent.AddMessage(sfx, lines)
            target.AddMessage(sfx, lines)
            sfx = Nothing
            If target.IsDead Then
                sfx = target.CharacterType.ToCharacterTypeDescriptor.DeathSfx
                lines.Clear()
                lines.Add((Mood.Info, $"{agent.Name}"))
                lines.Add((Mood.Info, $"kills"))
                lines.Add((Mood.Info, $"{target.Name}!"))
                For Each item In target.Items
                    target.Location.AddItem(item)
                Next
                target.Location.Character = Nothing
                target.AddMessage(sfx, lines)
                agent.AddMessage(sfx, lines)
            ElseIf Not isCounter Then
                target.Interact(agent, True)
            End If
        End If
    End Sub
End Class
