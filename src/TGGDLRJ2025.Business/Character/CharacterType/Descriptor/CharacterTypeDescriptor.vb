Friend MustInherit Class CharacterTypeDescriptor
    Friend ReadOnly Property CharacterType As String
    Friend ReadOnly Property CharacterCount As Integer
    Friend ReadOnly Property Name As String
    Friend ReadOnly Property HitSfx As String
    Friend ReadOnly Property MissSfx As String
    Friend ReadOnly Property DeathSfx As String
    Protected Statistics As New Dictionary(Of String, Integer)
    Protected StatisticMaximums As New Dictionary(Of String, Integer)
    Protected StatisticMinimums As New Dictionary(Of String, Integer)
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

    Friend Overridable Sub Initialize(character As ICharacter)
        For Each entry In StatisticMaximums
            character.SetStatisticMaximum(entry.Key, entry.Value)
        Next
        For Each entry In StatisticMinimums
            character.SetStatisticMinimum(entry.Key, entry.Value)
        Next
        For Each entry In Statistics
            character.SetStatistic(entry.Key, entry.Value)
        Next
    End Sub
    Friend Function GetStatistic(statisticType As String) As Integer?
        Dim result As Integer
        If Statistics.TryGetValue(statisticType, result) Then
            Return result
        End If
        Return Nothing
    End Function
    Friend MustOverride Function CanSpawn(location As ILocation) As Boolean
    Friend MustOverride Sub OnMove(character As ICharacter)
    Private Shared Sub OnHitEnemy(character As ICharacter)
        If character.GetStatistic(StatisticType.SwordDurability).Value > character.GetStatisticMinimum(StatisticType.SwordDurability) Then
            character.ChangeStatistic(StatisticType.SwordDurability, -1)
            If character.GetStatistic(StatisticType.SwordDurability).Value <= character.GetStatisticMinimum(StatisticType.SwordDurability) Then
                Dim lines As New List(Of (Mood As String, Text As String))
                Dim swordsLeft = character.GetItemTypeCount(ItemType.Sword)
                If swordsLeft > 0 Then
                    lines.Add((Mood.Info, "Yer sword"))
                    lines.Add((Mood.Info, "broke!"))
                    lines.Add((Mood.Info, "Equipping"))
                    lines.Add((Mood.Info, "next one!"))
                    lines.Add((Mood.Info, $"({swordsLeft - 1} left)"))
                    Dim item = character.GetItemOfType(ItemType.Sword)
                    character.RemoveItem(item)
                Else
                    lines.Add((Mood.Info, "Yer last"))
                    lines.Add((Mood.Info, "sword"))
                    lines.Add((Mood.Info, "broke!"))
                    character.SetStatistic(StatisticType.Attack, character.CharacterType.ToCharacterTypeDescriptor.GetStatistic(StatisticType.Attack).Value)
                End If
                character.AddMessage(Nothing, lines)
            End If
        End If
    End Sub
    Friend MustOverride Sub OnAttemptUseItemOfType(character As ICharacter, itemType As String)
    Friend Sub OnInteract(agent As ICharacter, target As ICharacter, isCounter As Boolean)
        If Not target.IsDead Then
            Dim attack = agent.GetStatistic(StatisticType.Attack).Value
            Dim defend = target.GetStatistic(StatisticType.Defend).Value
            Dim lines As New List(Of (Mood As String, Text As String))
            Dim damage = attack - defend
            Dim sfx As String
            Dim hit As Boolean = False
            If damage > 0 Then
                sfx = target.CharacterType.ToCharacterTypeDescriptor.HitSfx
                lines.Add((Mood.Info, $"{agent.Name}"))
                lines.Add((Mood.Info, $"hits"))
                lines.Add((Mood.Info, $"for {damage}!"))
                target.ChangeStatistic(StatisticType.Health, -damage)
                If Not target.IsDead Then
                    lines.Add((Mood.Info, $"{target.GetStatistic(Health).Value} left!"))
                End If
                hit = True
            Else
                sfx = agent.CharacterType.ToCharacterTypeDescriptor.MissSfx
                lines.Add((Mood.Info, $"{agent.Name} misses!"))
            End If
            agent.AddMessage(sfx, lines)
            target.AddMessage(sfx, lines)
            If hit Then
                OnHitEnemy(agent)
                OnHitByEnemy(target)
            End If
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

    Private Shared Sub OnHitByEnemy(character As ICharacter)
        If character.GetStatistic(StatisticType.ShieldDurability).Value > character.GetStatisticMinimum(StatisticType.ShieldDurability) Then
            character.ChangeStatistic(StatisticType.ShieldDurability, -1)
            If character.GetStatistic(StatisticType.ShieldDurability).Value <= character.GetStatisticMinimum(StatisticType.ShieldDurability) Then
                Dim lines As New List(Of (Mood As String, Text As String))
                Dim shieldsLeft = character.GetItemTypeCount(ItemType.Shield)
                If shieldsLeft > 0 Then
                    lines.Add((Mood.Info, "Yer shield"))
                    lines.Add((Mood.Info, "broke!"))
                    lines.Add((Mood.Info, "Equipping"))
                    lines.Add((Mood.Info, "next one!"))
                    lines.Add((Mood.Info, $"({shieldsLeft - 1} left)"))
                    Dim item = character.GetItemOfType(ItemType.Shield)
                    character.RemoveItem(item)
                Else
                    lines.Add((Mood.Info, "Yer last"))
                    lines.Add((Mood.Info, "shield"))
                    lines.Add((Mood.Info, "broke!"))
                    character.SetStatistic(StatisticType.Defend, character.CharacterType.ToCharacterTypeDescriptor.GetStatistic(StatisticType.Defend).Value)
                End If
                character.AddMessage(Nothing, lines)
            End If
        End If
    End Sub
End Class
