Imports TGGD.UI
Imports TGGDLRJ2025.Business
Imports TGGDLRJ2025.Data

Public Class UIContext
    Implements IUIContext
    ReadOnly buffer As IUIBuffer(Of Integer)
    Private ReadOnly worldData As New WorldData
    Private ReadOnly sfxQueue As New Queue(Of String)
    Private ReadOnly Property World As IWorld
        Get
            Return New World(worldData)
        End Get
    End Property
    Private state As IUIState = Nothing
    Sub New(columns As Integer, rows As Integer, pixelBuffer As Integer())
        Me.buffer = New UIBuffer(Of Integer)(columns, rows, pixelBuffer)
        state = New TitleState(buffer, World, AddressOf PlaySfx)
    End Sub

    Private Sub PlaySfx(sfx As String)
        sfxQueue.Enqueue(sfx)
    End Sub

    Public ReadOnly Property Sfx As String Implements IUIContext.Sfx
        Get
            Return If(sfxQueue.Any, sfxQueue.Peek, Nothing)
        End Get
    End Property

    Public Sub Refresh() Implements IUIContext.Refresh
        state.Refresh()
    End Sub

    Public Sub HandleCommand(command As String) Implements IUIContext.HandleCommand
        state = state.HandleCommand(command)
    End Sub

    Public Sub NextSfx() Implements IUIContext.NextSfx
        If sfxQueue.Any Then
            sfxQueue.Dequeue()
        End If
    End Sub
End Class
